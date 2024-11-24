#!/bin/bash

source ./scripts/cleanup.sh
source ./scripts/check_dependencies.sh
source ./scripts/disk_space.sh
source ./scripts/logging.sh
source ./scripts/conversion.sh
source ./scripts/notifications.sh

# Configuration (Always verify what a config does before you make a change)
WATCH_DIR="$HOME/Videos/Screencasts"
OUTPUT_DIR="$HOME/Videos/converted"
DELETE_WEBM=true
LOG_DIR="$HOME/.local/share/screencast-converter"
LOG_FILE="$LOG_DIR/converter.log"
LOCK_FILE="/tmp/screencast-converter.lock"
WAIT_TIME=3
CHECK_COUNT=3
MAX_WAIT_TIME=7200
FFMPEG_PRESET="medium"
FFMPEG_CRF=23
FFMPEG_AUDIO_BITRATE="128k"

# Process name for easy identification
export PROC_NAME="screencast-converter"
ps -p $$ -o comm= > /dev/null 2>&1
if [ $? -eq 0 ]; then
    export PS1="$PROC_NAME"
fi

# Trap signals
trap "cleanup $LOCK_FILE" SIGTERM SIGINT

# Main logic
case "$1" in
    status)
        show_status "$LOCK_FILE" "$LOG_FILE"
        exit 0
        ;;
    start)
        if [ -f "$LOCK_FILE" ] && kill -0 $(cat "$LOCK_FILE") 2>/dev/null; then
            echo "Screencast converter is already running"
            exit 1
        fi
        check_dependencies
        check_notification_support "$LOG_FILE"
        create_directories "$OUTPUT_DIR" "$LOG_DIR" "$LOG_FILE"
        ;;
    stop)
        if [ -f "$LOCK_FILE" ]; then
            pid=$(cat "$LOCK_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                log_message "Stopping screencast converter (PID: $pid)" "$LOG_FILE"
                kill "$pid"
                rm -f "$LOCK_FILE"
                echo "Stopped screencast converter"
            else
                echo "Screencast converter is not running (removing stale lock file)"
                rm -f "$LOCK_FILE"
            fi
        else
            echo "Screencast converter is not running"
        fi
        exit 0
        ;;
    *)
        check_dependencies
        create_directories "$OUTPUT_DIR" "$LOG_DIR" "$LOG_FILE"
        ;;
esac

# Log startup
log_message "Starting screencast converter service" "$LOG_FILE"
log_message "Watching directory: $WATCH_DIR" "$LOG_FILE"
log_message "Output directory: $OUTPUT_DIR" "$LOG_FILE"
log_message "WebM deletion: $DELETE_WEBM" "$LOG_FILE"
log_message "File completion check interval: ${WAIT_TIME}s" "$LOG_FILE"
log_message "Required stable checks: $CHECK_COUNT" "$LOG_FILE"
log_message "Maximum wait time: $MAX_WAIT_TIME seconds" "$LOG_FILE"
log_message "FFMPEG settings: preset=$FFMPEG_PRESET, crf=$FFMPEG_CRF, audio_bitrate=$FFMPEG_AUDIO_BITRATE" "$LOG_FILE"

# Monitor directory for new files
inotifywait -m "$WATCH_DIR" -e close_write -e moved_to |
while read -r directory event filename; do
    if [[ "$filename" =~ .*\.webm$ ]]; then
        input_file="$directory$filename"
        
        if [ -s "$input_file" ]; then
            log_message "New screencast detected: $filename" "$LOG_FILE"
            
            if is_file_complete "$input_file" "$WAIT_TIME" "$CHECK_COUNT" "$MAX_WAIT_TIME" "$LOG_FILE"; then
                convert_to_mp4 "$input_file" "$OUTPUT_DIR" "$FFMPEG_PRESET" "$FFMPEG_CRF" \
                              "$FFMPEG_AUDIO_BITRATE" "$DELETE_WEBM" "$LOG_FILE"
            else
                log_message "Recording was interrupted or file was deleted: $filename" "$LOG_FILE"
            fi
        fi
    fi
done