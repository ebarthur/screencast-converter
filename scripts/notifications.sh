#!/bin/bash

# Check if notify-send is available
check_notification_support() {
    if ! command -v notify-send &> /dev/null; then
        log_message "notify-send not found. Installing libnotify-bin..." "$1"
        sudo apt-get install -y libnotify-bin || {
            log_message "Failed to install libnotify-bin. Notifications will be disabled." "$1"
            return 1
        }
    fi
    return 0
}

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # default to normal urgency
    local duration="${4:-5000}"   # default to 5 seconds
    
    if command -v notify-send &> /dev/null; then
        notify-send --app-name="WebM Converter" \
                   --urgency="$urgency" \
                   --expire-time="$duration" \
                   "$title" "$message"
    fi
}
