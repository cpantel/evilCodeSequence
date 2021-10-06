/*
  This program blinks the leds while printing a message in the uart with the RTC data and copies it to de arduino too.
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

    char msg[] = "RTC: ..:.. \r\n\0";

    for (;;) {
        uint32_t rtc = RTC;
        ARDUINO = rtc;
        msg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
        msg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
        msg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
        msg[9] = ( rtc & 0xf ) + '0';
        uart_puts(msg);
        LEDS = ~LEDS;
        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }

}
