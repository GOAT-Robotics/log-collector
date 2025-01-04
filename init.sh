#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo $0"
    exit 1
fi

# Prompt for inputs
read -p "Enter your username: " USERNAME
read -p "Enter the full path to the Python script (e.g., /home/$USERNAME/multi_service_logger.py): " SCRIPT_LOCATION

# Validate inputs
if [[ ! -f "$SCRIPT_LOCATION" ]]; then
    echo "Error: Python script not found at $SCRIPT_LOCATION"
    exit 1
fi

# Create the Systemd service file
SERVICE_FILE="/etc/systemd/system/multi_service_logger.service"

echo "Creating service file at $SERVICE_FILE..."

cat >$SERVICE_FILE <<EOL
[Unit]
Description=Multi-Service Logger for apex_startup.service and rcc-agent.service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $SCRIPT_LOCATION
Restart=on-failure
User=$USERNAME
WorkingDirectory=$(dirname $SCRIPT_LOCATION)
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-q.target
EOL

# Reload Systemd, enable and start the service
echo "Reloading Systemd..."
systemctl daemon-reload

echo "Enabling the service..."
systemctl enable multi_service_logger

echo "Starting the service..."
systemctl start multi_service_logger

echo "Checking service status..."
systemctl status multi_service_logger
