#!/bin/sh
set -e

echo "--- Checking for file updates ---"

# ---------------------------------------------------------
# STEP 1: Staging
# ---------------------------------------------------------
if [ -n "$UPDATE_APP" ] && [ "$UPDATE_APP" != "false" ]; then
    echo "Update flag detected. Staging new files in /app_temp..."
    
    # Safety check: recreate /app_temp if missing, and clear out the old baked-in files
    # so we don't mix old image files with the newly downloaded ones.
    mkdir -p /app_temp
    rm -rf /app_temp/*
    
    BASE_API="https://mdriven.net/Rest/ProductRelease/Get?vProduct=ServerCore&platform=linux%20musl"

   
    if [ "$UPDATE_APP" = "true" ]; then
        echo "Fetching LATEST release URL..."
        API_ENDPOINT="$BASE_API"
    else
        echo "Fetching specific version ($UPDATE_APP)..."
        API_ENDPOINT="${BASE_API}&version=${UPDATE_APP}"
    fi

    # Your exact jq logic to grab the first item in the array
    DOWNLOAD_URL=$(curl -sL "$API_ENDPOINT" | jq -r '.Releases[0]')

    # 1b. Validate the URL and Download
    if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
        echo "Error: Could not find a valid release URL. Skipping update."
    else
        echo "Downloading from: $DOWNLOAD_URL"
        # I changed the output path to /tmp/release.zip to keep the root directory clean
        curl -L -o /tmp/release.zip "$DOWNLOAD_URL"
        
        # Unzip into your newly created staging area and clean up the zip file
        unzip -q -o  /tmp/release.zip -d /app_temp
        rm /tmp/release.zip
        
        echo "Download to staging complete!"
    fi
fi
# ---------------------------------------------------------
# 2. Syncing Your Code. 
# ---------------------------------------------------------
# Overwrite the volume data with the fresh code from the image
# The image stores fresh code in /app_temp (see Dockerfile below)
if [ -d "/app_temp" ]; then
    echo "Syncing new app files..."
    # -a: preserve attributes, -r: recursive
    cp -ar /app_temp/. /app/
    rm -rf /app_temp
fi

# ---------------------------------------------------------
# 3. Starting Application
# ---------------------------------------------------------
# Check if PUID and PGID environment variables are set
if [ -n "$PUID" ] && [ -n "$PGID" ]; then
    echo "PUID and PGID specified ($PUID:$PGID). Setting ownership..."
    
    # Change ownership to the specified user and group
    chown -R "$PUID:$PGID" /app
    
    echo "Dropping privileges and starting application as $PUID:$PGID..."
    
    # Execute the app by dropping privileges to the specified UID/GID
    echo "Starting application..."
    exec su-exec 1000:1000 "$@"

else
    # 3. If the variables are missing, skip chown and run normally (as Root)
    echo "PUID or PGID not specified. Skipping ownership changes."
    echo "Starting application as default user (root)..."
    
    # Execute the app directly
    echo "Starting application..."
    exec "$@"
fi