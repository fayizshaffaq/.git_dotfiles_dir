#!/bin/bash

# This script runs in the background to automatically update my desktop
# theme whenever the swww wallpaper changes.

# --- 💡 CONFIGURATION: Fast, Independent Commands 💡 ---
# These are commands that can run quickly and in the background.
CUSTOM_COMMANDS=(
  # For Rofi: Combines the pywal colors with my rofi template.
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

        # Create the SASS bridge file that combines pywal colors with a comprehensive set of GTK rules
        cat << 'EOF' > "$GTK_BRIDGE_SCSS"
@import '###PYWAL_SOURCE_SCSS###';

/*
 * A comprehensive GTK theme override using Pywal SASS variables.
 * This aims to provide a consistent dark theme across GTK3 and GTK4 apps.
 */

/* ===== General Window Styling ===== */
window, GtkWindow, .thunar {
    background-color: $background;
    color: $foreground;
    border-radius: 8px;
    border: 1px solid $color8;
}

/* ===== Header Bar ===== */
headerbar, .header-bar {
    background-color: darken($background, 3%);
    color: $foreground;
    border: none;
    border-bottom: 1px solid $color8;
    padding: 6px;
}

headerbar button, .header-bar button {
    background-color: transparent;
    border: none;
    color: $foreground;
}

headerbar button:hover, .header-bar button:hover {
    background-color: rgba($foreground, 0.1);
}

/* ===== Buttons ===== */
button {
    background-image: none;
    background-color: $color1;
    color: $background;
    border: none;
    border-radius: 4px;
    padding: 8px 12px;
    font-weight: bold;
}

button:hover {
    background-color: lighten($color1, 10%);
}

button:active {
    background-color: darken($color1, 5%);
}

/* Suggested action button (e.g., "Save") */
.suggested-action {
    background-color: $color2;
    color: $foreground;
}

.suggested-action:hover {
    background-color: lighten($color2, 10%);
}

/* Destructive action button (e.g., "Delete") */
.destructive-action {
    background-color: $color3;
    color: $foreground;
}

.destructive-action:hover {
    background-color: lighten($color3, 10%);
}


/* ===== Text Entries ===== */
entry {
    background-color: darken($background, 5%);
    color: $foreground;
    border: 1px solid $color8;
    border-radius: 4px;
    padding: 6px;
}

entry:focus {
    border-color: $color1;
}

/* ===== Sidebars, Panes, and Lists ===== */
.sidebar, paned, list, treeview {
    background-color: darken($background, 3%);
    color: $foreground;
}

row:hover, list row:hover {
    background-color: rgba($foreground, 0.05);
}

row:selected, list row:selected {
    background-color: $color1;
    color: $background;
}


/* ===== Notebooks (Tabs) ===== */
notebook {
    border: none;
}

notebook header {
    background-color: darken($background, 5%);
    border-bottom: 1px solid $color8;
}

notebook tab {
    background-color: transparent;
    border: none;
    padding: 10px;
    color: $color8;
}

notebook tab:hover {
    background-color: rgba($foreground, 0.05);
}

notebook tab:checked {
    color: $foreground;
    background-color: darken($background, 2%);
    border-bottom: 2px solid $color1;
}


/* ===== Menus ===== */
menu, .menu {
    background-color: darken($background, 2%);
    border: 1px solid $color8;
}

menuitem, .menuitem {
    color: $foreground;
    padding: 8px 12px;
}

menuitem:hover, .menuitem:hover {
    background-color: $color1;
    color: $background;
}


/* ===== Scrollbars ===== */
scrollbar {
    background-color: transparent;
}

scrollbar slider {
    background-color: $color8;
    border-radius: 8px;
    min-width: 8px;
    min-height: 8px;
}

scrollbar slider:hover {
    background-color: lighten($color8, 10%);
}

EOF
        # We use sed to replace the placeholder because using "EOF" with quotes disables variable expansion
        sed -i "s|###PYWAL_SOURCE_SCSS###|$PYWAL_SOURCE_SCSS|" "$GTK_BRIDGE_SCSS"

        # Compile the SASS file into the final GTK3 and GTK4 CSS files
        sassc "$GTK_BRIDGE_SCSS" "$GTK3_FINAL_CSS"
        cp "$GTK3_FINAL_CSS" "$GTK4_FINAL_CSS" # Ensure consistency
        rm "$GTK_BRIDGE_SCSS" # Clean up temporary file
        echo "-> GTK theme update complete."
        
        # --- BACKGROUND COMMANDS (ASYNCHRONOUS) ---
        # Run the commands from my list in the background.
        if [ ${#CUSTOM_COMMANDS[@]} -gt 0 ]; then
            echo "Executing background commands..."
            for command_string in "${CUSTOM_COMMANDS[@]}"; do
                eval "$command_string" &
            done
        fi
        
        echo "Full theme update process finished."
    fi
done
