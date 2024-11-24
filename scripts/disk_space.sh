#!/bin/bash

check_disk_space() {
    local required_space="$1"  # in MB
    local output_dir="$2"
    local available_space
    
    available_space=$(df -m "$output_dir" | awk 'NR==2 {print $4}')
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_message "ERROR: Insufficient disk space. Available: ${available_space}MB, Required: ${required_space}MB"
        return 1
    fi
    return 0
}

create_directories() {
    local output_dir="$1"
    local log_dir="$2"
    local log_file="$3"
    
    for dir in "$output_dir" "$log_dir"; do
        if ! mkdir -p "$dir"; then
            echo "Error: Failed to create directory: $dir"
            exit 1
        fi
    done
    
    touch "$log_file" || {
        echo "Error: Failed to create log file: $log_file"
        exit 1
    }
    
    chmod 755 "$log_dir"
    chmod 644 "$log_file"
}