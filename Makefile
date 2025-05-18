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

# Default target
all: kernel.elf iso

# Clean target
clean:
	rm -f *.o kernel.elf iso/boot/kernel.elf basickernel.iso

# Compile C sources to object files
%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

# Link the kernel
kernel.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

# Create an ISO image for GRUB
iso: kernel.elf
	mkdir -p iso/boot/grub
	cp kernel.elf iso/boot/
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo 'menuentry "BasicKernel" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/kernel.elf' >> iso/boot/grub/grub.cfg
	echo '  boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	grub-mkrescue -o basickernel.iso iso

# Run in QEMU
run: iso
	qemu-system-i386 -cdrom basickernel.iso
