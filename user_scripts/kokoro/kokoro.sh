#!/bin/bash
#
# kokoro-tts-script.sh
# A robust script to automate text-to-speech generation with Kokoro-TTS.
# It fetches text from the clipboard, formats it, generates a uniquely named
# audio file, logs *all* actions, and plays the resulting audio in a dedicated window.
#

# --- CONFIGURATION ---
# These variables should be customized to match your system's setup.
# The script assumes a user named 'fayiz'. If this is not your username,
# you must update the paths accordingly.
readonly USER_HOME="/home/fayiz"
readonly VENV_PATH="${USER_HOME}/kokoro_cpu/bin/activate"
readonly TTS_DIR="${USER_HOME}/kokoro_cpu/kokoro-tts"
readonly TTS_EXECUTABLE="./kokoro-tts"
readonly OUTPUT_DIR="/mnt/ramdisk/kokoro"
readonly LOG_DIR="${USER_HOME}/.local/share/kokoro-tts-script"
readonly LOG_FILE="/tmp/kokoro_log.log"
readonly VOICE="af_heart"
readonly PLAYBACK_SPEED="2.0" # Set desired playback speed (e.g., 1.0, 1.5, 2.0)
# --- END CONFIGURATION ---

#VOICES #af_heart: A || af_alloy: C || af_aoede: C+ || af_bella: A- || af_jessica: D || af_kore: C+ || af_nicole: B- || af_nova: C || af_river: D || af_sarah: C+ || af_sky: C- || am_adam: F+ || am_echo: D || am_eric: D || am_fenrir: C+ || am_liam: D || am_michael: C+ || am_onyx: D || am_puck: C+ || am_santa: D-

#indian voice hf_alpha hf_beta hm_omega hm_psi

#british bf_alice bf_emma (best) bf_isabella bf_Lily bm_daniel bm_fable bm_george bm_lewis


# --- LOGGING SETUP ---
# Ensures the log directory exists.
mkdir -p "$LOG_DIR"

# Redirects all output (stdout and stderr) from the script to the log file.
# This creates a comprehensive record of the script's execution for troubleshooting.
exec > >(tee -a "$LOG_FILE") 2>&1

# --- SCRIPT FUNCTIONS ---

# Logs a message with a timestamp.
# Usage: log_message "This is a log entry."
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Handles script exit, cleaning up temporary files.
# Usage: trap cleanup EXIT
cleanup() {
  if [ -n "$TEMP_TEXT_FILE" ] && [ -f "$TEMP_TEXT_FILE" ]; then
    rm -f "$TEMP_TEXT_FILE"
    log_message "Cleaned up temporary file: ${TEMP_TEXT_FILE}"
  fi
}

# Sends a desktop notification.
# Usage: notify "Title" "Message" "icon"
notify() {
    local title="$1"
    local message="$2"
    local icon="$3"
    if command -v notify-send &> /dev/null; then
        notify-send -t 5000 -i "$icon" "$title" "$message"
    else
        log_message "WARNING: 'notify-send' command not found. Cannot send desktop notification."
    fi
}

# --- SCRIPT EXECUTION ---

# Set a trap to call the cleanup function on script exit.
trap cleanup EXIT

log_message "--- Script execution started ---"

# Step 1: Check for necessary commands (wl-paste for Wayland, mpv for playback)
if ! command -v wl-paste &> /dev/null; then
    log_message "FATAL: 'wl-paste' command not found. This script requires it to get text from the clipboard on Wayland. Please install 'wl-clipboard'."
    notify "Kokoro TTS Script Error" "wl-paste not found. Please install wl-clipboard." "dialog-error"
    exit 1
fi

if ! command -v mpv &> /dev/null; then
    log_message "FATAL: 'mpv' command not found. This script requires it for audio playback. Please install 'mpv'."
    notify "Kokoro TTS Script Error" "mpv not found. Please install mpv." "dialog-error"
    exit 1
fi

log_message "All necessary commands are available."

# Step 2: Ensure the output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    log_message "Output directory '${OUTPUT_DIR}' not found. Creating it..."
    if ! mkdir -p "$OUTPUT_DIR"; then
        log_message "FATAL: Could not create output directory '${OUTPUT_DIR}'. Please check permissions."
        notify "Kokoro TTS Script Error" "Failed to create output directory in /mnt/ramdisk/kokoro. Check permissions." "dialog-error"
        exit 1
    fi
    log_message "Successfully created output directory."
fi

# Step 3: Get and format text from clipboard
log_message "Fetching text from clipboard..."
ORIGINAL_TEXT=$(wl-paste)
if [ -z "$ORIGINAL_TEXT" ]; then
    log_message "FATAL: Clipboard is empty. No text to process."
    notify "Kokoro TTS Script Error" "Clipboard is empty. Please copy some text." "dialog-warning"
    exit 1
fi

log_message "Formatting text..."
# 1. Replace newlines with spaces.
# 2. Remove any characters that are not letters, numbers, spaces, periods, commas, exclamation marks, or question marks.
# 3. Squeeze multiple spaces into a single space.
# 4. Trim leading/trailing whitespace.
CLEANED_TEXT=$(echo "$ORIGINAL_TEXT" | tr '\n' ' ' | sed 's/[^a-zA-Z0-9 .,!?]/ /g' | tr -s ' ' | sed 's/^[ \t]*//;s/[ \t]*$//')

if [ -z "$CLEANED_TEXT" ]; then
    log_message "FATAL: Text became empty after formatting. It might have only contained special characters."
    notify "Kokoro TTS Script Error" "No valid text found after formatting." "dialog-warning"
    exit 1
fi
log_message "Text formatted successfully."
log_message "Formatted Text: ${CLEANED_TEXT}"


# Step 4: Generate the dynamic filename
log_message "Generating dynamic filename..."
# Get the first five words for the filename.
FIRST_FIVE_WORDS=$(echo "$CLEANED_TEXT" | cut -d' ' -f1-5 | tr ' ' '_')
# Further sanitize by removing any lingering problematic characters for a filename.
FILENAME_SUFFIX=$(echo "$FIRST_FIVE_WORDS" | sed 's/[^a-zA-Z0-9_]/_/g')

# Find the next available index number.
# We look for files starting with a number and an underscore.
LAST_INDEX=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name '[0-9]*_*.wav' -print0 | xargs -0 -n 1 basename | sed 's/_.*//' | sort -rn | head -n 1)
if [ -z "$LAST_INDEX" ]; then
  NEXT_INDEX=1
else
  NEXT_INDEX=$((LAST_INDEX + 1))
fi
log_message "Next available file index is: ${NEXT_INDEX}"

FINAL_OUTPUT_FILENAME="${NEXT_INDEX}_${FILENAME_SUFFIX}.wav"
FINAL_OUTPUT_PATH="${OUTPUT_DIR}/${FINAL_OUTPUT_FILENAME}"
log_message "Generated output file path: ${FINAL_OUTPUT_PATH}"


# Step 5: Activate virtual environment and generate audio
log_message "Activating Python virtual environment at '${VENV_PATH}'..."
# We run the TTS command in a subshell to ensure the 'source' and 'cd' commands
# do not affect the main script's environment beyond this step.
(
    # Activate the venv
    source "$VENV_PATH" || { log_message "FATAL: Failed to source virtual environment."; exit 1; }
    log_message "Virtual environment activated."

    # Navigate to the TTS directory
    cd "$TTS_DIR" || { log_message "FATAL: Failed to change directory to '${TTS_DIR}'."; exit 1; }
    log_message "Changed directory to '${TTS_DIR}'."

    # Create a secure temporary file for the input text
    TEMP_TEXT_FILE=$(mktemp)
    echo "$CLEANED_TEXT" > "$TEMP_TEXT_FILE"

    log_message "Starting Kokoro-TTS audio generation..."
    log_message "Executing command: ${TTS_EXECUTABLE} \"${TEMP_TEXT_FILE}\" \"${FINAL_OUTPUT_PATH}\" --voice ${VOICE}"

    # Execute the TTS command
    if ! "$TTS_EXECUTABLE" "$TEMP_TEXT_FILE" "$FINAL_OUTPUT_PATH" --voice "$VOICE"; then
        log_message "FATAL: Kokoro-TTS command failed. Check the output above for errors from the program."
        notify "Kokoro TTS Script Error" "Audio generation failed. Check log file." "dialog-error"
        rm -f "$TEMP_TEXT_FILE" # Ensure cleanup on failure
        exit 1
    fi

    # Cleanup the temp file immediately after use
    rm -f "$TEMP_TEXT_FILE"
)

# Check the exit status of the subshell
SUBSHELL_EXIT_STATUS=$?
if [ $SUBSHELL_EXIT_STATUS -ne 0 ]; then
    log_message "FATAL: The TTS generation sub-process failed with exit code ${SUBSHELL_EXIT_STATUS}."
    exit 1
fi

# Step 6: Verify output and play audio
log_message "Verifying generated audio file..."
if [ -s "$FINAL_OUTPUT_PATH" ]; then
    log_message "SUCCESS: Audio file generated successfully at '${FINAL_OUTPUT_PATH}'."
    notify "Kokoro TTS" "Audio generated: ${FINAL_OUTPUT_FILENAME}" "audio-x-generic"

    log_message "Playing audio with mpv at ${PLAYBACK_SPEED}x speed..."
    # Launching mpv with --force-window=yes to ensure a GUI player is opened.
    # The --speed flag sets the playback speed from the configuration variable.
    # The player will close automatically upon completion, which is the default behavior.
    if ! mpv --speed="${PLAYBACK_SPEED}" --force-window=yes "$FINAL_OUTPUT_PATH"; then
        log_message "WARNING: mpv playback finished with an error."
        notify "Kokoro TTS Script Warning" "mpv encountered an error during playback." "dialog-warning"
    else
        log_message "Playback finished."
    fi
else
    log_message "FATAL: Output file was not created or is empty."
    notify "Kokoro TTS Script Error" "The final audio file is missing or empty." "dialog-error"
    exit 1
fi

log_message "--- Script execution finished successfully ---"

exit 0
