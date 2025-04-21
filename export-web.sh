#!/bin/bash

# Define fallback Godot executable path
FALLBACK_GODOT_PATH="G:/godot-binaries/Godot_v4.4.1-stable_win64.exe/Godot_v4.4.1-stable_win64.exe"

# Function to increment the version string
increment_version() {
    local version=$1
    local prefix=${version%.*}
    local number=${version##*.}
    printf "%s.%02d" "$prefix" "$((10#$number + 1))"
}

# Check if Godot executable is in PATH or use fallback
if command -v godot &> /dev/null; then
    GODOT_EXECUTABLE="godot"
elif [ -f "$FALLBACK_GODOT_PATH" ]; then
    GODOT_EXECUTABLE="$FALLBACK_GODOT_PATH"
else
    echo "Error: Godot executable not found in PATH or at '$FALLBACK_GODOT_PATH'."
    exit 1
fi

# Find the highest version
LATEST_VERSION=$(ls -1 "./releases/" 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

if [ -z "$LATEST_VERSION" ]; then
    # If no versions exist, start with v0.0.01
    NEXT_VERSION="v0.0.01"
else
    # Increment the version
    NEXT_VERSION=$(increment_version "$LATEST_VERSION")
fi


# Define export paths
EXPORT_PRESET="Web"
EXPORT_OUTPUT="./releases/$NEXT_VERSION/index.html"

echo $EXPORT_OUTPUT
# exit 0

# Create the output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$EXPORT_OUTPUT")
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Creating directories for export output: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Export the project
echo "Exporting Godot project using the '$EXPORT_PRESET' preset..."
"$GODOT_EXECUTABLE" --export-debug --verbose --headless "$EXPORT_PRESET" "$EXPORT_OUTPUT"

# Check if export succeeded
if [ $? -eq 0 ]; then
    echo "Export successful: $EXPORT_OUTPUT"
else
    echo "Export failed."
    exit 1
fi

# Zip the exported files into current.zip using PowerShell
ZIP_FILE="./releases/$NEXT_VERSION.zip"
echo "Zipping exported files into $ZIP_FILE..."
powershell.exe -Command "Compress-Archive -Path '$OUTPUT_DIR/*' -DestinationPath '$ZIP_FILE' -Force"

if [ $? -eq 0 ]; then
    echo "Zipping successful: $ZIP_FILE"
else
    echo "Zipping failed."
    exit 1
fi
