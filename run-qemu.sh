#!/bin/bash
# run-qemu.sh - Script to run basicKernel in QEMU on Linux/WSL

echo "BasicKernel QEMU Runner (Linux/WSL)"
echo "----------------------------------"

# Check if kernel.elf exists
if [ ! -f "kernel.elf" ]; then
    echo "Error: kernel.elf not found. Building it now..."
    make kernel.elf
    
    # Check if build was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to build kernel.elf. See errors above."
        exit 1
    fi
fi

# Check if QEMU is installed
QEMU_PATH=$(command -v qemu-system-i386 2>/dev/null)
if [ -z "$QEMU_PATH" ]; then
    echo "qemu-system-i386 not found. Installing required packages..."
    
    # Try to detect the Linux distribution and install packages
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu/Kali based
        echo "Detected Debian/Ubuntu/Kali based system"
        sudo apt-get update
        sudo apt-get install -y qemu-system-x86 grub-pc-bin grub-common xorriso
    elif command -v yum &> /dev/null; then
        # RHEL/CentOS/Fedora based
        echo "Detected RHEL/CentOS/Fedora based system"
        sudo yum install -y qemu-system-x86 grub2-tools xorriso
    else
        echo "Could not automatically install QEMU."
        echo "Please install QEMU manually using your distribution's package manager."
        exit 1
    fi
    
    # Check again if QEMU was installed
    QEMU_PATH=$(command -v qemu-system-i386 2>/dev/null)
    if [ -z "$QEMU_PATH" ]; then
        echo "Error: Failed to install qemu-system-i386."
        exit 1
    fi
else
    echo "Found QEMU at: $QEMU_PATH"
fi

# Run kernel directly if ISO doesn't exist or if requested
if [ ! -f "basickernel.iso" ] || [ "$1" == "--direct" ]; then
    echo "Running kernel directly with QEMU..."
    # Try these QEMU parameters in order until one works
    if ! "$QEMU_PATH" -kernel kernel.elf -display gtk,gl=off 2>/dev/null; then
        echo "First attempt failed, trying without display options..."
        if ! "$QEMU_PATH" -kernel kernel.elf 2>/dev/null; then
            echo "Error running QEMU. Trying with no graphics..."
            "$QEMU_PATH" -kernel kernel.elf -nographic || {
                echo "All QEMU attempts failed. Please check your QEMU installation."
                exit 1
            }
        fi
    fi
else
    # Create ISO if it doesn't exist
    if [ ! -f "basickernel.iso" ]; then
        echo "ISO not found. Creating one..."
        make iso
        
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create ISO. Running kernel directly instead."
            "$QEMU_PATH" -kernel kernel.elf -display gtk,gl=off || "$QEMU_PATH" -kernel kernel.elf || "$QEMU_PATH" -kernel kernel.elf -nographic
            exit 0
        fi
    fi
    
    echo "Running kernel from ISO with QEMU..."
    # Try these QEMU parameters in order until one works
    if ! "$QEMU_PATH" -cdrom basickernel.iso -display gtk,gl=off 2>/dev/null; then
        echo "First attempt failed, trying without display options..."
        if ! "$QEMU_PATH" -cdrom basickernel.iso 2>/dev/null; then
            echo "Error running QEMU. Trying with no graphics..."
            "$QEMU_PATH" -cdrom basickernel.iso -nographic || {
                echo "All QEMU attempts failed. Please check your QEMU installation."
                exit 1
            }
        fi
    fi
fi

exit 0
