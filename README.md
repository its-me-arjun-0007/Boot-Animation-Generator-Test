<p align="center">
  <img src="1002971044.png" alt="Tool Banner" width="50%"/>
</p>

## Summary

A simple and powerful Bash script for Kali Linux to convert any video or GIF into a perfectly formatted, Android-compatible `bootanimation.zip` file.

## Overview

This Bash script is a command-line interface (CLI) tool designed to automate the entire process of converting a standard video or GIF file into a fully compliant Android `bootanimation.zip` file. It acts as a user-friendly wrapper around powerful multimedia tools like `ffmpeg` and `ffprobe`. The script guides the user through a series of interactive prompts to configure key parameters such as frame rate (FPS) and resolution. It then intelligently analyzes the source video to split it into an introductory sequence (which plays once) and a looping sequence. 

Finally, it processes and packages the resulting image frames into the precise directory structure and uncompressed ZIP format required by the Android operating system, with an optional built-in preview to verify the result.

This script handles all of that in a single command. You provide a video or GIF, and it outputs a ready-to-use `bootanimation.zip` file, built to your exact specifications.

## Legal Disclaimer

**USE AT YOUR OWN RISK.** This tool is intended for educational and personal use only.

Modifying your Android device's system files (such as `/system/media/bootanimation.zip`) carries inherent risks, including the possibility of a "bootloop" or system instability if done incorrectly. The creator of this tool is not responsible for any damage, data loss, or "bricked" devices that may result from its use.

**Always back up your data and your original `bootanimation.zip` file before applying any modifications.**

## Key Features

* **Interactive Configuration:** Instead of requiring users to edit variables within the script, it interactively prompts for all necessary parameters (FPS, resolution, and source file path), making it accessible even to users unfamiliar with shell scripting.

* **Dynamic Duration Splitting:** A standout feature is its ability to dynamically calculate the split point between the intro and the loop. It uses `ffprobe` to get the total video duration and `bc` for floating-point math, ensuring the loop part uses the remainder of the video after a fixed-length intro. This is far more flexible than hardcoding split times.

* **Advanced `ffmpeg` Filtering:** The script constructs a sophisticated `ffmpeg` filter chain (`-vf`). This chain not only resizes the video but also intelligently handles aspect ratios by padding with black bars (`pad`) to prevent stretching, ensuring the final animation looks professional on the target device.

* **Correct Packaging (`zip -0`):** It correctly creates the `bootanimation.zip` file using the essential `-0` flag, which ensures the files are stored without compression. This is a critical requirement, as the Android boot loader cannot handle compressed boot animation files.

* **Integrated Full-Screen Preview:** The inclusion of an `ffplay`-based preview is an excellent feature. It allows the user to immediately see how the intro and loop will play on a screen, providing instant feedback and saving the time of testing on an actual device..

* **Dependency and Error Handling:** The script performs checks for necessary dependencies like `zip` and `ffplay` before attempting to use them. It also validates user input (e.g., ensuring resolution is a number) and checks for the existence of the source file, preventing crashes and providing clear error messages.

* **Clean Workspace Management:** By deleting (`rm -rf`) and recreating the project directory at the start, the script guarantees that each run is clean and free from artifacts of previous executions.

## Key Design Principles

**The script is built on three core principles:**

* **User-Centric Interaction:** It's designed as an interactive wizard. Instead of forcing the user to edit script variables, it uses `read` and `select` prompts to guide them, making it highly accessible.

* **Modularity:** Logic is cleanly separated into distinct functions (e.g., `select_fps`, `get_resolution`), making the code easy to read, maintain, and debug.

* **Robustness & Safety:** It includes essential checks for user input errors (e.g., non-numeric input) and missing dependencies (`zip`, `ffplay`), preventing common failures. The initial `rm -rf` ensures each run is atomic and starts from a clean state.

## Structural Elements & Functional Aspects

The script's architecture follows a clear, linear execution flow divided into four main phases:

**1** **Initialization:** Sets up the environment by defining color variables for the UI, displaying a header, and preparing a clean, empty project directory.

**2** **Configuration:** This phase is entirely interactive. It calls the modular functions to gather all necessary parameters (FPS, Resolution, Source File) from the user and store them in global variables.

**3** **Processing (Core Engine):** This is the non-interactive backend. It uses `ffprobe` to analyze the source media, then executes two `ffmpeg` commands to process and split the video into `part0` (intro) and `part1` (loop) frames. It finishes by writing the `desc.txt` control file.

**4** **Finalization (Conditional):** This final phase is optional and user-driven. It checks the user's choice to either:

* **Package:** Create the final, uncompressed `bootanimation.zip` file.

* **Preview:** Launch `ffplay` to provide an immediate visual feedback loop.

## Unique & Innovative Features

**Dynamic Split Calculation:** The script doesn't rely on hardcoded timers. It intelligently uses `ffprobe` to get the video's total duration and `bc` to calculate the loop's length, making it adaptable to any video.

**Integrated Verification:** The built-in `ffplay` preview is a key feature that allows the user to test and verify the animation's intro and loop behavior before deploying it to a device.

**Compliance-First Packaging:** It correctly enforces the mandatory `zip -0` (store-only) flag, which is a common point of failure for manual boot animation creation.

## Prerequisites

This script is designed for a Debian-based Linux environment (like Kali Linux, Ubuntu, or Debian). You must have the following packages installed:

* `ffmpeg`
* `zip`
* `bc`

## Installation

1.  **Install Dependencies:**
    Open your terminal and install `ffmpeg`, `zip` and `bc`:
    ```bash
    sudo apt update && sudo apt install ffmpeg zip bc -y
    ```

2.  **Get the Script:**
    Clone this repository:
    ```bash
    git clone https://github.com/its-me-arjun-0007/Boot-Animation-Generator-Test
    ```
    ```
    cd Boot-Animation-Generator-Test
    ```

3.  **Make the Script Executable:**
    ```bash
    chmod +x create_bootani.sh
    ```

## Usage

Run the script from your terminal, providing the path to your input video or GIF file as the only argument.

```bash
./create_bootani.sh
````

## Sample Output

After running the script, you will get the following structure:

```
.
├── create_bootani.sh
├── my-cool-animation.mp4
├── 1002971041.jpg
├── README.md
├── bootanimation.zip        <-- This is your final file
└── custom_boot_animation/   <-- This is the working directory
    ├── desc.txt
    ├── part0/
    │   ├── frame_0000.png
    │   ├── frame_0001.png
    │   └── ... (45 intro frames)
    └── part1/
        ├── frame_0000.png
        ├── frame_0001.png
        └── ... (135 loop frames)
```

## Educational Use Cases

This project is an excellent way to learn about:

  * **Bash Scripting:** How to write scripts that automate complex tasks and pass arguments.
  * **FFmpeg Filters:** How to use FFmpeg's powerful filter chains (`-vf`) to manipulate video streams in real-time.
  * **Android Internals:** Understanding how Android's boot sequence works and how it loads custom assets.
  * **File Formats:** The difference between compressed and uncompressed zip archives and why Android requires the latter.

## Support & Contact

For questions, bug reports, or collaboration, feel free to reach out.

  * **GitHub:** [its-me-arjun-0007](https://github.com/its-me-arjun-0007)
  * **Instagram:** [@its\_me\_arjun\_2255](https://www.instagram.com/its_me_arjun_2255)
  * **WhatsApp:** [Chat on WhatsApp](https://wa.me/+917356118016)

<!-- end list -->

```
```








