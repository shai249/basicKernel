# Makefile for basicKernel

# Cross-compiler settings
CC = i386-elf-gcc
LD = i386-elf-ld
AS = i386-elf-as

# Flags
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c -g
LDFLAGS = -T linker.ld -melf_i386
ASFLAGS = --32

# Source files
CSOURCES = kernel.c screen.c keyboard.c shell.c
OBJECTS = $(CSOURCES:.c=.o)

# Detect OS for conditional compilation
ifeq ($(OS),Windows_NT)
	DETECTED_OS := Windows
else
	DETECTED_OS := $(shell uname -s)
endif

# Check if running in WSL
ifneq ($(findstring microsoft,$(shell uname -r)),)
	DETECTED_OS := WSL
endif

# Default target - on Windows, don't try to build ISO by default
# On WSL or Linux, always try to build the ISO
ifeq ($(DETECTED_OS),Windows)
all: kernel.elf grub_note
else
all: kernel.elf iso
endif

# Information about GRUB on Windows
grub_note:
	@echo "NOTE: ISO creation skipped on Windows."
	@echo "To create a bootable ISO, you need GRUB tools which are primarily available on Linux."
	@echo "Options:"
	@echo "1. Use WSL (Windows Subsystem for Linux) to run 'make iso'"
	@echo "2. Use a Linux VM to build the ISO"
	@echo "3. Use tools like RUFUS to create a bootable USB from kernel.elf"

# Clean target
clean:
	rm -f *.o kernel.elf 
	rm -rf iso
	rm -f basickernel.iso

# Compile C sources to object files
%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

# Link the kernel
kernel.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

# Create an ISO image for GRUB
iso: kernel.elf
	@echo "Creating GRUB bootable ISO..."
	mkdir -p iso/boot/grub
	cp kernel.elf iso/boot/
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo 'menuentry "BasicKernel" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/kernel.elf' >> iso/boot/grub/grub.cfg
	echo '  boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	@if ! which grub-mkrescue >/dev/null 2>&1; then \
		echo "Error: grub-mkrescue not found. Installing required packages..."; \
		if which apt-get >/dev/null 2>&1; then \
			sudo apt-get update && \
			sudo apt-get install -y grub-pc-bin grub-common xorriso; \
		else \
			echo "Please install the grub2-tools and xorriso packages manually."; \
			exit 1; \
		fi; \
	fi
	grub-mkrescue -o basickernel.iso iso || { \
		echo "Failed to create ISO. Make sure you have all required packages:"; \
		echo "  - grub-pc-bin"; \
		echo "  - grub-common"; \
		echo "  - xorriso"; \
		exit 1; \
	}

# Find QEMU executable
ifeq ($(DETECTED_OS),Windows)
    # Try common QEMU installation paths on Windows
    QEMU_PATHS = $(wildcard C:/Program*/qemu*/qemu-system-i386.exe) \
                $(wildcard C:/qemu*/qemu-system-i386.exe) \
                $(wildcard "C:/Program Files/qemu/qemu-system-i386.exe") \
                $(wildcard "C:/Program Files (x86)/qemu/qemu-system-i386.exe")
    
    ifneq ($(QEMU_PATHS),)
        # Use the first found QEMU path
        QEMU = "$(firstword $(QEMU_PATHS))"
    else
        # Default if not found
        QEMU = qemu-system-i386
    endif
else
    QEMU = qemu-system-i386
endif

# Run in QEMU - different approach based on OS
ifeq ($(DETECTED_OS),Windows)
run: kernel.elf
	@echo "Running kernel in QEMU (direct kernel load)..."
	@echo "Using QEMU: $(QEMU)"
	@if not exist $(QEMU) (echo "ERROR: QEMU not found at $(QEMU)" & \
	 echo "Please install QEMU or set its path manually in the Makefile" & \
	 echo "You can download QEMU from https://www.qemu.org/download/#windows" & \
	 exit /b 1)
	$(QEMU) -kernel kernel.elf
else ifeq ($(DETECTED_OS),WSL)
# WSL version - check for QEMU and use appropriate method
run: kernel.elf
	@echo "Running kernel in WSL with QEMU..."
	@if ! command -v $(QEMU) >/dev/null 2>&1; then \
		echo "Installing QEMU..."; \
		sudo apt-get update && \
		sudo apt-get install -y qemu-system-x86; \
	fi
	$(QEMU) -kernel kernel.elf
else
# Linux/macOS version tries ISO first, falls back to direct if needed
run: kernel.elf
	@echo "Running kernel in QEMU..."
	@if [ -f basickernel.iso ]; then \
		echo "Using ISO image..."; \
		$(QEMU) -cdrom basickernel.iso; \
	else \
		echo "ISO not found, running kernel directly..."; \
		$(QEMU) -kernel kernel.elf; \
	fi
endif

# Alternative run target for Windows
ifeq ($(DETECTED_OS),Windows)
qemu-run: kernel.elf
	@echo "Please enter the full path to qemu-system-i386.exe:"
	@set /p QEMU_PATH=
	@echo "Running kernel using specified QEMU path..."
	@"!QEMU_PATH!" -kernel kernel.elf
else
# Alternative Linux/WSL target for direct kernel load
qemu-run: kernel.elf
	@echo "Running kernel directly (without ISO)..."
	$(QEMU) -kernel kernel.elf
endif
