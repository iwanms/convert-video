#!/bin/bash

# Cek argumen path
if [ -z "$1" ]; then
    echo "❌ Pemakaian: $0 /path/to/folder"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$INPUT_DIR/converted"

mkdir -p "$OUTPUT_DIR"

# Ekstensi video yang mau dicek
EXTENSIONS=("mp4" "mkv" "avi" "mov" "flv" "wmv")

for ext in "${EXTENSIONS[@]}"; do
    for file in "$INPUT_DIR"/*."$ext"; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        output="$OUTPUT_DIR/${filename%.*}.mp4"

        echo "🎬 Mengonversi: $file -> $output"

        ffmpeg -y -i "$file" \
          -c:v libx264 -profile:v main -level 4.0 -preset fast -crf 23 \
          -c:a libmp3lame -b:a 192k \
          -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease,fps=30" \
          "$output"
    done
done

echo "✅ Semua video sudah diproses ke folder: $OUTPUT_DIR"

