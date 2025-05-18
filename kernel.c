/*
 * kernel.c - Main kernel file for basicKernel
 * This is the entry point for our kernel after GRUB hands over control
 */

#include "kernel.h"

/* Multiboot header for GRUB compatibility */
#define MULTIBOOT_MAGIC 0x1BADB002
#define MULTIBOOT_FLAGS 0x00000003
#define MULTIBOOT_CHECKSUM -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

/* Multiboot header structure required by GRUB */
/* Multiboot header with section attribute for GCC/Clang */
__attribute__((section(".multiboot")))
unsigned int multiboot_header[] = {
    MULTIBOOT_MAGIC,
    MULTIBOOT_FLAGS,
    MULTIBOOT_CHECKSUM
};

/* Kernel stack */
#define STACK_SIZE 0x4000 /* 16 KB */
/* Aligned kernel stack (16 bytes alignment) - marked unused to avoid compiler warnings */
static char kernel_stack[STACK_SIZE] __attribute__((aligned(16))) __attribute__((unused));

/* Kernel entry point */
void kernel_main() {
    /* Initialize the screen */
    screen_init();
    screen_clear();
    
    /* Display welcome message */
    kprintf("BasicKernel v0.1\n");
    kprintf("A simple hobbyist operating system\n");
    kprintf("-------------------------------------\n\n");
    
    /* Initialize keyboard */
    keyboard_init();
    
    /* Start the shell */
    shell_init();
    
    /* Shell should never return, but just in case */
    kprintf("\nKernel halted. System is now idle.\n");    /* Halt the CPU */
    while (1) {
        HALT();
    }
}
