#!/bin/bash

# Set the output directory for logs
OUTPUT_DIR="gtstudio_logs"
ARCHIVE_NAME="gtstudio_logs_$(date +%Y%m%d_%H%M%S).tar.gz"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Fetch all running container IDs
CONTAINER_IDS=$(docker ps -q)

# Check if there are running containers
if [ -z "$CONTAINER_IDS" ]; then
    echo "No running Docker containers found."
    exit 1
fi

# Collect logs for each container
echo "Collecting logs from running Docker containers..."
for CONTAINER_ID in $CONTAINER_IDS; do
    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' "$CONTAINER_ID" | sed 's/^\/\|\/$//g')
    LOG_FILE="$OUTPUT_DIR/${CONTAINER_NAME}_${CONTAINER_ID}.log"
    docker logs "$CONTAINER_ID" &>"$LOG_FILE"
    echo "Logs collected for container: $CONTAINER_NAME ($CONTAINER_ID)"
done

# Compress the log files into a tar.gz archive
echo "Compressing logs into $ARCHIVE_NAME..."
tar -czf "$ARCHIVE_NAME" "$OUTPUT_DIR"

# Remove the temporary log directory
rm -rf "$OUTPUT_DIR"

echo "Logs collection completed: $ARCHIVE_NAME"
