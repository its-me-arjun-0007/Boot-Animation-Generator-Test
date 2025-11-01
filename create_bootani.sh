#!/bin/bash

# --- 0. Clear the terminal screen ---
clear

# --- 1. Color Definitions ---
# Using the ANSI escape codes you provided for seamless integration:
BLUE=$'\e[1;34m'
YELLOW=$'\e[1;33m'
GREEN=$'\e[0;32m'
LIGHTGREEN=$'\e[1;32m'
RED=$'\e[1;31m'
CYAN=$'\e[0;36m'
LIGHTCYAN=$'\e[96m'
WHITE=$'\e[1;37m'
NC=$'\e[0m' # No Color (Reset)

# --- 2. Summary ---


echo    .--------------------------------------------------------------------------------.
echo    |  _______ _______ _______ _______ _______ _______ _______ _______ _______       |                                                                             |
echo    |                                                                                |
echo    |                A N D R O I D     B O O T     A N I M A T I O N                 |
echo    |                                                                                |
echo    |                               G E N E R A T O R                                |
echo    |  _______ _______ _______ _______ _______ _______ _______ _______ _______       |
echo    |                                                                                |
echo -e |                   "${WHITE}CREATED BY IT'S ME ARJUN${NC}"                      |
echo -e |  "${BLUE}GITHUB  : https://github.com/its-me-arjun-0007${NC}"                  |
echo -e |  "${LIGHTCYAN}INSTAGRAM : https://www.instagram.com/its_me_arjun_2255${NC}"    |
echo -e |                                                                                |
echo    '--------------------------------------------------------------------------------'
echo
echo -e "${WHITE}A Bash script to convert any video/GIF into a formatted Android bootanimation.zip.${NC}"
echo -e "${YELLOW}LEGAL DISCLAIMER${NC}"
echo -e "${WHITE}USE AT YOUR OWN RISK. This tool is for educational and personal use only.${NC}"
echo -e "${WHITE}Modifying system files can be risky. The creator is not responsible for any damage.${NC}"
echo -e "${WHITE}Always back up your data and original bootanimation.zip before proceeding.${NC}"


# --- 3. Function to select FPS ---
select_fps() {
    echo -e "\n${BLUE}Please select a frame rate (FPS):${NC}"
    options=("15" "25" "30")
    # Set the prompt for the 'select' menu
    echo -e "\n${YELLOW}Choice: ${NC}"
    
    select opt in "${options[@]}"; do
        if [[ " ${options[@]} " =~ " ${opt} " ]]; then
            FPS=$opt
            echo -e "✅ ${GREEN}FPS set to $FPS.${NC}"
            break
        else
            echo -e "❌ ${RED}Invalid option $REPLY. Please select 1, 2, or 3.${NC}"
        fi
    done
}

# --- 4. Function to get Resolution (Aspect Ratio) ---
get_resolution() {
    echo -e "\n${BLUE}Please enter the target resolution (this defines the aspect ratio).${NC}"
    while true; do
        read -p $'\n'"${YELLOW}Enter target WIDTH (e.g., 1080): ${NC}" WIDTH
        if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 1080).${NC}"
            continue
        fi
        
        read -p "${YELLOW}Enter target HEIGHT (e.g., 2400): ${NC}" HEIGHT
        if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 2400).${NC}"
            continue
        fi
        
        echo -e "✅ ${GREEN}Resolution set to ${WIDTH}x${HEIGHT}.${NC}"
        break
    done
}

# --- 5. Function to get the input file ---
get_input_file() {
    echo -e "\n${BLUE}Please provide the source video or GIF.${NC}"
    while true; do
        read -p $'\n'"${YELLOW}Enter the path to your file: ${NC}" INPUT_FILE
        
        if [ ! -f "$INPUT_FILE" ]; then
            echo -e "❌ ${RED}Error: File not found at '$INPUT_FILE'. Please try again.${NC}"
        else
            echo -e "✅ ${GREEN}Using file: $INPUT_FILE${NC}"
            break
        fi
    done
}


# --- 6. CONFIGURATION (Interactive) ---
select_fps
get_resolution
get_input_file

# These durations are still hardcoded.
INTRO_DURATION=1.5  # 1.5 seconds
LOOP_DURATION=4.5   # 4.5 seconds
# ---

# 7. Define Project Variables & Structure
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

echo -e "\n${CYAN}Setting up project directory: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# --- 9. Generate Frames ---

# First, get the total duration of the input file using ffprobe
echo -e "${CYAN}Analyzing video duration...${NC}"
TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

# Check if the video is long enough for the intro
if (( $(echo "$TOTAL_DURATION < $INTRO_DURATION" | bc -l) )); then
    echo -e "❌ ${RED}Error: Input video is shorter than the intro duration ($INTRO_DURATION seconds).${NC}"
    exit 1
fi

# Dynamically calculate the loop duration
# It's the total duration minus the intro duration
LOOP_DURATION=$(echo "$TOTAL_DURATION - $INTRO_DURATION" | bc)

echo -e "✅ ${GREEN}Video duration is ${TOTAL_DURATION}s. Using ${LOOP_DURATION}s for the loop part.${NC}"

echo -e "${CYAN}Processing Intro (part0)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

echo -e "${CYAN}Processing Loop (part1)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 10. Create desc.txt
echo -e "${CYAN}Generating desc.txt...${NC}"
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "✅ ${LIGHTGREEN}Success! Project created at '$PROJECT_DIR'${NC}"
echo -e "${WHITE}Resolution: $WIDTH x $HEIGHT @ $FPS fps${NC}"
echo -e "${WHITE}Intro frames: $(ls -1q "$PART0_DIR" | wc -l)${NC}"
echo -e "${WHITE}Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"


# --- 11. (NEW FEATURE) Create ZIP file ---
echo
echo -e "${BLUE}Would you like to create the final bootanimation.zip file? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" zip_choice

if [[ "$zip_choice" == "y" || "$zip_choice" == "Y" ]]; then
  echo -e "${CYAN}Creating bootanimation.zip...${NC}"
  
  # Check if zip is installed
  if ! command -v zip &> /dev/null; then
      echo -e "❌ ${RED}Error: 'zip' is not found. Please install it (e.g., sudo apt install zip).${NC}"
  else
      # Go into the directory to create the zip with the correct paths
      cd "$PROJECT_DIR"
      
      # Use -0 (store only, NO compression) and -r (recursive)
      # -q (quiet) to suppress zip's own output
      # We create the zip in the parent directory (../)
      zip -0qr ../bootanimation.zip part0 part1 desc.txt
      
      # Go back to the original directory
      cd ..
      
      if [ -f "bootanimation.zip" ]; then
          echo -e "✅ ${LIGHTGREEN}Successfully created 'bootanimation.zip' in the current directory!${NC}"
      else
          echo -e "❌ ${RED}Error: Failed to create zip file.${NC}"
      fi
  fi
fi


# --- 12. Integrated Full-Screen Preview ---
echo
echo -e "${BLUE}Would you like to preview the animation? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" preview_choice

if [[ "$preview_choice" == "y" || "$preview_choice" == "Y" ]]; then
  echo -e "${CYAN}Generating preview... Press 'q' or 'ESC' to quit full-screen.${NC}"
  
  if ! command -v ffplay &> /dev/null; then
      echo -e "❌ ${RED}Error: ffplay is not found. Please install ffmpeg to use the preview.${NC}"
      exit 1
  fi
  
  ffplay -autoexit -fs -framerate $FPS -i "$PART0_DIR/frame_%04d.png" && \
  ffplay -fs -framerate $FPS -loop 0 -i "$PART1_DIR/frame_%04d.png"

  echo -e "${CYAN}Preview finished.${NC}"
fi
# --- End of Script ---get_resolution() {
    echo
    echo "Please enter the target resolution (this defines the aspect ratio)."
    while true; do
        read -p "Enter target WIDTH (e.g., 1080): " WIDTH
        # Validate that input is a positive number
        if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
            echo "Invalid input. Please enter a number (e.g., 1080)."
            continue
        fi
        
        read -p "Enter target HEIGHT (e.g., 2400): " HEIGHT
        if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
            echo "Invalid input. Please enter a number (e.g., 2400)."
            continue
        fi
        
        echo "✅ Resolution set to ${WIDTH}x${HEIGHT}."
        break
    done
}

# --- Function to get the input file ---
get_input_file() {
    echo
    while true; do
        read -p "Please enter the path to your video/GIF file: " INPUT_FILE
        
        # Check if the file exists
        if [ ! -f "$INPUT_FILE" ]; then
            echo "Error: File not found at '$INPUT_FILE'. Please try again."
        else
            echo "✅ Using file: $INPUT_FILE"
            break
        fi
    done
}


# --- CONFIGURATION (Interactive) ---
select_fps
get_resolution
get_input_file

# These durations are still hardcoded.
INTRO_DURATION=1.5  # 1.5 seconds
LOOP_DURATION=4.5   # 4.5 seconds
# ---

# 1. Input Validation (REMOVED - Handled by get_input_file)
# $INPUT_FILE is now set by the function above.

# 2. Define Project Variables
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

# 3. Create Project Structure
echo
echo "Setting up project directory: $PROJECT_DIR"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 4. Define the FFmpeg Filter
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 5. Generate Intro Frames (part0)
echo "Processing Intro (part0)..."
# Suppress noisy ffmpeg output with -loglevel error
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

# 6. Generate Loop Frames (part1)
echo "Processing Loop (part1)..."
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 7. Create desc.txt
echo "Generating desc.txt..."
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo "------------------------------------------------"
echo "✅ Success! Project created at '$PROJECT_DIR'"
echo "Resolution: $WIDTH x $HEIGHT @ $FPS fps"
echo "Intro frames: $(ls -1q "$PART0_DIR" | wc -l)"
echo "Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)"
echo "------------------------------------------------"

# --- Integrated Full-Screen Preview ---
echo
echo "Would you like to preview the animation? (y/n)"
read -p "Choice: " preview_choice

if [[ "$preview_choice" == "y" || "$preview_choice" == "Y" ]]; then
  echo "Generating preview... Press 'q' or 'ESC' to quit full-screen."
  
  # Check if ffplay is installed
  if ! command -v ffplay &> /dev/null; then
      echo "Error: ffplay is not found. Please install ffmpeg to use the preview."
      exit 1
  fi
  
  ffplay -autoexit -fs -framerate $FPS -i "$PART0_DIR/frame_%04d.png" && \
  ffplay -fs -framerate $FPS -loop 0 -i "$PART1_DIR/frame_%04d.png"

  echo "Preview finished."
fi
# --- End of Script ---select_fps() {
    echo -e "${BLUE}Please select a frame rate (FPS):${NC}"
    options=("15" "25" "30")
    # Set the prompt for the 'select' menu
    PS3=$'\n'"${YELLOW}Choice: ${NC}"
    
    select opt in "${options[@]}"; do
        if [[ " ${options[@]} " =~ " ${opt} " ]]; then
            FPS=$opt
            echo -e "✅ ${GREEN}FPS set to $FPS.${NC}"
            break
        else
            echo -e "❌ ${RED}Invalid option $REPLY. Please select 1, 2, or 3.${NC}"
        fi
    done
}

# --- Function to get Resolution (Aspect Ratio) ---
get_resolution() {
    echo -e "\n${BLUE}Please enter the target resolution (this defines the aspect ratio).${NC}"
    while true; do
        # Use $'..._ to safely include escape codes in the read prompt
        read -p $'\n'"${YELLOW}Enter target WIDTH (e.g., 1080): ${NC}" WIDTH
        if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 1080).${NC}"
            continue
        fi
        
        read -p "${YELLOW}Enter target HEIGHT (e.g., 2400): ${NC}" HEIGHT
        if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 2400).${NC}"
            continue
        fi
        
        echo -e "✅ ${GREEN}Resolution set to ${WIDTH}x${HEIGHT}.${NC}"
        break
    done
}

# --- Function to get the input file ---
get_input_file() {
    echo -e "\n${BLUE}Please provide the source video or GIF.${NC}"
    while true; do
        read -p $'\n'"${YELLOW}Enter the path to your file: ${NC}" INPUT_FILE
        
        if [ ! -f "$INPUT_FILE" ]; then
            echo -e "❌ ${RED}Error: File not found at '$INPUT_FILE'. Please try again.${NC}"
        else
            echo -e "✅ ${GREEN}Using file: $INPUT_FILE${NC}"
            break
        fi
    done
}


# --- CONFIGURATION (Interactive) ---
select_fps
get_resolution
get_input_file

# These durations are still hardcoded.
INTRO_DURATION=1.5  # 1.5 seconds
LOOP_DURATION=4.5   # 4.5 seconds
# ---

# 1. Input Validation (REMOVED - Handled by get_input_file)

# 2. Define Project Variables
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

# 3. Create Project Structure
echo -e "\n${CYAN}Setting up project directory: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 4. Define the FFmpeg Filter
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 5. Generate Intro Frames (part0)
echo -e "${CYAN}Processing Intro (part0)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

# 6. Generate Loop Frames (part1)
echo -e "${CYAN}Processing Loop (part1)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 7. Create desc.txt
echo -e "${CYAN}Generating desc.txt...${NC}"
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "✅ ${LIGHTGREEN}Success! Project created at '$PROJECT_DIR'${NC}"
echo -e "${WHITE}Resolution: $WIDTH x $HEIGHT @ $FPS fps${NC}"
echo -e "${WHITE}Intro frames: $(ls -1q "$PART0_DIR" | wc -l)${NC}"
echo -e "${WHITE}Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"

# --- Integrated Full-Screen Preview ---
echo
echo -e "${BLUE}Would you like to preview the animation? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" preview_choice

if [[ "$preview_choice" == "y" || "$preview_choice" == "Y" ]]; then
  echo -e "${CYAN}Generating preview... Press 'q' or 'ESC' to quit full-screen.${NC}"
  
  if ! command -v ffplay &> /dev/null; then
      echo -e "❌ ${RED}Error: ffplay is not found. Please install ffmpeg to use the preview.${NC}"
      exit 1
  fi
  
  ffplay -autoexit -fs -framerate $FPS -i "$PART0_DIR/frame_%04d.png" && \
  ffplay -fs -framerate $FPS -loop 0 -i "$PART1_DIR/frame_%04d.png"

  echo -e "${CYAN}Preview finished.${NC}"
fi
# --- End of Script ---            break
        fi
    done
}


# --- CONFIGURATION (Interactive) ---
select_fps
get_resolution
get_input_file

# These durations are still hardcoded.
INTRO_DURATION=1.5  # 1.5 seconds
LOOP_DURATION=4.5   # 4.5 seconds
# ---

# 1. Input Validation (REMOVED - Handled by get_input_file)

# 2. Define Project Variables
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

# 3. Create Project Structure
echo -e "\n${CYAN}Setting up project directory: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 4. Define the FFmpeg Filter
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 5. Generate Intro Frames (part0)
echo -e "${CYAN}Processing Intro (part0)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

# 6. Generate Loop Frames (part1)
echo -e "${CYAN}Processing Loop (part1)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 7. Create desc.txt
echo -e "${CYAN}Generating desc.txt...${NC}"
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "✅ ${LIGHTGREEN}Success! Project created at '$PROJECT_DIR'${NC}"
echo -e "${WHITE}Resolution: $WIDTH x $HEIGHT @ $FPS fps${NC}"
echo -e "${WHITE}Intro frames: $(ls -1q "$PART0_DIR" | wc -l)${NC}"
echo -e "${WHITE}Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"

# --- Integrated Full-Screen Preview ---
echo
echo -e "${BLUE}Would you like to preview the animation? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" preview_choice

if [[ "$preview_choice" == "y" || "$preview_choice" == "Y" ]]; then
  echo -e "${CYAN}Generating preview... Press 'q' or 'ESC' to quit full-screen.${NC}"
  
  if ! command -v ffplay &> /dev/null; then
      echo -e "❌ ${RED}Error: ffplay is not found. Please install ffmpeg to use the preview.${NC}"
      exit 1
  fi
  
  ffplay -autoexit -fs -framerate $FPS -i "$PART0_DIR/frame_%04d.png" && \
  ffplay -fs -framerate $FPS -loop 0 -i "$PART1_DIR/frame_%04d.png"

  echo -e "${CYAN}Preview finished.${NC}"
fi
# --- End of Script ---

# --- Function to select FPS ---
select_fps() {
    echo -e "${BLUE}Please select a frame rate (FPS):${NC}"
    options=("15" "25" "30")
    # Set the prompt for the 'select' menu
    PS3=$'\n'"${YELLOW}Choice: ${NC}"
    
    select opt in "${options[@]}"; do
        if [[ " ${options[@]} " =~ " ${opt} " ]]; then
            FPS=$opt
            echo -e "✅ ${GREEN}FPS set to $FPS.${NC}"
            break
        else
            echo -e "❌ ${RED}Invalid option $REPLY. Please select 1, 2, or 3.${NC}"
        fi
    done
}

# --- Function to get Resolution (Aspect Ratio) ---
get_resolution() {
    echo -e "\n${BLUE}Please enter the target resolution (this defines the aspect ratio).${NC}"
    while true; do
        # Use $'..._ to safely include escape codes in the read prompt
        read -p $'\n'"${YELLOW}Enter target WIDTH (e.g., 1080): ${NC}" WIDTH
        if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 1080).${NC}"
            continue
        fi
        
        read -p "${YELLOW}Enter target HEIGHT (e.g., 2400): ${NC}" HEIGHT
        if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 2400).${NC}"
            continue
        fi
        
        echo -e "✅ ${GREEN}Resolution set to ${WIDTH}x${HEIGHT}.${NC}"
        break
    done
}

# --- Function to get the input file ---
get_input_file() {
    echo -e "\n${BLUE}Please provide the source video or GIF.${NC}"
    while true; do
        read -p $'\n'"${YELLOW}Enter the path to your file: ${NC}" INPUT_FILE
        
        if [ ! -f "$INPUT_FILE" ]; then
            echo -e "❌ ${RED}Error: File not found at '$INPUT_FILE'. Please try again.${NC}"
        else
            echo -e "✅ ${GREEN}Using file: $INPUT_FILE${NC}"
            break
        fi
    done
}


# --- CONFIGURATION (Interactive) ---
select_fps
get_resolution
get_input_file

# These durations are still hardcoded.
INTRO_DURATION=1.5  # 1.5 seconds
LOOP_DURATION=4.5   # 4.5 seconds
# ---

# 1. Input Validation (REMOVED - Handled by get_input_file)

# 2. Define Project Variables
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

# 3. Create Project Structure
echo -e "\n${CYAN}Setting up project directory: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

# 4. Define the FFmpeg Filter
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# 5. Generate Intro Frames (part0)
echo -e "${CYAN}Processing Intro (part0)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss 0 \
       -t $INTRO_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART0_DIR/frame_%04d.png"

# 6. Generate Loop Frames (part1)
echo -e "${CYAN}Processing Loop (part1)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
       -ss $INTRO_DURATION \
       -t $LOOP_DURATION \
       -vf "$FILTER_GRAPH" \
       -vsync vfr \
       "$PART1_DIR/frame_%04d.png"

# 7. Create desc.txt
echo -e "${CYAN}Generating desc.txt...${NC}"
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "✅ ${LIGHTGREEN}Success! Project created at '$PROJECT_DIR'${NC}"
echo -e "${WHITE}Resolution: $WIDTH x $HEIGHT @ $FPS fps${NC}"
echo -e "${WHITE}Intro frames: $(ls -1q "$PART0_DIR" | wc -l)${NC}"
echo -e "${WHITE}Loop frames:  $(ls -1q "$PART1_DIR" | wc -l)${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"

# --- Integrated Full-Screen Preview ---
echo
echo -e "${BLUE}Would you like to preview the animation? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" preview_choice

if [[ "$preview_choice" == "y" || "$preview_choice" == "Y" ]]; then
  echo -e "${CYAN}Generating preview... Press 'q' or 'ESC' to quit full-screen.${NC}"
  
  if ! command -v ffplay &> /dev/null; then
      echo -e "❌ ${RED}Error: ffplay is not found. Please install ffmpeg to use the preview.${NC}"
      exit 1
  fi
  
  ffplay -autoexit -fs -framerate $FPS -i "$PART0_DIR/frame_%04d.png" && \
  ffplay -fs -framerate $FPS -loop 0 -i "$PART1_DIR/frame_%04d.png"

  echo -e "${CYAN}Preview finished.${NC}"
fi
# --- End of Script ---
