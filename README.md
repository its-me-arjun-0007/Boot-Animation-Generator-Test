# Android Boot Animation Generator

<p align="center">
  <img src="1002971042.png" alt="Tool Banner" width="450"/>
</p>

## Summary

A simple and powerful Bash script for Kali Linux to convert any video or GIF into a perfectly formatted, Android-compatible `bootanimation.zip` file.

## Overview

This tool automates the tedious process of creating a custom Android boot animation. Manually, this requires extracting hundreds of frames, resizing and padding them to your screen's resolution, splitting them into an "intro" and "loop" sequence, writing a `desc.txt` file, and creating a special *uncompressed* zip archive.

This script handles all of that in a single command. You provide a video or GIF, and it outputs a ready-to-use `bootanimation.zip` file, built to your exact specifications.

## Legal Disclaimer

**USE AT YOUR OWN RISK.** This tool is intended for educational and personal use only.

Modifying your Android device's system files (such as `/system/media/bootanimation.zip`) carries inherent risks, including the possibility of a "bootloop" or system instability if done incorrectly. The creator of this tool is not responsible for any damage, data loss, or "bricked" devices that may result from its use.

**Always back up your data and your original `bootanimation.zip` file before applying any modifications.**

## Key Features

* **Video/GIF to PNG:** Converts common video formats (.mp4, .mov, .webm) and animated GIFs into a PNG sequence.
* **Android Structure:** Automatically creates the required `part0` (intro) and `part1` (loop) directory structure.
* **Smart Resizing:** Scales and pads your input media to fit the target resolution (e.g., 1080x2400) without stretching or distorting it.
* **`desc.txt` Generation:** Automatically creates the `desc.txt` file that tells Android the resolution, frame rate, and play order.
* **Correct Packaging:** Generates the final `bootanimation.zip` using "Store" (level 0) compression, which is required by Android.
* **Customizable:** All settings (resolution, FPS, durations) are easily configurable within the script.

## Architecture

This tool is a lightweight Bash script that acts as a wrapper for two powerful, pre-existing Linux utilities:

1.  **FFmpeg:** This is the core engine that handles all video processing. It is used for:
    * Reading the input file (video or GIF).
    * Splitting the animation into intro and loop segments.
    * Applying video filters to resize, pad, and set the frame rate.
    * Exporting the final frames as a PNG sequence.
2.  **`zip`:** This utility is used to package the final directories and `desc.txt` file into the `bootanimation.zip` archive. The crucial `-0` flag is used to ensure no compression is applied.

## Prerequisites

This script is designed for a Debian-based Linux environment (like Kali Linux, Ubuntu, or Debian). You must have the following packages installed:

* `ffmpeg`
* `zip`

## Installation

1.  **Install Dependencies:**
    Open your terminal and install `ffmpeg` and `zip`:
    ```bash
    sudo apt update
    sudo apt install ffmpeg zip
    ```

2.  **Get the Script:**
    Clone this repository:
    ```bash
    git clone https://github.com/its-me-arjun-0007/Boot-Animation-Generator
    cd Boot-Animation-Generator
    ```

3.  **Make the Script Executable:**
    ```bash
    chmod +x create_bootani.sh
    ```

## Usage

Run the script from your terminal, providing the path to your input video or GIF file as the only argument.

```bash
./create_bootani.sh <path-to-input-file>
````

**Example:**

```bash
./create_bootani.sh ~/Videos/my-cool-animation.mp4
```

The script will create a directory named `custom_boot_animation` and the final `bootanimation.zip` file in your current directory.

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








