#!/bin/bash

# --- CONFIGURATION (Based on your requirements) ---
WIDTH=1080
HEIGHT=2400
FPS=30
INTRO_DURATION=1.5  # 1.5 seconds (45 frames)
LOOP_DURATION=4.5   # 4.5 seconds (135 frames)

# Total duration = 6 seconds (180 frames)
# ---

# 1. Input Validation
if [ -z "$1" ]; then
  echo "Usage: $0 <input_video_or_gif>"
  echo "Example: $0 my_animation.mp4"
  exit 1
fi

INPUT_FILE="$1"
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file not found at $INPUT_FILE"
  exit 1
fi

# 2. Create Project Structure
echo "Setting up project directory: $PROJECT_DIR"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 3. Define the FFmpeg Filter
# This filter chain does the following:
# 1. Sets FPS: fps=$FPS
# 2. Scales: Resizes video to fit within 1080x2400 while keeping aspect ratio.
# 3. Pads: Adds black bars to fill the 1080x2400 canvas (centers the content).
# 4. Setsar: Ensures square pixels.
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 4. Generate Intro Frames (part0)
echo "Processing Intro (part0) - 45 frames..."
ffmpeg -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

# 5. Generate Loop Frames (part1)
# Note: We seek to 1.5s into the *input* file to get the loop content.
# The output file numbering will restart from 'frame_0000.png',
# which is the correct behavior for the part1 loop.
echo "Processing Loop (part1) - 135 frames..."
ffmpeg -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 6. Create desc.txt
# This file tells Android how to play the animation.
# Format: WIDTH HEIGHT FPS
#         p 1 0 part0  (Play part0 1 time, 0ms pause)
#         p 0 0 part1  (Play part1 0 times (infinite loop), 0ms pause)
echo "Generating desc.txt..."
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo "------------------------------------------------"
echo "✅ Success! Project created at '$PROJECT_DIR'"
echo "Intro frames: $(ls -1q "$PART0_DIR" | wc -l)"
echo "Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)"
echo "------------------------------------------------"
