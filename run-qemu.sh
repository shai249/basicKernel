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
if ! command -v qemu-system-i386 &> /dev/null; then
    echo "Error: qemu-system-i386 not found. Installing required packages..."
    
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
    if ! command -v qemu-system-i386 &> /dev/null; then
        echo "Error: Failed to install qemu-system-i386."
        exit 1
    fi
fi

# Run kernel directly if ISO doesn't exist or if requested
if [ ! -f "basickernel.iso" ] || [ "$1" == "--direct" ]; then
    echo "Running kernel directly with QEMU..."
    qemu-system-i386 -kernel kernel.elf
else
    # Create ISO if it doesn't exist
    if [ ! -f "basickernel.iso" ]; then
        echo "ISO not found. Creating one..."
        make iso
        
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create ISO. Running kernel directly instead."
            qemu-system-i386 -kernel kernel.elf
            exit 0
        fi
    fi
    
    echo "Running kernel from ISO with QEMU..."
    qemu-system-i386 -cdrom basickernel.iso
fi

exit 0
