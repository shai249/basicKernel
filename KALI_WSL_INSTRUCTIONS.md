# Kali Linux WSL Instructions

This document provides specific instructions for building and running the basicKernel project in Kali Linux WSL.

## Setup Instructions

1. Open your Kali Linux WSL terminal
2. Navigate to your project directory:
   ```
   cd /mnt/c/Users/shaig/Desktop/Projects/basicKernel
   ```

3. Fix the permissions on the shell scripts:
   ```
   chmod +x *.sh
   ```

4. Run the Kali-specific script:
   ```
   ./kali-run.sh
   ```

This script will:
- Install all necessary packages
- Check for the cross-compiler and offer to install it
- Build the kernel
- Try multiple different QEMU display options to find one that works

## Troubleshooting

### Display Issues

If you have trouble with the graphical display in WSL:

1. Install an X server on Windows:
   - Download and install [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
   - Run XLaunch and select "Disable access control"

2. Configure your Kali WSL to use it:
   ```
   echo 'export DISPLAY=:0' >> ~/.bashrc
   source ~/.bashrc
   ```

3. Try running again:
   ```
   ./kali-run.sh
   ```

### Cross-Compiler Issues

If the automatic cross-compiler installation doesn't work:

1. Follow the manual build instructions in the main README.md
2. Make sure to add the cross-compiler to your PATH:
   ```
   export PATH="$HOME/opt/cross/bin:$PATH"
   ```

### Other Issues

If you continue to experience problems:

1. Try running with no graphics:
   ```
   qemu-system-i386 -kernel kernel.elf -nographic
   ```

2. Check for error messages and install any missing packages:
   ```
   sudo apt update
   sudo apt install build-essential qemu-system-x86 grub-pc-bin grub-common xorriso
   ```

## Running Individual Steps

If you prefer to run each step manually:

1. Build the kernel:
   ```
   make kernel.elf
   ```

2. Run in QEMU:
   ```
   qemu-system-i386 -kernel kernel.elf -display sdl
   ```

Good luck with your OS development project!
