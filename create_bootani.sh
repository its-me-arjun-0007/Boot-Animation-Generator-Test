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


echo    '.--------------------------------------------------------------------------------.'
echo    '|                                                                                |'
echo    '|                A N D R O I D     B O O T     A N I M A T I O N                 |'
echo    '|                                                                                |'
echo    '|                               G E N E R A T O R                                |'
echo    '|                                                                                |'
echo -e "|                             ${WHITE}CREATER : IT'S ME ARJUN${NC}                           |"
echo -e "|                            ${BLUE}GITHUB : its-me-arjun-0007${NC}                         |"
echo -e "|                           ${LIGHTCYAN}INSTAGRAM : its_me_arjun_2255${NC}                       |"
echo    '|                                                                                |'
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

# --- 4. Function to get Resolution (Aspect Ratio) ---
get_resolution() {

    # --- Helper Function for Custom Input ---
    # This is the logic from your previous script,
    # to be called if the user selects "Custom".
    get_custom_resolution() {
        echo -e "\n${BLUE}Please enter the custom resolution.${NC}"
        echo -e "${CYAN}Pressing Enter will use the default 1080x2400.${NC}"
        
        while true; do
            read -p $'\n'"${YELLOW}Enter target WIDTH (default: 1080): ${NC}" custom_width
            # Set default if input is empty
            WIDTH=${custom_width:-1080}
            
            if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
                echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 1080).${NC}"
                continue
            fi
            
            read -p "${YELLOW}Enter target HEIGHT (default: 2400): ${NC}" custom_height
            # Set default if input is empty
            HEIGHT=${custom_height:-2400}
            
            if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
                echo -e "❌ ${RED}Invalid input. Please enter a number (e.g., 2400).${NC}"
                continue
            fi
            
            break # Break this helper function's loop
        done
    }
    # --- End of Helper Function ---


    # --- Main Resolution Menu ---
    echo -e "\n${BLUE}Please select the target resolution:${NC}"
    options=(
        "1080 x 2400 (Pixel 5/6a, Galaxy A-series)"
        "1440 x 3200 (Galaxy S21/S22 Ultra)"
        "1080 x 2340 (Pixel 4, Galaxy S10/S20)"
        "1440 x 3120 (Pixel 4 XL, OnePlus 7 Pro)"
        "1080 x 2520 (Sony Xperia series)"
        "1080 x 1920 (Older HD - Pixel 2, Galaxy S7)"
        "1440 x 2560 (Older QHD - Pixel 2 XL)"
        "720 x 1600 (Budget devices)"
        "Custom (Enter manually)"
    )
    
    PS3=$'\n'"${YELLOW}Choice (1-9): ${NC}"
    
    select opt in "${options[@]}"; do
        case $REPLY in
            1) WIDTH=1080; HEIGHT=2400; break ;;
            2) WIDTH=1440; HEIGHT=3200; break ;;
            3) WIDTH=1080; HEIGHT=2340; break ;;
            4) WIDTH=1440; HEIGHT=3120; break ;;
            5) WIDTH=1080; HEIGHT=2520; break ;;
            6) WIDTH=1080; HEIGHT=1920; break ;;
            7) WIDTH=1440; HEIGHT=2560; break ;;
            8) WIDTH=720; HEIGHT=1600; break ;;
            9)
                get_custom_resolution
                break # This breaks the 'select' loop
                ;;
            *) echo -e "❌ ${RED}Invalid option $REPLY. Please select 1-9.${NC}" ;;
        esac
    done
    
    # Confirmation message
    echo -e "✅ ${GREEN}Resolution set to ${WIDTH}x${HEIGHT}.${NC}"
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

# 8. Define the FFmpeg Filter
FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

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
# --- End of Script ---
