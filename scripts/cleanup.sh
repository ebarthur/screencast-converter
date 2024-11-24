#!/bin/bash

cleanup() {
    local LOCK_FILE="$1"
    log_message "Cleaning up and exiting..."
    rm -f "$LOCK_FILE"
    exit 0
}

remove_failed_output() {
    local output_file="$1"
    [ -f "$output_file" ] && rm "$output_file"
    log_message "Removed failed output: $output_file"
}

delete_original() {
    local input_file="$1"
    local DELETE_WEBM="$2"
    if [ "$DELETE_WEBM" = true ]; then
        rm "$input_file" && log_message "Deleted original WebM file: $input_file"
    fi
}
