/*
  This program copies the buttons to the leds while printing a message in the uart
*/

#include <stdint.h>
#include "../memmap.h"

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 9600

static void uart_putc(char c) {
    while (!(UART_STATUS & UART_STATUS_TX_READY));
    UART_DATA = c;
}

static void uart_puts(const char *str) {
    char c;
    while ((c = *str++)) {
        uart_putc(c);
    }
}

static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

int main() {
    UART_BAUD = FREQ / BAUD_RATE;
    LEDS = 0xAA;

    for (;;) {
        uart_puts("Press buttons, should turn on leds!\r\n");
        LEDS = ~BUTTONS; 
        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }
}
