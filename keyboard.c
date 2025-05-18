/*
 * keyboard.c - Simple keyboard driver using polling
 * Handles basic keyboard input without interrupts
 */

#include "kernel.h"

/* IO ports for the keyboard controller */
#define KBD_DATA_PORT 0x60
#define KBD_STATUS_PORT 0x64

/* Keyboard status flags */
#define KBD_OUTPUT_FULL 0x01

/* Key mappings for US QWERTY keyboard */
static char kbd_us[128] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    '-', '=', '\b', '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u',
    'i', 'o', 'p', '[', ']', '\n', 0, 'a', 's', 'd', 'f', 'g',
    'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c',
    'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

/*
 * Initialize the keyboard
 */
void keyboard_init() {
    /* Nothing to initialize for polling mode */
}

/*
 * Read a byte from an I/O port
 */
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
#ifdef _MSC_VER
    /* MSVC inline assembly */
    __asm {
        mov dx, port
        in al, dx
        mov ret, al
    }
#else
    /* GCC/Clang inline assembly */
    __asm__ __volatile__ ("inb %1, %0" : "=a" (ret) : "Nd" (port));
#endif
    return ret;
}

/*
 * Check if a key is available to read
 */
static int keyboard_available() {
    return inb(KBD_STATUS_PORT) & KBD_OUTPUT_FULL;
}

/*
 * Read a character from the keyboard (blocking)
 * This uses polling, not interrupts
 */
char keyboard_read() {
    static int shift = 0;
    uint8_t scancode;
    char c = 0;
    
    /* Wait until a key is pressed */
    while (!keyboard_available());
    
    /* Read the scancode */
    scancode = inb(KBD_DATA_PORT);
    
    /* Handle key release (bit 7 set) */
    if (scancode & 0x80) {
        /* Key released, check if it was shift */
        if (scancode == 0xAA || scancode == 0xB6) {
            shift = 0;
        }
        return 0; /* Ignore key release events */
    } else {
        /* Handle shift key press */
        if (scancode == 0x2A || scancode == 0x36) {
            shift = 1;
            return 0;
        }
        
        /* Convert scancode to ASCII */
        c = kbd_us[scancode];
        
        /* Apply shift if needed */
        if (shift) {
            if (c >= 'a' && c <= 'z') {
                c -= 32; /* Convert to uppercase */
            } else {
                /* Handle other shifted characters */
                switch (c) {
                    case '1': c = '!'; break;
                    case '2': c = '@'; break;
                    case '3': c = '#'; break;
                    case '4': c = '$'; break;
                    case '5': c = '%'; break;
                    case '6': c = '^'; break;
                    case '7': c = '&'; break;
                    case '8': c = '*'; break;
                    case '9': c = '('; break;
                    case '0': c = ')'; break;
                    case '-': c = '_'; break;
                    case '=': c = '+'; break;
                    case '[': c = '{'; break;
                    case ']': c = '}'; break;
                    case ';': c = ':'; break;
                    case '\'': c = '"'; break;
                    case '\\': c = '|'; break;
                    case ',': c = '<'; break;
                    case '.': c = '>'; break;
                    case '/': c = '?'; break;
                    case '`': c = '~'; break;
                }
            }
        }
    }
    
    return c;
}
