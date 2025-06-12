#!/bin/bash
#
# Toggle transparency for the focused window
# Toggles between opaque (1.0) and the configured transparency values
#

# Get the focused window address
WINDOW_ADDRESS=$(hyprctl activewindow -j | jq -r '.address')

if [ "$WINDOW_ADDRESS" = "null" ] || [ -z "$WINDOW_ADDRESS" ]; then
    echo "No focused window found"
    exit 1
fi

# Get current decoration configuration values
DECORATION_CONFIG="$HOME/.config/hypr/conf/decorations/rounding-all-blur.conf"
ACTIVE_OPACITY=$(grep "^\s*active_opacity" "$DECORATION_CONFIG" | grep -oE '[0-9]+\.[0-9]+')
INACTIVE_OPACITY=$(grep "^\s*inactive_opacity" "$DECORATION_CONFIG" | grep -oE '[0-9]+\.[0-9]+')

# Fallback to default values if not found
if [ -z "$ACTIVE_OPACITY" ]; then
    ACTIVE_OPACITY="0.9"
fi
if [ -z "$INACTIVE_OPACITY" ]; then
    INACTIVE_OPACITY="0.6"
fi

# File to store opaque windows
OPAQUE_WINDOWS_FILE="$HOME/.config/hypr/opaque_windows.txt"

# Check if window is currently set to opaque
if grep -q "$WINDOW_ADDRESS" "$OPAQUE_WINDOWS_FILE" 2>/dev/null; then
    # Window is marked as opaque, make it transparent again using configured values
    hyprctl dispatch setprop address:$WINDOW_ADDRESS opaque 0
    # Remove from opaque list
    grep -v "$WINDOW_ADDRESS" "$OPAQUE_WINDOWS_FILE" > "$OPAQUE_WINDOWS_FILE.tmp" 2>/dev/null
    mv "$OPAQUE_WINDOWS_FILE.tmp" "$OPAQUE_WINDOWS_FILE" 2>/dev/null || rm -f "$OPAQUE_WINDOWS_FILE.tmp"
    echo "Window made transparent (using configured opacity: $ACTIVE_OPACITY)"
else
    # Window is transparent, make it completely opaque
    hyprctl dispatch setprop address:$WINDOW_ADDRESS opaque 1
    # Add to opaque list
    echo "$WINDOW_ADDRESS" >> "$OPAQUE_WINDOWS_FILE"
    echo "Window made completely opaque (100% solid, no transparency)"
fi 