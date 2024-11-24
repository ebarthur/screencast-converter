# Screencast WebM to MP4 Auto-Converter (Linux)

This script automatically monitors your screen recordings in WebM format, converts them to MP4 using **FFmpeg**, and optionally deletes the original WebM files. It efficiently handles file stabilization checks to ensure that the conversion only occurs once the recording is fully completed.

## Features

- **Automatic WebM to MP4 conversion**
- **Optional deletion of source WebM files after conversion**
- **Process management** (start, stop, status)
- **Detailed logging** of all actions
- **Single instance enforcement** (only one script can run at a time)
- **FFmpeg high-quality conversion settings**
- **File completion checks** to avoid partial conversions

## Prerequisites

Before using this script, make sure the following packages are installed:

- **FFmpeg**: For converting WebM files to MP4.
- **inotify-tools**: For monitoring the file system for changes.

### Install Dependencies (Not necessary)

Run the following command to install the required tools on a Debian-based system (e.g., Ubuntu):

```bash
sudo apt-get install inotify-tools ffmpeg
```

For other distributions, use the respective package manager to install `ffmpeg` and `inotify-tools`.

## Installation

1. **Clone or Download the Repository**:

   Clone the repository or download the script to a directory of your choice.

   ```bash
   git clone https://github.com/ebarthur/screencast-converter.git
   cd webm-converter
   ```

2. **Make the Script Executable**:

   Change the permissions of the script to make it executable:

   ```bash
   chmod +x scripts/*.sh
   chmod +x ./main.sh
   ```

## Usage

- `My setup:` Ubuntu 24.04.1 LTS
- Let me know when you have issues

### Basic Commands

- **Start the converter**:  
  Starts the screencast converter and begins monitoring the specified directory for new WebM files.

  ```bash
  ./main.sh start
  ```

- **Check the status**:  
  Displays the current status of the converter, including whether it's running, the process ID, and recent log entries.

  ```bash
  ./main.sh status
  ```

- **Stop the converter**:  
  Stops the currently running converter instance.

  ```bash
  ./main.sh stop
  ```

### Monitoring the Service

You can monitor the service and its logs in the following ways:

1. **Using the status command**:

   ```bash
   ./main.sh status
   ```

   This shows:

   - Whether the service is running
   - Process ID (PID)
   - Log file location
   - Last 5 log entries

2. **Viewing the logs**:

   You can continuously view the log file using `tail`:

   ```bash
   tail -f ~/.local/share/screencast-converter/converter.log
   ```

3. **Checking the process**:

   Use the `ps` command to check if the script is running:

   ```bash
   ps aux | grep screencast-converter
   ```

### Auto-start on Login

To automatically start the script when you log in:

1. Open your desktop environment’s **Startup Applications** settings.
2. Add a new startup entry:
   - **Name**: Screencast Converter
   - **Command**: `/path/to/screencast-converter.sh start`
   - **Comment**: Automatically converts screencasts from WebM to MP4.

## Configuration

The script can be customized by modifying the following configuration variables in the script file:

```bash
WATCH_DIR="$HOME/Videos/Screencasts"  # Directory to watch for new WebM files
OUTPUT_DIR="$HOME/Videos/converted"  # Directory to save the converted MP4 files
DELETE_WEBM=true  # Set to false to keep original WebM files
LOG_FILE="$HOME/.local/share/screencast-converter/converter.log"  # Log file path
MAX_WAIT_TIME=1800  # Maximum time to wait for a file to stabilize (in seconds)
WAIT_TIME=5  # Time between stability checks (in seconds)
CHECK_COUNT=2  # Number of stable checks required before starting conversion
FFMPEG_PRESET="medium"  # FFmpeg preset for conversion
FFMPEG_CRF=23  # FFmpeg CRF for quality control
FFMPEG_AUDIO_BITRATE="128k"  # Audio bitrate for FFmpeg conversion
```

### Directory Structure

- **Watch Directory**: Where new WebM files are detected.
- **Output Directory**: Where converted MP4 files are saved.
- **Log Directory**: Where the log file is stored.

### WebM File Deletion

By default, the script deletes the original WebM files after successful conversion. To keep the WebM files:

1. Open the script in a text editor.
2. Change `DELETE_WEBM=true` to `DELETE_WEBM=false`.

## Log Files

The script logs its actions to the following log file:

```
~/.local/share/screencast-converter/converter.log
```

Logs include:

- Service start/stop events
- Detection of new WebM files
- Conversion status (success or failure)
- Errors and warnings
- File deletions (if enabled)

## How It Works

1. The script monitors the **WATCH_DIR** for new WebM files using `inotifywait`.
2. When a new WebM file is detected, it waits for the file to stabilize (size stops changing).
3. Once the file is stable, the script converts it to MP4 using FFmpeg.
4. The MP4 file is saved in the **OUTPUT_DIR**.
5. If enabled, the original WebM file is deleted after conversion.
6. All actions and events are logged for troubleshooting.

## FFmpeg Conversion Settings

The script uses the following FFmpeg settings for video conversion:

- **Video codec**: `libx264`
- **Preset**: `medium` (balance between speed and quality)
- **CRF**: `23` (a good balance between quality and file size; lower values increase quality)
- **Audio codec**: `AAC`
- **Audio bitrate**: `128k` (good quality for most audio)

## Troubleshooting

If the script isn't working as expected:

1. **Check Service Status**:

   ```bash
   ./main.sh status
   ```

2. **View Log Files**:

   ```bash
   tail -f ~/.local/share/screencast-converter/converter.log
   ```

3. **Verify Prerequisites**:

   - Ensure `inotify-tools` and `ffmpeg` are installed(Not necessary).
   - Make sure the script has executable permissions.
   - Check that all directories exist.

4. **Common Issues**:
   - If WebM files aren't being deleted, check the `DELETE_WEBM` setting.
   - If the script doesn't start, ensure no other instance is running (use `ps aux` or check the lock file).

## Suggestions

FYI, I made this one Sunday morning in my university dorm to solve a problem I was facing

**Possible Add-ons** - Add loading or progress bar to the system tray to show users conversion status - Make it a lot easier to install and configure

## Credits

- **FFmpeg**: The script uses [FFmpeg](https://ffmpeg.org/), a powerful multimedia processing tool, to convert WebM files to MP4. FFmpeg is licensed under the LGPL or GPL, depending on the configuration.
- **inotify-tools**: The script uses [inotify-tools](https://github.com/inotify-tools/inotify-tools), a set of command-line programs for Linux that provides a simple interface to `inotify`, a Linux kernel subsystem that provides file system event monitoring.

## License

This script is released under the MIT License. Feel free to modify and distribute it.

## Support

If you encounter any issues:

1. Check the troubleshooting section above.
2. Review the log files.
3. Ensure all prerequisites are installed.
4. Verify your configuration settings.
