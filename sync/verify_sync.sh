
source_dir=/home/thorgeir/media
dest_dir=/mnt/icybox2/media

source_files=$(mktemp)

cd $source_dir
find . -type f > $source_files

# Get the total number of files for progress tracking
total_files=$(wc -l < "$source_files")
current_file=0

error_track_file=$(mktemp)

while read -r file; do
  # Increment file counter and calculate progress
  ((current_file++))
  progress=$((current_file * 100 / total_files))

  file=${file#./}
  src="${source_dir}/${file}"
  dst="${dest_dir}/${file}"

  echo "[$progress%] Verifying: $file"

  # Check if the file exists in the destination
  if [ ! -f "$dst" ]; then
      echo "Missing: $file" >> $error_track_file
      continue
  fi

  # Optionally, compare checksums (md5sum) of src and dst
  if [ "$(md5sum "$src" | cut -d' ' -f1)" != "$(md5sum "$dst" | cut -d' ' -f1)" ]; then
      echo "Checksum mismatch: $file" >> $error_track_file
  fi
done < $source_files

echo "Errors found:"
cat $error_track_file

echo "Error count:"
cat $error_track_file | wc -l

echo "Verification complete."
