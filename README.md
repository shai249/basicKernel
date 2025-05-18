# BasicKernel

A very simple hobbyist operating system kernel written in C that demonstrates basic OS concepts.

## Features

- Boots via GRUB with multiboot header
- Initializes VGA text mode display
- Implements keyboard input via polling
- Provides a simple command shell
- Simple modular design

## Commands

The shell supports these basic commands:
- `help` - Display available commands
- `clear` - Clear the screen
- `echo [text]` - Display text on the screen
- `version` - Display kernel version information
- `halt` - Halt the system

## Requirements

To build and run this kernel, you'll need:

1. i386-elf cross-compiler toolchain
2. GRUB2 and tools (including grub-mkrescue)
3. xorriso (for creating the ISO)
4. QEMU (for testing)

## Building the Cross-Compiler

If you don't have the i386-elf toolchain, you can build it using these instructions:

```bash
# Install dependencies (on Ubuntu/Debian)
sudo apt-get install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo

# Define installation directory
export PREFIX="$HOME/opt/cross"
export TARGET=i386-elf
export PATH="$PREFIX/bin:$PATH"

# Download and build binutils
cd /tmp
wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.gz
tar -xf binutils-2.35.tar.gz
mkdir build-binutils
cd build-binutils
../binutils-2.35/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

# Download and build GCC
cd /tmp
wget https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz
tar -xf gcc-10.2.0.tar.gz
mkdir build-gcc
cd build-gcc
../gcc-10.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```

## Building the Kernel

To build the kernel:

```
make
```

This will generate `kernel.elf`. On Linux/macOS, it will also create an ISO file `basickernel.iso`.

### Windows-Specific Instructions

On Windows, the ISO creation is skipped by default since GRUB tools are primarily available on Linux. You have a few options:

1. **Use WSL (Windows Subsystem for Linux)** to build the full ISO:
   ```bash
   wsl make iso
   ```

2. **Use a Linux VM** to build the ISO.

3. **Run directly with QEMU** (without ISO):
   ```
   qemu-system-i386 -kernel kernel.elf
   ```

## Testing with QEMU

To run the kernel in QEMU:

```
make run
```

On Linux/macOS, this will run with `qemu-system-i386 -cdrom basickernel.iso`.
On Windows, this will run with `qemu-system-i386 -kernel kernel.elf`.

## Project Structure

- `kernel.c` - Main kernel file and entry point
- `kernel.h` - Common header for the kernel
- `screen.c` - VGA text mode driver
- `keyboard.c` - Keyboard input driver
- `shell.c` - Command shell implementation
- `linker.ld` - Linker script
- `Makefile` - Build instructions

## Architecture

This is a monolithic kernel design where all components run in kernel mode. The execution flow is:
1. GRUB loads the kernel and transfers control to `kernel_main()`
2. The kernel initializes the screen and keyboard
3. The shell is started and runs in an infinite loop
4. Shell processes commands as they're entered
