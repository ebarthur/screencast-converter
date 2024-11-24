#!/bin/bash

log_message() {
    local message="$1"
    local log_file="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$log_file"
}

show_status() {
    local lock_file="$1"
    local log_file="$2"
    
    if [ -f "$lock_file" ]; then
        local pid
        pid=$(cat "$lock_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Screencast converter is running (PID: $pid)"
            echo "Log file location: $log_file"
            if [ -f "$log_file" ]; then
                echo "Last 5 log entries:"
                tail -n 5 "$log_file"
            else
                echo "Log file not found. Starting a new log file."
                create_directories
            fi
        else
            echo "Screencast converter is not running (stale lock file found)"
            rm -f "$lock_file"
        fi
    else
        echo "Screencast converter is not running"
    fi
}
