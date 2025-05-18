/*
 * screen.c - VGA text mode screen driver for basicKernel
 * Handles writing text to the screen in 80x25 text mode
 */

#include "kernel.h"

/* VGA text mode constants */
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_BASE_ADDR 0xB8000

/* Default color: White text on black background */
#define DEFAULT_COLOR 0x0F

/* Current cursor position */
static uint8_t cursor_x = 0;
static uint8_t cursor_y = 0;
static uint8_t text_color = DEFAULT_COLOR;

/*
 * Initialize screen
 */
void screen_init() {
    text_color = DEFAULT_COLOR;
    cursor_x = 0;
    cursor_y = 0;
}

/*
 * Clear the screen by filling it with spaces
 */
void screen_clear() {
    uint16_t* vga_buffer = (uint16_t*)VGA_BASE_ADDR;
    uint16_t blank = (text_color << 8) | ' ';
    
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = blank;
    }
    
    cursor_x = 0;
    cursor_y = 0;
}

/*
 * Scroll the screen up one line if needed
 */
static void screen_scroll() {
    if (cursor_y >= VGA_HEIGHT) {
        uint16_t* vga_buffer = (uint16_t*)VGA_BASE_ADDR;
        
        /* Move each line up one position */
        for (int i = 0; i < (VGA_HEIGHT - 1) * VGA_WIDTH; i++) {
            vga_buffer[i] = vga_buffer[i + VGA_WIDTH];
        }
        
        /* Clear the last line */
        uint16_t blank = (text_color << 8) | ' ';
        for (int i = (VGA_HEIGHT - 1) * VGA_WIDTH; i < VGA_HEIGHT * VGA_WIDTH; i++) {
            vga_buffer[i] = blank;
        }
        
        cursor_y = VGA_HEIGHT - 1;
    }
}

/*
 * Write a character to the screen at current cursor position
 */
void kputchar(char c) {
    uint16_t* vga_buffer = (uint16_t*)VGA_BASE_ADDR;
    
    if (c == '\n') {
        /* New line */
        cursor_x = 0;
        cursor_y++;
        screen_scroll();
    }
    else if (c == '\r') {
        /* Carriage return */
        cursor_x = 0;
    }
    else if (c == '\b') {
        /* Backspace */
        if (cursor_x > 0) {
            cursor_x--;
            vga_buffer[cursor_y * VGA_WIDTH + cursor_x] = (text_color << 8) | ' ';
        }
    }
    else if (c >= ' ') {
        /* Regular character */
        vga_buffer[cursor_y * VGA_WIDTH + cursor_x] = (text_color << 8) | c;
        cursor_x++;
        
        /* Wrap to next line if needed */
        if (cursor_x >= VGA_WIDTH) {
            cursor_x = 0;
            cursor_y++;
            screen_scroll();
        }
    }
}

/*
 * Simple printf-like function
 * Only handles a minimal subset of formatting:
 * %c (character), %s (string), %d (integer), %x (hex)
 */
void kprintf(const char* format, ...) {
    char** arg = (char**)&format;
    int c;
    char buf[20];
    
    arg++;
    
    while ((c = *format++) != 0) {
        if (c != '%') {
            kputchar(c);
        } else {
            char* p;
            c = *format++;
            switch (c) {
                case 'd':
                case 'u':
                case 'x':
                    /* Convert integer to string */
                    itoa(*((int*)arg++), buf, (c == 'x') ? 16 : 10);
                    p = buf;
                    goto string;
                    break;
                case 's':
                    /* Print string */
                    p = *arg++;
                    if (!p)
                        p = "(null)";
                string:
                    while (*p)
                        kputchar(*p++);
                    break;
                case 'c':
                    /* Print character */
                    kputchar(*((int*)arg++));
                    break;
                default:
                    kputchar(*((int*)arg++));
                    break;
            }
        }
    }
}

/*
 * Simple itoa implementation (not in standard library)
 * Convert integer to string in the specified base
 */
void itoa(int value, char* str, int base) {
    char* ptr = str;
    char* ptr1 = str;
    char tmp_char;
    int tmp_value;
    
    /* Handle negative numbers only for base 10 */
    if (value < 0 && base == 10) {
        *ptr++ = '-';
        value = -value;
        ptr1 = ptr;
    }
    
    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "0123456789abcdef"[tmp_value - value * base];
    } while (value);
    
    /* Terminate the string */
    *ptr-- = '\0';
    
    /* Reverse the string */
    while (ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr-- = *ptr1;
        *ptr1++ = tmp_char;
    }
}
