#!/bin/bash

# --- 1. Color Definitions (Based on your request) ---
# Using \e[...] format for compatibility with 'echo -e'
# From your set 1:
CYAN='\e[0;36m'
LIGHTCYAN='\e[96m'
GREEN='\e[0;32m'
LIGHTGREEN='\e[1;32m'
WHITE='\e[1;37m'
RED='\e[1;31m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'

# From your set 2 (Reset variable):
NC='\e[0m' # No Color / Reset

# --- 2. Clear the terminal screen ---
clear

# --- Summary ---
echo
echo -e $green "Boot-Animationn Generator . version 3.0"
echo "Boot-Animation Generator a simple and powerful Bash script for Kali Linux to convert any video or GIF into a perfectly formatted, Android-compatible bootanimation.zip file."
echo
echo                  "CREATED BY ARJUN"
echo                "GITHUB  : https://github.com/its-me-arjun-0007"
echo              "INSTAGRAM : https://www.instagram.com/its_me_arjun_2255"
echo
echo -e $red "LEGAL DISCLAIMER"
echo "USE AT YOUR OWN RISK. This tool is intended for educational and personal use only."
echo "Modifying your Android device's system files (such as /system/media/bootanimation.zip) carries inherent risks, including the possibility of a bootloop or system instability if done incorrectly. The creator of this tool is not responsible for any damage, data loss, or bricked devices that may result from its use."
echo "Always back up your data and your original bootanimation.zip file before applying any modifications."


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
