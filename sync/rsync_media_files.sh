#!/bin/bash

# Sync Images from Local PC to External Drive
# Usage: ./sync_images.sh <external_drive_partition_name> [dry-run]

# The main rsync command used in this script.
RSYNC_CMD="rsync -ahvc --backup --suffix=.backup"
# Verify synchronization
VERIFY_SCRIPT=~/bin/media/sync/verify_sync_fast.sh

# Exit on error
set -euo pipefail

# Function to display usage
usage() {
    echo "Usage: $0 <external_drive_partition_name> [dry-run]"
    echo "Example: $0 /media/sda3 dry-run"
    exit 1
}

# Check arguments
if [ "$#" -lt 1 ]; then
    usage
fi

EXTERNAL_PARTITION="$1"
LOCAL_DIR=~/media
REMOTE_DIR="${EXTERNAL_PARTITION}/media"
DRY_RUN=false

# Optional dry-run argument
if [ "${2:-}" == "dry-run" ]; then
    DRY_RUN=true
    echo "[x] Dry-run mode activated. No files will be copied."
fi

# Check if the external partition exists
if [ ! -d "$EXTERNAL_PARTITION" ]; then
    echo "[ERROR]: The external partition '$EXTERNAL_PARTITION' does not exist."
    exit 1
fi

if $DRY_RUN; then
    RSYNC_CMD+=" --dry-run"
fi

echo "[INFO]: Starting synchronization from '$LOCAL_DIR' to '$REMOTE_DIR'..."
echo "[INFO]: Using rsync command: $RSYNC_CMD"

echo + $RSYNC_CMD "$LOCAL_DIR/" "$REMOTE_DIR/"
$RSYNC_CMD "$LOCAL_DIR/" "$REMOTE_DIR/"

if [ -x "$VERIFY_SCRIPT" ]; then
    echo "[INFO]: Running verification script..."
    echo bash "$VERIFY_SCRIPT" "$LOCAL_DIR" "$REMOTE_DIR"
else
    echo "Warning: Verification script '$VERIFY_SCRIPT' not found or not executable."
    echo "Please ensure synchronization integrity manually."
fi

if ! $DRY_RUN; then
    if [ -x "$VERIFY_SCRIPT" ]; then
        echo "[INFO]: Running verification script..."
        bash "$VERIFY_SCRIPT" "$LOCAL_DIR" "$REMOTE_DIR"
    else
        echo "Warning: Verification script '$VERIFY_SCRIPT' not found or not executable."
        echo "Please ensure synchronization integrity manually."
    fi
else
    echo "Dry-run mode: Verification skipped."
fi



echo "Synchronization completed successfully."

################
# NOTES
################
# --backup/--suffix - Keep a backup of the existing file
# in the destination folder before it is overwritten,
# you can use the --backup option along with --suffix
# to specify a suffix for the backup file.
# 
# Notice, if a file have same checksum, we do not create backup.
# Backup is only created when filename is equal and the content is different
#
# THIS IS THE ORIGINAL COMMAND USED IN THE PAST:
# $ rsync -ahvc --backup --suffix=.backup ~/media/ /mnt/icybox3/media/ && bash ~/bin/media/sync/verify_sync_fast.sh ~/media /mnt/icybox3/media


