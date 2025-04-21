#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Create a .env file with ITCH_USERNAME and GAME_SLUG variables."
    exit 1
fi

# Check if required environment variables are set
if [ -z "$ITCH_USERNAME" ] || [ -z "$GAME_SLUG" ]; then
    echo "Error: ITCH_USERNAME and GAME_SLUG must be set in the .env file."
    exit 1
fi

# Construct the itch.io game identifier
GAME_IDENTIFIER="$ITCH_USERNAME/$GAME_SLUG"

# Check if Butler is installed
if ! command -v butler &> /dev/null
then
    echo "Error: Butler is not installed. Please install it from https://itch.io/docs/butler/"
    exit 1
fi

# Determine the next version
BASE_DIR="./releases"  # Directory to store versions locally
mkdir -p "$BASE_DIR"

LATEST_ZIP=$(ls -1 "$BASE_DIR" 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+\.zip$' | sort -V | tail -n 1)
LATEST_VERSION=$(echo "$LATEST_ZIP" | sed 's/\.zip$//')

echo "$BASE_DIR/$(basename "$LATEST_ZIP")"
# exit 0
cp -f "$BASE_DIR/$(basename "$LATEST_ZIP")" "$BASE_DIR/$(basename "current.zip")"

echo "$BASE_DIR/$(basename "current.zip")"


# Upload the file using Butler
echo "Uploading '$LATEST_ZIP' to itch.io project '$GAME_IDENTIFIER' as version '$LATEST_VERSION'..."
butler push "$BASE_DIR/$(basename "$LATEST_ZIP")" "$GAME_IDENTIFIER:$LATEST_VERSION"

butler push "$BASE_DIR/$(basename "current.zip")" "$GAME_IDENTIFIER:current"

# Check if the upload was successful
if [ "$?" -eq 0 ]; then
    echo "Upload successful! Version: $LATEST_VERSION"
else
    echo "Error: Upload failed."
    exit 1
fi
