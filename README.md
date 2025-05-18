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

1. **Run directly with QEMU** (without ISO):
   ```
   run-qemu.bat
   ```
   or
   ```
   qemu-system-i386 -kernel kernel.elf
   ```

### WSL-Specific Instructions

If you're using Windows Subsystem for Linux (WSL), you have full access to Linux tools, making it easier to build and test the kernel:

1. **Navigate to the project directory**:
   ```bash
   cd /mnt/c/Users/shaig/Desktop/Projects/basicKernel
   ```

2. **Build and run the kernel**:
   ```bash
   chmod +x run-qemu.sh
   ./run-qemu.sh
   ```

3. **Or use make commands directly**:
   ```bash
   make        # Build the kernel and ISO
   make run    # Run the kernel in QEMU
   ```

The WSL environment will automatically install any missing dependencies (QEMU, GRUB tools, etc.) when needed.

## Testing with QEMU

### Setting up QEMU on Windows

1. Download QEMU from the [official website](https://www.qemu.org/download/#windows)
   - For Windows, you can use the installer from [QEMU-Windows](https://qemu.weilnetz.de/w64/)
   
2. During installation:
   - Make sure to select the option to add QEMU to your PATH
   - Install the i386 system emulation

### Running the Kernel

To run the kernel in QEMU:

```
make run
```

On Linux/macOS, this will run with `qemu-system-i386 -cdrom basickernel.iso`.
On Windows, this will run with `qemu-system-i386 -kernel kernel.elf`.

If QEMU is installed but not in your PATH, you can use:

```
make qemu-run
```

This will prompt you to enter the full path to qemu-system-i386.exe (e.g., `C:\Program Files\qemu\qemu-system-i386.exe`).

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
