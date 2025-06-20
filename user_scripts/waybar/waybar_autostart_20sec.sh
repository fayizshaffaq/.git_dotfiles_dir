#!/usr/bin/env bash
# Minimal Waybar Temporary Launcher (for startup, silent)

# --- Configuration ---
# Waybar will be forcefully killed (SIGKILL) after this many seconds.
DURATION_SECONDS=20
# Command to start Waybar.
WAYBAR_COMMAND="waybar"
# --- End Configuration ---

# Start Waybar in the background, detached and silent.
# nohup ensures it keeps running if the terminal closes, and output is redirected.
nohup $WAYBAR_COMMAND >/dev/null 2>&1 &

# In a separate, detached background process:
# 1. Wait for DURATION_SECONDS.
# 2. Forcefully kill Waybar by its exact command name.
(
  sleep "$DURATION_SECONDS"
  # Using pkill with -9 (SIGKILL) for a forceful termination.
  # -x ensures matching the exact command name "waybar".
  # '|| true' ensures the subshell itself doesn't report an error 
  # if Waybar is already closed for some reason.
  pkill -9 -x "$WAYBAR_COMMAND" || true
) &

# Main script exits immediately. The background processes (Waybar and the killer subshell) continue.
exit 0
