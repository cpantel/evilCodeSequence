/*
  This program implements a SW kitt
*/

#include <stdint.h>
#include "../memmap.h"
#include "../uart.h"
#include "../delay.h"


int main() {
    uart_init();

    uart_puts("KITT starting\r\n");
    for (;;) {
        LEDS = 1;
        delay();
        LEDS = 2;
        delay();
        LEDS = 4;
        delay();
        LEDS = 8;
        delay();
        LEDS = 4;
        delay();
        LEDS = 2;
        delay();
        uart_puts("KITT .\r\n");
    }
}
