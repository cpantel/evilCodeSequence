/*
  This program copies buttons to leds, copies pmod0 to pmod1, prints a message to the uart and shifts a led in arduino
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
    unsigned int shift = 0x01010101;
    UART_BAUD = FREQ / BAUD_RATE;

    for (;;) {
        uart_puts("Press buttons, should turn on leds, while the arduino connector shifts and pmod0 mimics pmod1!\r\n");
        LEDS = ~BUTTONS;
        PMOD0 = PMOD1;

        ARDUINO = shift;
        shift = shift << 1;
        if (shift == 0x01010100) {
          shift |= 1;
        }

        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }
}
