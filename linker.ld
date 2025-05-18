/* 
 * linker.ld - Linker script for basicKernel
 * Defines the memory layout of the kernel
 */

OUTPUT_FORMAT("elf32-i386")
ENTRY(kernel_main)

SECTIONS
{
    /* Begin at 1MB (GRUB loads us here) */
    . = 0x00100000;
    
    /* Make sure multiboot header is near the beginning */
    .text ALIGN(4K) : {
        *(.multiboot)
        *(.text)
    }
    
    /* Read-only data */
    .rodata ALIGN(4K) : {
        *(.rodata)
    }
    
    /* Read-write data (initialized) */
    .data ALIGN(4K) : {
        *(.data)
    }
    
    /* Read-write data (uninitialized) and stack */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss)
    }
}
