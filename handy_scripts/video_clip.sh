#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found, please install it."
    exit 1
fi

# Function to extract a segment from a video
extract_segment() {
    local input_file=$1
    local start_time=$2
    local end_time=$3
    local output_file=$4

    ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -c copy "$output_file"
}

# Clear previous list file
echo "" > videos.txt

# Extract segments from DJI_0595.MP4
extract_segment "DJI_0595.MP4" "00:00:48" "00:01:16" "DJI_0595_part.mp4"
echo "file 'DJI_0595_part.mp4'" >> videos.txt

# Extract segments from DJI_0598.MP4
extract_segment "DJI_0598.MP4" "00:00:11" "00:00:18" "DJI_0598_part.mp4"
echo "file 'DJI_0598_part.mp4'" >> videos.txt

# Extract segments from DJI_0599.MP4
extract_segment "DJI_0599.MP4" "00:00:39" "00:00:43" "DJI_0599_part1.mp4"
echo "file 'DJI_0599_part1.mp4'" >> videos.txt
extract_segment "DJI_0599.MP4" "00:04:59" "00:05:09" "DJI_0599_part2.mp4"
echo "file 'DJI_0599_part2.mp4'" >> videos.txt
extract_segment "DJI_0599.MP4" "00:07:39" "00:07:46" "DJI_0599_part3.mp4"
echo "file 'DJI_0599_part3.mp4'" >> videos.txt

# Concatenate all parts
ffmpeg -f concat -safe 0 -i videos.txt -c copy output_video.mp4

# Cleanup
rm DJI_0595_part.mp4 DJI_0598_part.mp4 DJI_0599_part1.mp4 DJI_0599_part2.mp4 DJI_0599_part3.mp4 videos.txt

echo "Video concatenation complete. Output file: output_video.mp4"
