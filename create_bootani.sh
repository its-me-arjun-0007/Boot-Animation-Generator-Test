#!/bin/bash

# --- CONFIGURATION (Based on your requirements) ---
WIDTH=1080
HEIGHT=2400
FPS=30
INTRO_DURATION=1.5  # 1.5 seconds (45 frames)
LOOP_DURATION=4.5   # 4.5 seconds (135 frames)
# Total duration = 6 seconds (180 frames)
# ---

# 1. Dependency Check
# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: 'ffmpeg' is not installed. Please install it first."
    echo "On Kali/Debian, run: sudo apt install ffmpeg"
    exit 1
fi
# Check for zip
if ! command -v zip &> /dev/null; then
    echo "Error: 'zip' is not installed. Please install it first."
    echo "On Kali/Debian, run: sudo apt install zip"
    exit 1
fi

# 2. Input Validation
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input_video_or_gif>"
  echo "Example: $0 my_animation.mp4"
  exit 1
fi

INPUT_FILE="$1"
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"
OUTPUT_ZIP="bootanimation.zip"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file not found at $INPUT_FILE"
  exit 1
fi

# 3. Create Project Structure
echo "Setting up project directory: $PROJECT_DIR"
rm -rf "$PROJECT_DIR" "$OUTPUT_ZIP"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 4. Define the FFmpeg Filter
# This filter chain does the following:
# 1. Sets FPS: fps=$FPS
# 2. Scales: Resizes video to fit within 1080x2400 while keeping aspect ratio.
# 3. Pads: Adds black bars to fill the 1080x2400 canvas (centers the content).
# 4. Setsar: Ensures square pixels.
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 5. Generate Intro Frames (part0)
echo "Processing Intro (part0) - 45 frames..."
ffmpeg -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: ffmpeg failed during intro (part0) processing."
    exit 1
fi

# 6. Generate Loop Frames (part1)
echo "Processing Loop (part1) - 135 frames..."
ffmpeg -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: ffmpeg failed during loop (part1) processing."
    exit 1
fi

# 7. Create desc.txt
# This file tells Android how to play the animation.
# Format: WIDTH HEIGHT FPS
#         p 1 0 part0  (Play part0 1 time, 0ms pause)
#         p 0 0 part1  (Play part1 0 times (infinite loop), 0ms pause)
echo "Generating desc.txt..."
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

# 8. Create the final bootanimation.zip
echo "Creating $OUTPUT_ZIP..."
# CRITICAL: Use compression level 0 (-0) for Android compatibility.
# We 'cd' into the directory to get the correct zip structure.
(
  cd "$PROJECT_DIR" && \
  zip -r0 "../$OUTPUT_ZIP" .
) > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "------------------------------------------------"
  echo "✅ Success! '$OUTPUT_ZIP' has been created."
  echo "You can now push this file to your device (e.g., /system/media/)."
  echo "The intermediate project folder is '$PROJECT_DIR'."
  echo "------------------------------------------------"
else
  echo "Error: Failed to create $OUTPUT_ZIP."
  exit 1
fi
