/*
 * kernel.h - Main header file for basicKernel
 */

#ifndef KERNEL_H
#define KERNEL_H

/* For IntelliSense compatibility with GCC extensions */
#ifdef _MSC_VER
/* Microsoft Visual C++ specific definitions */
#define __attribute__(x)
#define __volatile__ 
#define __asm__ __asm
#define HALT() __asm { hlt }
#else
/* GCC/Clang specific */
#define HALT() __asm__ __volatile__("hlt")
#endif

/* Standard typedefs for convenience */
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

/* Function declarations for other modules */
void screen_init(void);
void screen_clear(void);
void kputchar(char c);
void kprintf(const char* format, ...);
void itoa(int value, char* str, int base);
void keyboard_init(void);
char keyboard_read(void);
void shell_init(void);

#endif /* KERNEL_H */
