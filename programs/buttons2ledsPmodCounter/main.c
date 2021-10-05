/*
  This program copies buttons to leds while a counter goes up in pmod0 and a message is printed in the uart
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
    char counter = 0;
    UART_BAUD = FREQ / BAUD_RATE;
    PMOD0 = counter;

    for (;;) {
        uart_puts("Press buttons, should turn on leds, while counter goes up in pmod0!\r\n");
        LEDS = ~BUTTONS;
        PMOD0 = counter++;
        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }
}
