#!/bin/bash

# --- 0. Clear the terminal screen ---
clear

# --- 1. Color Definitions ---
BLUE=$'\e[1;34m'
YELLOW=$'\e[1;33m'
GREEN=$'\e[0;32m'
LIGHTGREEN=$'\e[1;32m'
RED=$'\e[1;31m'
CYAN=$'\e[0;36m'
LIGHTCYAN=$'\e[96m'
WHITE=$'\e[1;37m'
NC=$'\e[0m' # No Color

# --- 2. Abort Handling ---
trap 'echo -e "\n${RED}Aborted by user.${NC}"; exit 1' INT

# --- 3. Dependency Checks ---
for cmd in ffmpeg ffprobe zip bc; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "❌ ${RED}Error: '$cmd' is required but not installed.${NC}"
        exit 1
    fi
done

# --- 4. Summary Banner ---
echo    '.--------------------------------------------------------------------------------.'
echo    '|                                                                                |'
echo    '|                A N D R O I D     B O O T     A N I M A T I O N                 |'
echo    '|                                                                                |'
echo    '|                               G E N E R A T O R                                |'
echo    '|                                                                                |'
echo -e "|                            ${WHITE}CREATOR : IT'S ME ARJUN${NC}                            |"
echo -e "|                           ${BLUE}GITHUB : its-me-arjun-0007${NC}                          |"
echo -e "|                          ${LIGHTCYAN}INSTAGRAM : its_me_arjun_2255${NC}                        |"
echo    '|                                                                                |'
echo    '--------------------------------------------------------------------------------'
echo
echo -e "${WHITE}A Bash script to convert any video/GIF into a formatted Android bootanimation.zip.${NC}"
echo -e "${YELLOW}LEGAL DISCLAIMER${NC}"
echo -e "${WHITE}USE AT YOUR OWN RISK. This tool is for educational and personal use only.${NC}"
echo -e "${WHITE}Modifying system files can be risky. The creator is not responsible for any damage.${NC}"
echo -e "${WHITE}Always back up your data and original bootanimation.zip before proceeding.${NC}"

# --- 5. Function to select FPS ---
select_fps() {
    echo -e "\n${BLUE}Please select a frame rate (FPS):${NC}"
    options=("15" "25" "30")
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

# --- 6. Function to get Resolution ---
get_resolution() {
    get_custom_resolution() {
        echo -e "\n${BLUE}Please enter the custom resolution.${NC}"
        echo -e "${CYAN}Press Enter to use default 1080x2400.${NC}"

        while true; do
            read -p $'\n'"${YELLOW}Enter target WIDTH (default: 1080): ${NC}" custom_width
            WIDTH=${custom_width:-1080}
            if [[ ! "$WIDTH" =~ ^[1-9][0-9]*$ ]]; then
                echo -e "❌ ${RED}Invalid input. Please enter a number.${NC}"
                continue
            fi
            read -p "${YELLOW}Enter target HEIGHT (default: 2400): ${NC}" custom_height
            HEIGHT=${custom_height:-2400}
            if [[ ! "$HEIGHT" =~ ^[1-9][0-9]*$ ]]; then
                echo -e "❌ ${RED}Invalid input. Please enter a number.${NC}"
                continue
            fi
            break
        done
    }

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
    PS3=$'\n'"${YELLOW}Choice (Press Enter for default: 1): ${NC}"

    select opt in "${options[@]}"; do
        if [[ -z "$REPLY" || "$REPLY" == "" ]]; then
            echo -e "No selection made. Using default 1080x2400."
            WIDTH=1080; HEIGHT=2400; break
        fi
        case $REPLY in
            1) WIDTH=1080; HEIGHT=2400; break ;;
            2) WIDTH=1440; HEIGHT=3200; break ;;
            3) WIDTH=1080; HEIGHT=2340; break ;;
            4) WIDTH=1440; HEIGHT=3120; break ;;
            5) WIDTH=1080; HEIGHT=2520; break ;;
            6) WIDTH=1080; HEIGHT=1920; break ;;
            7) WIDTH=1440; HEIGHT=2560; break ;;
            8) WIDTH=720; HEIGHT=1600; break ;;
            9) get_custom_resolution; break ;;
            *) echo -e "❌ ${RED}Invalid option $REPLY. Please select 1–9 or press Enter.${NC}" ;;
        esac
    done

    echo -e "✅ ${GREEN}Resolution set to ${WIDTH}x${HEIGHT}.${NC}"
}

# --- 7. Get input file ---
get_input_file() {
    echo -e "\n${BLUE}Please provide the source video or GIF.${NC}"
    while true; do
        read -p $'\n'"${YELLOW}Enter the path to your file: ${NC}" INPUT_FILE
        if [ ! -f "$INPUT_FILE" ]; then
            echo -e "❌ ${RED}Error: File not found at '$INPUT_FILE'.${NC}"
        else
            echo -e "✅ ${GREEN}Using file: $INPUT_FILE${NC}"
            break
        fi
    done
}

# --- 8. Ask for Optional Audio File ---
get_audio_file() {
    echo -e "\n${BLUE}Would you like to add a boot sound? (y/n)${NC}"
    read -p "${YELLOW}Choice: ${NC}" add_sound

    if [[ "$add_sound" =~ ^[Yy]$ ]]; then
        while true; do
            read -p $'\n'"${YELLOW}Enter path to your audio file (.mp3 / .wav): ${NC}" AUDIO_FILE
            if [ ! -f "$AUDIO_FILE" ]; then
                echo -e "❌ ${RED}File not found. Try again.${NC}"
            else
                echo -e "✅ ${GREEN}Using audio file: $AUDIO_FILE${NC}"
                break
            fi
        done
    else
        AUDIO_FILE=""
    fi
}

# --- 9. Configuration ---
select_fps
get_resolution
get_input_file
get_audio_file

INTRO_DURATION=1.5
PROJECT_DIR="custom_boot_animation"
PART0_DIR="$PROJECT_DIR/part0"
PART1_DIR="$PROJECT_DIR/part1"
DESC_FILE="$PROJECT_DIR/desc.txt"

echo -e "\n${CYAN}Setting up project directory: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PART0_DIR" "$PART1_DIR"

FILTER_GRAPH="fps=$FPS,scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1"

# --- 10. Analyze Video ---
echo -e "${CYAN}Analyzing video duration...${NC}"
TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

if [[ -z "$TOTAL_DURATION" || ! "$TOTAL_DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo -e "❌ ${RED}Error: Could not determine video duration.${NC}"
    exit 1
fi

if (( $(echo "$TOTAL_DURATION < $INTRO_DURATION" | bc -l) )); then
    echo -e "❌ ${RED}Video too short (< $INTRO_DURATION s).${NC}"
    exit 1
fi

LOOP_DURATION=$(echo "$TOTAL_DURATION - $INTRO_DURATION" | bc)
echo -e "✅ ${GREEN}Video duration: ${TOTAL_DURATION}s | Loop: ${LOOP_DURATION}s${NC}"

# --- 11. Generate Frames ---
echo -e "${CYAN}Processing Intro (part0)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
    -ss 0 \
    -t "$INTRO_DURATION" \
    -vf "$FILTER_GRAPH" \
    -vsync vfr \
    "$PART0_DIR/frame_%04d.png"

echo -e "${CYAN}Processing Loop (part1)...${NC}"
ffmpeg -loglevel error -i "$INPUT_FILE" \
    -ss "$INTRO_DURATION" \
    -t "$LOOP_DURATION" \
    -vf "$FILTER_GRAPH" \
    -vsync vfr \
    "$PART1_DIR/frame_%04d.png"

# --- 12. Generate desc.txt ---
echo -e "${CYAN}Generating desc.txt...${NC}"
echo "$WIDTH $HEIGHT $FPS" > "$DESC_FILE"
echo "p 1 0 part0" >> "$DESC_FILE"
echo "p 0 0 part1" >> "$DESC_FILE"

# --- 13. Optional Boot Sound ---
if [[ -n "$AUDIO_FILE" ]]; then
    echo -e "\n${CYAN}Processing audio file...${NC}"
    ffmpeg -loglevel error -i "$AUDIO_FILE" -ac 2 -ar 44100 -c:a libvorbis -y "$PROJECT_DIR/boot_sound.ogg"

    # Verify audio duration
    AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$PROJECT_DIR/boot_sound.ogg")
    if (( $(echo "$AUDIO_DURATION > $TOTAL_DURATION + 1" | bc -l) )); then
        echo -e "⚠️ ${YELLOW}Warning: Boot sound is longer than animation. It will play partially.${NC}"
    fi
fi

echo -e "✅ ${LIGHTGREEN}Frames and audio prepared successfully.${NC}"

# --- 14. Create bootanimation.zip ---
echo
echo -e "${BLUE}Would you like to create bootanimation.zip now? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" zip_choice

if [[ "$zip_choice" =~ ^[Yy]$ ]]; then
    ORIG_DIR=$(pwd)
    cd "$PROJECT_DIR" || exit 1

    if [[ -f "boot_sound.ogg" ]]; then
        zip -0qr "$ORIG_DIR/bootanimation.zip" part0 part1 desc.txt boot_sound.ogg
    else
        zip -0qr "$ORIG_DIR/bootanimation.zip" part0 part1 desc.txt
    fi

    cd "$ORIG_DIR" || exit 1

    if [ -f "bootanimation.zip" ]; then
        echo -e "✅ ${LIGHTGREEN}Created 'bootanimation.zip' successfully!${NC}"
    else
        echo -e "❌ ${RED}Error: Failed to create zip file.${NC}"
    fi
fi

# --- 15. Preview Animation ---
echo
echo -e "${BLUE}Would you like to preview the animation? (y/n)${NC}"
read -p "${YELLOW}Choice: ${NC}" preview_choice

if [[ "$preview_choice" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Generating preview... Press 'q' to quit.${NC}"
    ffplay -autoexit -fs -framerate "$FPS" -i "$PART0_DIR/frame_%04d.png"
    ffplay -fs -framerate "$FPS" -loop 0 -i "$PART1_DIR/frame_%04d.png"
    echo -e "${CYAN}Preview finished.${NC}"
fi

# --- End of Script ---
