#!/bin/bash
#
#   This script verifies the integrity of files synced
#   from a source directory to a destination directory.
#
#   It checks for three potential issues:
#   1. Missing files.......:  Files present in the source but not
#                             found in the destination.
#   2. Size mismatch.......:  Differences in file size between the
#                             source and destination files.
#   3. Modify time mismatch:  Differences in the last modification
#                             times between source and destination files.
#
# If any error were found, they will be printed to stdout.

source_dir=$1; shift
dest_dir=$1; shift

source_files=$(mktemp)

cd $source_dir
find . -type f > $source_files

# Get the total number of files for progress tracking
total_files=$(wc -l < "$source_files")
current_file=0
last_reported_progress=-1

# Calculate the number of digits in total_files for formatting
total_files_digits=${#total_files}

error_track_file=$(mktemp)

while read -r file; do
  # Increment file counter and calculate progress
  ((current_file++))
  progress=$((current_file * 100 / total_files))

  file=${file#./}
  src="${source_dir}/${file}"
  dst="${dest_dir}/${file}"

  if (( progress > last_reported_progress )); then
 	  printf "Current progress: [%3d%%] (%*d / %d)\n" $progress $total_files_digits $current_file $total_files

      #echo "Current progress: [$progress%] ($current_file/$total_files)"
      last_reported_progress=$progress
  fi

  # Check if the file exists in the destination
  if [ ! -f "$dst" ]; then
      echo "Missing: $file" >> $error_track_file
      continue
  fi
  
  # Compare file sizes
  if [ $(stat -c%s "$src") -ne $(stat -c%s "$dst") ]; then
      echo "Size mismatch: $file" >> $error_track_file
      continue
  fi

  # Compare modification times
  if [ $(stat -c%Y "$src") -ne $(stat -c%Y "$dst") ]; then
      echo "Modification time mismatch: $file" >> $error_track_file
      continue
  fi 

done < $source_files

echo "Errors found:"
cat $error_track_file

echo "Error count:"
cat $error_track_file | wc -l

echo "Verification complete."
