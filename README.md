# Screencast WebM to MP4 Auto-Converter

This modular Bash script system automates the conversion of WebM screen recordings to MP4 format using FFmpeg. It monitors a specific directory for new WebM files, converts them once the recording is complete, and optionally deletes the original WebM files.

## Key Features

- **Modular Design**  
  Organized into separate modules for better maintainability and clarity:

  - `cleanup.sh`: Handles cleanup operations and file removal
  - `check_dependencies.sh`: Manages dependency checking
  - `disk_space.sh`: Handles disk space management
  - `logging.sh`: Contains logging and status reporting functions
  - `conversion.sh`: Manages file conversion and completion checking
  - `main.sh`: Main script that coordinates all modules

- **Automated WebM to MP4 conversion**  
  Detects new WebM recordings and converts them to MP4 with high-quality FFmpeg settings.

- **Original file management**  
  Option to automatically delete WebM files after successful conversion.

- **Single instance enforcement**  
  Prevents multiple instances of the script from running simultaneously.

- **Logging**  
  Maintains detailed logs for all operations (file events, conversions, errors).

- **Service management**  
  Allows starting, stopping, and checking the status of the converter service.

## Prerequisites

Ensure the following tools are installed:

```bash
sudo apt-get install inotify-tools ffmpeg
```

## Installation and Setup

1. Clone or download all script files to a directory of your choice:

   - `main.sh`
   - `cleanup.sh`
   - `check_dependencies.sh`
   - `disk_space.sh`
   - `logging.sh`
   - `conversion.sh`

2. Make all scripts executable:

   ```bash
   chmod +x *.sh
   ```

3. Edit the configuration section in `main.sh` if necessary:

   - **`WATCH_DIR`**: Directory where new WebM files are recorded
   - **`OUTPUT_DIR`**: Directory where converted MP4 files will be saved
   - **`DELETE_WEBM`**: Set to `true` to delete WebM files after conversion or `false` to keep them

4. Create the required directories:
   ```bash
   mkdir -p ~/Videos/Screencasts ~/Videos/converted ~/.local/share/screencast-converter
   ```

## Usage

### Commands

- **Start the service:**

  ```bash
  ./main.sh start
  ```

- **Check service status:**

  ```bash
  ./main.sh status
  ```

- **Stop the service:**
  ```bash
  ./main.sh stop
  ```

## Auto-Start on Login

To enable the script to run at login:

1. Open your desktop environment's **Startup Applications** settings
2. Add a new entry with the following details:
   - **Name:** Screencast Converter
   - **Command:** `/path/to/main.sh start`
   - **Comment:** Automatically converts WebM screencasts to MP4

## Configuration

### Default Settings

- **Watched Directory:** `~/Videos/Screencasts`
- **Output Directory:** `~/Videos/converted`
- **Delete WebM Files:** `true`
- **Log Directory:** `~/.local/share/screencast-converter`
- **Log File:** `~/.local/share/screencast-converter/converter.log`

### Adjusting Conversion Quality

The script uses the following FFmpeg settings for conversion:

- **Video Codec:** `libx264`
- **Preset:** `medium` (balanced between speed and quality)
- **CRF:** `23` (lower values mean better quality but larger file sizes)
- **Audio Codec:** `aac`
- **Audio Bitrate:** `128k`

To modify these, edit the corresponding variables at the top of `main.sh`:

- `FFMPEG_PRESET`
- `FFMPEG_CRF`
- `FFMPEG_AUDIO_BITRATE`

## Monitoring the Script

### View Recent Logs

```bash
tail -f ~/.local/share/screencast-converter/converter.log
```

### Check Running Processes

```bash
ps aux | grep screencast-converter
```

## Module Descriptions

### cleanup.sh

- Handles cleanup operations
- Manages file removal and cleanup on exit
- Handles removal of failed conversions

### check_dependencies.sh

- Verifies required system dependencies
- Checks for ffmpeg and inotify-tools
- Provides helpful installation messages

### disk_space.sh

- Manages disk space checking
- Creates necessary directories
- Ensures sufficient space for conversions

### logging.sh

- Manages all logging operations
- Provides status reporting functions
- Maintains detailed operation logs

### conversion.sh

- Handles WebM to MP4 conversion
- Manages file completion checking
- Controls conversion quality settings

### main.sh

- Coordinates all modules
- Manages configuration settings
- Handles service control (start/stop/status)

## Troubleshooting

### Common Issues

- **Missing Dependencies:**  
  Verify that both `inotify-tools` and `ffmpeg` are installed:

  ```bash
  sudo apt-get install inotify-tools ffmpeg
  ```

- **Service Not Starting:**  
  Check for stale lock files in `/tmp/screencast-converter.lock`. If present, delete them manually.

- **No Output Files:**  
  Verify the available disk space and ensure the `OUTPUT_DIR` is writable.

- **Logs Not Updating:**  
  Ensure the log directory and file exist and have correct permissions.

## Contribution

Enhance the script by:

- Adding new features (e.g., support for other formats)
- Integrating system notifications
- Improving error handling or logging mechanisms
- Adding new modules for additional functionality

Feel free to fork and customize it as per your requirements.

## License

This script is released under the **MIT License**. Modify and distribute freely.
