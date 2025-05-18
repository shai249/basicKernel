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

# Default target - on Windows, don't try to build ISO by default
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
	@which grub-mkrescue >/dev/null 2>&1 || (echo "Error: grub-mkrescue not found. Please install GRUB2 tools." && exit 1)
	grub-mkrescue -o basickernel.iso iso

# Run in QEMU - Windows version loads kernel directly
ifeq ($(DETECTED_OS),Windows)
run: kernel.elf
	@echo "Running kernel in QEMU (direct kernel load)..."
	qemu-system-i386 -kernel kernel.elf
else
# Linux/macOS version uses ISO
run: iso
	@echo "Running kernel in QEMU (from ISO)..."
	qemu-system-i386 -cdrom basickernel.iso
endif
