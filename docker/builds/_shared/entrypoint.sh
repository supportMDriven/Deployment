#!/bin/bash
set -e

echo "--- Checking for file updates ---"

# 1. Overwrite the volume data with the fresh code from the image
# We assume the image stores fresh code in /app_temp (see Dockerfile below)
if [ -d "/app_temp" ]; then
    echo "Syncing new app files..."
    # -a: preserve attributes, -r: recursive
    cp -ar /app_temp/. /app/
    rm -rf /app_temp
fi

echo "--- Starting Application ---"

# 2. THE HANDOFF
# This executes whatever command is passed to the container
exec "$@"