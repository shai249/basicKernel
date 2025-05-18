/*
 * shell.c - Simple command shell
 * Provides a basic user interface for the kernel
 */

#include "kernel.h"

/* Function declarations for string utilities used in this file */
static int strcmp(const char* s1, const char* s2);
static int strncmp(const char* s1, const char* s2, int n);

#define COMMAND_BUFFER_SIZE 256
#define SHELL_PROMPT "basicKernel> "

/* Buffer for storing command input */
static char command_buffer[COMMAND_BUFFER_SIZE];

/*
 * Read a line of input from the keyboard
 */
static void readline(char* buffer, int max_size) {
    int i = 0;
    char c;
    
    while (1) {
        /* Read a character */
        c = keyboard_read();
        
        if (c == 0) {
            /* Skip key release events or special keys */
            continue;
        }
        
        if (c == '\n' || c == '\r') {
            /* End of line */
            kputchar('\n');
            buffer[i] = '\0';
            break;
        }
        else if (c == '\b') {
            /* Backspace */
            if (i > 0) {
                i--;
                kputchar('\b');
            }
        }
        else if (i < max_size - 1 && c >= ' ' && c <= '~') {
            /* Regular character */
            buffer[i++] = c;
            kputchar(c);
        }
    }
}

/*
 * Compare two strings
 */
static int strcmp(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *s1 - *s2;
}

/* 
 * These functions are kept for potential future use but marked as unused
 * to prevent compiler warnings with -Werror
 */

#ifdef __GNUC__
/*
 * Copy a string
 */
static char* strcpy(char* dest, const char* src) __attribute__((unused));
static char* strcpy(char* dest, const char* src) {
    char* original = dest;
    while ((*dest++ = *src++));
    return original;
}

/*
 * Get the length of a string
 */
static int strlen(const char* s) __attribute__((unused));
static int strlen(const char* s) {
    int len = 0;
    while (*s++) {
        len++;
    }
    return len;
}
#else
/* Non-GCC version */
static char* strcpy(char* dest, const char* src);
static int strlen(const char* s);
#endif

/*
 * Execute a shell command
 */
static void execute_command(char* command) {
    /* Skip leading spaces */
    while (*command == ' ') {
        command++;
    }
    
    /* Ignore empty commands */
    if (*command == '\0') {
        return;
    }
    
    /* Handle commands */
    if (strcmp(command, "help") == 0) {
        kprintf("Available commands:\n");
        kprintf("  help    - Display this help message\n");
        kprintf("  clear   - Clear the screen\n");
        kprintf("  echo    - Echo text to the screen\n");
        kprintf("  halt    - Halt the system\n");
        kprintf("  version - Display kernel version\n");
    }
    else if (strcmp(command, "clear") == 0) {
        screen_clear();
    }
    else if (strncmp(command, "echo ", 5) == 0) {
        kprintf("%s\n", command + 5);
    }    else if (strcmp(command, "halt") == 0) {
        kprintf("System halted. You may now turn off your computer.\n");
        while (1) {
            HALT();
        }
    }
    else if (strcmp(command, "version") == 0) {
        kprintf("BasicKernel v0.1\n");
    }
    else {
        kprintf("Unknown command: %s\n", command);
    }
}

/*
 * Compare strings up to n characters
 */
static int strncmp(const char* s1, const char* s2, int n) {
    for (int i = 0; i < n; i++) {
        if (s1[i] != s2[i]) {
            return s1[i] - s2[i];
        }
        if (s1[i] == '\0') {
            return 0;
        }
    }
    return 0;
}

/*
 * Initialize and run the shell
 */
void shell_init() {
    while (1) {
        kprintf(SHELL_PROMPT);
        readline(command_buffer, COMMAND_BUFFER_SIZE);
        execute_command(command_buffer);
    }
}
