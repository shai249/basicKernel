#!/bin/bash
# kali-run.sh - Script specifically tuned for running basicKernel on Kali Linux WSL

echo "BasicKernel Kali WSL Runner"
echo "=========================="

# Make sure we're in the right directory
if [ ! -f "kernel.c" ] || [ ! -f "Makefile" ]; then
    echo "Error: This script must be run from the basicKernel directory."
    exit 1
fi

echo "Step 1: Ensuring required packages are installed..."
sudo apt-get update
sudo apt-get install -y build-essential qemu-system-x86 grub-pc-bin grub-common xorriso

# Check if cross-compiler exists
echo "Step 2: Checking for cross-compiler..."
if ! command -v i386-elf-gcc &>/dev/null; then
    echo "Cross-compiler (i386-elf-gcc) not found."
    echo "You need to install the cross-compiler toolchain."
    echo ""
    echo "Would you like to download a pre-built toolchain? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        mkdir -p ~/opt
        cd ~/opt
        echo "Downloading pre-built toolchain..."
        wget -q --show-progress https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.tar.gz
        echo "Extracting toolchain..."
        tar -xzf i686-elf-tools-linux.tar.gz
        echo 'export PATH="$HOME/opt/i686-elf-tools-linux/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/opt/i686-elf-tools-linux/bin:$PATH"
        cd - > /dev/null
        echo "Toolchain installed. Added to PATH in ~/.bashrc"
    else
        echo "Please install the cross-compiler manually and try again."
        exit 1
    fi
fi

echo "Step 3: Building the kernel..."
make kernel.elf

if [ $? -ne 0 ]; then
    echo "Error: Build failed. See error messages above."
    exit 1
fi

echo "Step 4: Running kernel in QEMU..."
QEMU_PATH=$(command -v qemu-system-i386 2>/dev/null)

# This is the safest approach for WSL
echo "Attempting to run QEMU with SDL display..."
$QEMU_PATH -kernel kernel.elf -display sdl 2>/dev/null

if [ $? -ne 0 ]; then
    echo "SDL display failed. Trying GTK display..."
    $QEMU_PATH -kernel kernel.elf -display gtk 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "GTK display failed. Falling back to default display..."
        $QEMU_PATH -kernel kernel.elf 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo "Default display failed. Trying with nographic mode..."
            echo "(Note: You won't see the graphical output in this mode)"
            $QEMU_PATH -kernel kernel.elf -nographic
            
            if [ $? -ne 0 ]; then
                echo "All QEMU attempts failed. Try running with X server forwarding enabled."
                echo "For WSL2, you may need to install an X server like VcXsrv on Windows."
                exit 1
            fi
        fi
    fi
fi

exit 0
