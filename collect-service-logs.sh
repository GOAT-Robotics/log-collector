#!/bin/bash

# Define the services to collect logs from
SERVICES=("apex_startup.service" "rcc-agent.service")

# Get the hostname
HOSTNAME=$(hostname)

# Set the output directory for logs
OUTPUT_DIR="service_logs"
ARCHIVE_NAME="service_logs_${HOSTNAME}_$(date +%Y%m%d_%H%M%S).tar.gz"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Collect logs for each service
echo "Collecting logs from services..."
for SERVICE in "${SERVICES[@]}"; do
    LOG_FILE="$OUTPUT_DIR/${SERVICE}.log"
    echo "Collecting logs for $SERVICE..."
    journalctl -u "$SERVICE" >"$LOG_FILE"
    echo "Logs collected for $SERVICE: $LOG_FILE"
done

# Compress the log files into a tar.gz archive
echo "Compressing logs into $ARCHIVE_NAME..."
tar -czf "$ARCHIVE_NAME" "$OUTPUT_DIR"

# Remove the temporary log directory
rm -rf "$OUTPUT_DIR"

echo "Logs collection completed: $ARCHIVE_NAME"
