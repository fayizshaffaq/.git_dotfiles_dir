#!/usr/bin/env bash
# ~/user_scripts/waybar/fs_waybar_toggle.sh

# --- EMENDATION FOR INITIAL LAUNCH ---
pgrep -x waybar >/dev/null || waybar & disown


WAYBAR_BIN="$(command -v waybar)"
POLL_INTERVAL=0.5

while :; do
  FS_STATE="$(hyprctl -j activewindow | jq -r '.fullscreen')"
  if [[ "$FS_STATE" -eq 1 || "$FS_STATE" -eq 2 ]]; then
    pgrep -x waybar && pkill -x waybar
  else
    pgrep -x waybar >/dev/null || "$WAYBAR_BIN" &
  fi
  sleep "$POLL_INTERVAL"
done
