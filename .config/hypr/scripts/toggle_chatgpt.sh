#!/bin/bash
#
# Toggle ChatGPT popup window
# Uses Chromium in app mode with Wayland support
# Simple show/hide functionality
#

# Chromium command with app mode and Wayland support
export BROWSER="zen"
CHROMIUM_CMD="chromium --app=https://chat.openai.com/?temporary-chat=true -ozone-platform=wayland --enable-features=UseOzonePlatform --no-default-browser-check --disable-features=MediaRouter"

# Check if ChatGPT window exists (using the actual window class that gets created)
CHATGPT_WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.class == "chrome-chat.openai.com__-Default") | .address')

if [ -n "$CHATGPT_WINDOW" ]; then
  echo "Found existing ChatGPT window: $CHATGPT_WINDOW"

  # Check what workspace the ChatGPT window is currently on
  CURRENT_WORKSPACE=$(hyprctl clients -j | jq -r '.[] | select(.class == "chrome-chat.openai.com__-Default") | .workspace.name')
  ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.name')

  echo "ChatGPT is on workspace: $CURRENT_WORKSPACE"
  echo "Active workspace: $ACTIVE_WORKSPACE"

  if [ "$CURRENT_WORKSPACE" = "special:chatgpt" ]; then
    # Window is hidden in special workspace, show it on current workspace
    hyprctl dispatch movetoworkspace $ACTIVE_WORKSPACE,address:$CHATGPT_WINDOW
    # Set to floating by default when shown
    hyprctl dispatch setfloating address:$CHATGPT_WINDOW
    hyprctl dispatch centerwindow address:$CHATGPT_WINDOW
    hyprctl dispatch focuswindow address:$CHATGPT_WINDOW
    echo "ChatGPT window shown on workspace $ACTIVE_WORKSPACE (floating)"
  else
    # Window is visible, hide it to special workspace
    hyprctl dispatch movetoworkspacesilent special:chatgpt,address:$CHATGPT_WINDOW
    echo "ChatGPT window hidden to special:chatgpt workspace"
  fi
else
  # Window doesn't exist, launch it
  echo "No ChatGPT window found, launching..."

  # Launch Chromium in background
  $CHROMIUM_CMD &
  LAUNCH_PID=$!

  # Wait for the window to appear (with timeout)
  echo "Waiting for window to appear..."
  for i in {1..10}; do
    sleep 0.5
    CHATGPT_WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.class == "chrome-chat.openai.com__-Default") | .address')
    if [ -n "$CHATGPT_WINDOW" ]; then
      echo "Window appeared after ${i} attempts"
      break
    fi
  done

  if [ -n "$CHATGPT_WINDOW" ]; then
    # Window was created, move it to current workspace and make it floating
    ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.name')
    hyprctl dispatch movetoworkspace $ACTIVE_WORKSPACE,address:$CHATGPT_WINDOW
    hyprctl dispatch setfloating address:$CHATGPT_WINDOW
    hyprctl dispatch centerwindow address:$CHATGPT_WINDOW
    hyprctl dispatch focuswindow address:$CHATGPT_WINDOW
    echo "ChatGPT launched and shown on workspace $ACTIVE_WORKSPACE (floating)"
  else
    echo "Failed to detect ChatGPT window after launch"
    # Kill the process if window detection failed
    kill $LAUNCH_PID 2>/dev/null
  fi
fi

