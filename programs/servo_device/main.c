/*
  This program changes the server position based upon buttons input
*/

#include <stdint.h>
#include "../memmap.h"

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 9600

#define MAX_POS 10

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
    signed char position = 0;
    char buttons;
    UART_BAUD = FREQ / BAUD_RATE; 
    LEDS = 0xAA;

    char msg[15];
    msg[0]='B';
    msg[1]='u';
    msg[2]='t';
    msg[3]='t';
    msg[4]='o';
    msg[5]='n';
    msg[6]='s';
    msg[7]=':';
    msg[8]='.';
    msg[9]='.';
    msg[10]='.';
    msg[11]='.';
    msg[12]='\r';
    msg[13]='\n';
    msg[14]='\0';

    for (;;) {
        SERVO = position;
        buttons = ~BUTTONS;
        LEDS = ~LEDS;

        msg[8] =  ((buttons & 1 )      ) + '0';
        msg[9] =  ((buttons & 2 ) >> 1 ) + '0';
        msg[10] = ((buttons & 4 ) >> 2 ) + '0';
        msg[11] = ((buttons & 8 ) >> 3 ) + '0';
        uart_puts(msg);
        if ((buttons & 8 ) >> 3 ) {
            position = MAX_POS;
        } else if (buttons & 1 ) {
            position = 0;
        } else if ((buttons & 2 ) >> 1 ) {
            --position;
            if (position < 0 ) position = 0;
        } else if ((buttons & 4 ) >> 2 ) {
            ++position;
            if (position > MAX_POS) position = MAX_POS;
        }

        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }

}
