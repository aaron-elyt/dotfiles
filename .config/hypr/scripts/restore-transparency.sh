#!/bin/bash
#
# Restore transparency settings for windows
# Run this on Hyprland startup to restore opaque windows
#

OPAQUE_WINDOWS_FILE="$HOME/.config/hypr/opaque_windows.txt"

if [ ! -f "$OPAQUE_WINDOWS_FILE" ]; then
    exit 0
fi

# Wait a bit for windows to load
sleep 2

# Read each window address and set it to opaque
while IFS= read -r window_address; do
    if [ -n "$window_address" ]; then
        # Check if window still exists
        if hyprctl clients -j | jq -r '.[].address' | grep -q "$window_address"; then
            hyprctl dispatch setprop address:$window_address opaque 1
        fi
    fi
done < "$OPAQUE_WINDOWS_FILE"

# Clean up file of non-existent windows
temp_file=$(mktemp)
while IFS= read -r window_address; do
    if [ -n "$window_address" ] && hyprctl clients -j | jq -r '.[].address' | grep -q "$window_address"; then
        echo "$window_address" >> "$temp_file"
    fi
done < "$OPAQUE_WINDOWS_FILE"

mv "$temp_file" "$OPAQUE_WINDOWS_FILE" 