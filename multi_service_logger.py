import os
import logging
from logging.handlers import RotatingFileHandler
import subprocess
from datetime import datetime
import threading
import signal
import sys


class ServiceLogger:
    def __init__(self, service_name):
        self.service_name = service_name
        self.logger = self.setup_logger()
        self.process = None
        self.stop_event = threading.Event()
        self.last_message = None
        self.duplicate_count = 0

    def setup_logger(self):
        """Set up a rotating file logger for the service."""
        log_dir = os.path.expanduser("~/apex_logs")
        os.makedirs(log_dir, exist_ok=True)
        log_file_path = os.path.join(log_dir, f"logs/{self.service_name}.log")

        logger = logging.getLogger(self.service_name)
        logger.setLevel(logging.DEBUG)
        handler = RotatingFileHandler(
            log_file_path,
            maxBytes=10 * 1024 * 1024,  # 10 MB
            backupCount=50  # Keep up to 50 backup files
        )
        formatter = logging.Formatter(
            '%(asctime)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def log_message(self, message):
        """Log a message with throttling for repetitive logs."""
        if message == self.last_message:
            self.duplicate_count += 1
        else:
            if self.duplicate_count > 0:
                # Log suppressed duplicates
                self.logger.info(f"[Suppressed {self.duplicate_count} duplicate messages]")
            self.last_message = message
            self.duplicate_count = 0
            self.logger.info(message)

    def stream_journal(self):
        """Stream and log journalctl output for the service."""
        try:
            self.process = subprocess.Popen(
                ["journalctl", "-f", "-u", self.service_name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            for line in iter(self.process.stdout.readline, ''):
                if self.stop_event.is_set():
                    break
                self.log_message(line.strip())
        except Exception as e:
            self.logger.error(f"Error in journal streaming for {self.service_name}: {e}")
        finally:
            self.stop_process()

    def stop_process(self):
        """Stop the journalctl process."""
        if self.process:
            self.process.terminate()
            self.process.wait()
            if self.duplicate_count > 0:
                self.logger.info(f"[Suppressed {self.duplicate_count} duplicate messages]")
            self.logger.info(f"Stopped logging for {self.service_name}")

    def stop(self):
        """Signal to stop streaming."""
        self.stop_event.set()
        self.stop_process()


def signal_handler(signal, frame, loggers):
    """Handle termination signals to ensure clean shutdown."""
    print("Shutting down service loggers...")
    for logger in loggers:
        logger.stop()
    sys.exit(0)


def main():
    services = ["apex_startup.service", "rcc-agent.service"]
    service_loggers = [ServiceLogger(service_name) for service_name in services]

    # Set up threads for each service
    threads = []
    for service_logger in service_loggers:
        thread = threading.Thread(target=service_logger.stream_journal)
        thread.daemon = True
        threads.append(thread)
        thread.start()

    # Handle termination signals
    signal.signal(signal.SIGINT, lambda sig, frame: signal_handler(sig, frame, service_loggers))
    signal.signal(signal.SIGTERM, lambda sig, frame: signal_handler(sig, frame, service_loggers))

    # Wait for threads to finish
    try:
        for thread in threads:
            thread.join()
    except KeyboardInterrupt:
        signal_handler(signal.SIGINT, None, service_loggers)


if __name__ == "__main__":
    main()