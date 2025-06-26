#!/bin/bash

# This script runs in the background to automatically update your desktop
# theme whenever the swww wallpaper changes.

# --- 💡 CONFIGURATION: Fast, Independent Commands 💡 ---
# These are commands that can run quickly and in the background.
# The GTK generation process is now handled separately and synchronously.
CUSTOM_COMMANDS=(
  # For Rofi: Combines the pywal colors with your rofi template.
  "cat ~/.cache/wal/colors-rofi-dark.rasi ~/.config/rofi/template/rofi_template.rasi > ~/.config/rofi/config.rasi"

  # For Firefox: Updates the browser theme via the Pywalfox add-on.
  "pywalfox update"
)
# ----------------------------------------------------

# --- Environment Setup for Daemons ---
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# --- Core Watcher Logic ---
SWWW_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/swww"
while [ ! -d "$SWWW_CACHE_DIR" ]; do sleep 1; done
echo "Theme Updater is running, watching for wallpaper changes..."

inotifywait -m -e create,modify --format '%w%f' "$SWWW_CACHE_DIR" | while read -r event; do
    echo "Detected wallpaper change. Updating theme..."
    CURRENT_WALLPAPER=$(swww query | awk -F 'image: ' '{print $2}')

    if [ -n "$CURRENT_WALLPAPER" ]; then
        # --- PRIMARY ACTION ---
        # This generates all the necessary color files, including colors.scss
        wal -i "$CURRENT_WALLPAPER"
        
        # --- GTK THEME GENERATION (SASS Method) ---
        # This is the verified method. It runs synchronously to prevent errors.
        echo "-> Generating GTK theme via SASS..."
        
        # Define file paths
        PYWAL_SOURCE_SCSS="$HOME/.cache/wal/colors.scss"
        GTK_BRIDGE_SCSS="/tmp/gtk_bridge.scss" # Temporary file
        GTK3_FINAL_CSS="$HOME/.config/gtk-3.0/gtk.css"
        GTK4_FINAL_CSS="$HOME/.config/gtk-4.0/gtk.css"

        # Create the SASS bridge file that combines pywal colors with GTK rules
        cat << EOF > "$GTK_BRIDGE_SCSS"
@import '${PYWAL_SOURCE_SCSS}';

window, GtkWindow, .thunar {
    background-color: \$background;
    color: \$foreground;
}

button {
    background-image: none;
    background-color: \$color1;
    color: \$background;
    border: none;
}

button:hover {
    background-color: lighten(\$color1, 10%);
}
EOF
        # Compile the SASS file into the final GTK3 and GTK4 CSS files
        sassc "$GTK_BRIDGE_SCSS" "$GTK3_FINAL_CSS"
        cp "$GTK3_FINAL_CSS" "$GTK4_FINAL_CSS" # Ensure consistency
        rm "$GTK_BRIDGE_SCSS" # Clean up temporary file
        echo "-> GTK theme update complete."
        
        # --- BACKGROUND COMMANDS (ASYNCHRONOUS) ---
        # Run the commands from your list in the background.
        if [ ${#CUSTOM_COMMANDS[@]} -gt 0 ]; then
            echo "Executing background commands..."
            for command_string in "${CUSTOM_COMMANDS[@]}"; do
                eval "$command_string" &
            done
        fi
        
        echo "Full theme update process finished."
    fi
done
