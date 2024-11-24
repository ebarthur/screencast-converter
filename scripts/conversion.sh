#!/bin/bash

convert_to_mp4() {
    local input_file="$1"
    local output_dir="$2"
    local ffmpeg_preset="$3"
    local ffmpeg_crf="$4"
    local ffmpeg_audio_bitrate="$5"
    local delete_webm="$6"
    local log_file="$7"
    
    local filename
    filename=$(basename "$input_file" .webm)
    local output_file="$output_dir/${filename}.mp4"
    
    # Check input file exists and is readable
    if [ ! -r "$input_file" ]; then
        log_message "Error: Cannot read input file: $input_file" "$log_file"
        send_notification "Conversion Error" "Cannot read input file: $filename" "critical"
        return 1
    fi
    
    # Notify user that conversion is starting
    send_notification "Converting Screencast" "Starting conversion of $filename" "normal"
    
    # Estimate required disk space (input file size * 1.5 for safety)
    local input_size
    input_size=$(($(stat -c%s "$input_file") / 1024 / 1024 * 3 / 2))
    
    if ! check_disk_space "$input_size" "$output_dir"; then
        send_notification "Conversion Error" "Insufficient disk space for converting $filename" "critical"
        return 1
    fi
    
    log_message "Starting conversion: $input_file" "$log_file"
    log_message "Using ffmpeg preset: $ffmpeg_preset, CRF: $ffmpeg_crf" "$log_file"
    
    # Convert using ffmpeg with high quality settings
    if ffmpeg -i "$input_file" \
        -c:v libx264 -preset "$ffmpeg_preset" -crf "$ffmpeg_crf" \
        -c:a aac -b:a "$ffmpeg_audio_bitrate" \
        -progress pipe:1 \
        "$output_file" 2>> "$log_file"; then
        
        log_message "Converted successfully: $input_file -> $output_file" "$log_file"
        
        # Verify output file exists and has size > 0
        if [ -s "$output_file" ]; then
            if [ "$delete_webm" = true ]; then
                delete_original "$input_file" "$delete_webm"
            fi
            # Notify user of successful conversion
            send_notification "Conversion Complete" "Successfully converted $filename to MP4" "normal" 10000
        else
            log_message "Error: Output file is empty or missing: $output_file" "$log_file"
            send_notification "Conversion Error" "Failed to convert $filename - Output file is empty" "critical"
            remove_failed_output "$output_file"
            return 1
        fi
    else
        log_message "Error converting $input_file" "$log_file"
        send_notification "Conversion Error" "Failed to convert $filename" "critical"
        remove_failed_output "$output_file"
        return 1
    fi
}

is_file_complete() {
    local file="$1"
    local wait_time="$2"
    local check_count="$3"
    local max_wait_time="$4"
    local log_file="$5"
    
    local last_size=0
    local current_size=0
    local stable_count=0
    local total_wait=0
    local filename
    filename=$(basename "$file")
    
    log_message "Waiting for recording to complete: $file" "$log_file"
    send_notification "Preparing Recording" "Waiting for $filename to complete..." "low"
    
    while [ $total_wait -lt $max_wait_time ]; do
        if [ ! -f "$file" ]; then
            log_message "File no longer exists: $file" "$log_file"
            send_notification "Recording Error" "$filename no longer exists" "critical"
            return 1
        fi
        
        current_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        
        if [ "$current_size" = "$last_size" ] && [ "$current_size" -gt 0 ]; then
            stable_count=$((stable_count + 1))
            
            if [ $stable_count -ge $check_count ]; then
                log_message "Recording complete after $total_wait seconds" "$log_file"
                return 0
            fi
        else
            stable_count=0
        fi
        
        last_size=$current_size
        sleep "$wait_time"
        total_wait=$((total_wait + wait_time))
        
        # Notify user every minute if still waiting
        if [ $((total_wait % 60)) -eq 0 ]; then
            log_message "Still waiting for recording to complete... ($total_wait seconds elapsed)" "$log_file"
            send_notification "Still Preparing" "Still waiting for $filename to complete... ($total_wait seconds)" "low"
        fi
    done
    
    log_message "WARNING: Recording exceeded maximum wait time of $max_wait_time seconds" "$log_file"
    send_notification "Recording Timeout" "$filename exceeded maximum wait time" "critical"
    return 1
}
