#!/bin/sh
set -e

# Check the currently installed version (if it exists)
CURRENT_VERSION="none"
if [ -f "/app/version.txt" ]; then
    CURRENT_VERSION=$(cat /app/version.txt)
fi

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
    
    
    if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
        BASE_API="https://mdriven.net/Rest/ProductRelease/Get?vProduct=ServerCore&platform=linux"
    else
        BASE_API="https://mdriven.net/Rest/ProductRelease/Get?vProduct=ServerCore&platform=linux%20arm64"
    fi

   
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
        # 1c. Extract the exact version from the filename in the URL
        # e.g., converts "http://.../ServerCore_20260316.zip" to "20260316"
        FILENAME=$(basename "$DOWNLOAD_URL")
        TARGET_VERSION=$(echo "$FILENAME" | sed -E 's/^.*_//; s/\.zip$//')

        # 1d. Compare versions to decide if we need to download
        if [ "$TARGET_VERSION" = "$CURRENT_VERSION" ]; then
            echo "Version $TARGET_VERSION is already installed. Skipping download."
        else
            echo "Updating from $CURRENT_VERSION to $TARGET_VERSION..."
        
            echo "Downloading from: $DOWNLOAD_URL"
            # Set the output path to /tmp/release.zip to keep the root directory clean
            curl -L -o /tmp/release.zip "$DOWNLOAD_URL"
            
            # Unzip into your newly created staging area and clean up the zip file
            unzip -q -o  /tmp/release.zip -d /app_temp
            rm /tmp/release.zip

            # SAVE THE NEW VERSION: Write it to the staging area so it syncs to /app
            echo "$TARGET_VERSION" > /app_temp/version.txt
            
            echo "Download to staging complete!"
        fi
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

# Check if PwdReset file exists
if [ -f "/pwdreset/PwdReset.txt" ]; then
    echo "Copying PwdReset..."
    cp /pwdreset/PwdReset.txt /app/App_Data/
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
    exec setpriv --reuid="$PUID" --regid="$PGID" --clear-groups "$@"

else
    # 3. If the variables are missing, skip chown and run normally (as Root)
    echo "PUID or PGID not specified. Skipping ownership changes."
    echo "Starting application as default user (root)..."
    
    # Execute the app directly
    echo "Starting application..."
    exec "$@"
fi