#!/bin/bash

# This script runs in the background to automatically update pywal colors
# and run a predefined list of custom scripts OR commands whenever the swww wallpaper changes.

# --- 💡 CONFIGURATION: ADD YOUR SCRIPTS OR COMMANDS HERE 💡 ---
# Add any script path or raw command string you want to run after a theme change.
# Each item MUST be enclosed in double quotes.
#
# If you don't have any, leave the list empty: CUSTOM_COMMANDS=()

CUSTOM_COMMANDS=(
  # Example 1: A raw command to reload Waybar
  #"pkill -SIGUSR2 Waybar"
  # Example 2: A path to another script you made
  # "$HOME/my-scripts/reload-cava.sh"
  # Example 3: Another raw command
  # "pywalfox update"
  
  # THE COMMANDS OR SCRIPS ALL NEED TO BE IN QUOTATIONS!!!!!!!!, the script needs to be stopped and rerun if there are any changes,or just restart your pc and it'll auto run becuasue it's in hyprland.conf set to auto exec

#rofi
"cat ~/.cache/wal/colors-rofi-dark.rasi ~/.config/wal/templates/rofi_template.rasi > ~/.config/rofi/config.rasi"

#firefox
"pywalfox update"

#kitty
"kitty @ set-colors --all --configured ~/.cache/wal/colors-kitty.conf"

#swaync
"pkill swaync && sleep 0.2 && swaync &"

)
# ----------------------------------------------------

# --- Environment Setup for Daemons ---
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
# -------------------------------------------

# Find the directory swww stores its cache in.
SWWW_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/swww"

# Wait for the directory to exist before starting to watch.
while [ ! -d "$SWWW_CACHE_DIR" ]; do
  sleep 1
done

echo "Theme Updater is running, watching for wallpaper changes..."

# Main loop using inotifywait
inotifywait -m -e create,modify --format '%w%f' "$SWWW_CACHE_DIR" | while read -r event; do
    echo "Detected wallpaper change. Updating theme..."

    CURRENT_WALLPAPER=$(swww query | awk -F 'image: ' '{print $2}')

    if [ -n "$CURRENT_WALLPAPER" ]; then
        # --- CORE ACTIONS ---
        wal -i "$CURRENT_WALLPAPER"
        #hyprctl reload
        
        # --- CUSTOM COMMAND EXECUTION ---
        if [ ${#CUSTOM_COMMANDS[@]} -gt 0 ]; then
            echo "Executing custom commands from the list..."
            for command_string in "${CUSTOM_COMMANDS[@]}"; do
                echo "-> Executing: $command_string"
                # Use 'eval' to execute the string as a command.
                # This is safe because you are the one defining the commands.
                # The '&' at the end runs it in the background to prevent blocking.
                eval "$command_string" &
            done
        else
            echo "-> Custom command list is empty."
        fi
        
        echo "Theme update complete."
    fi
done
