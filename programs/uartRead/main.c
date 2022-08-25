/*
  This program reads the uart
*/


#include <stdint.h>
#include "../memmap.h"
#include "../uart.h"
#include "../delay.h"

int main() {
    uart_init();
    LEDS = 0xA;
    char cmd;
    uart_puts("UART read example!\r\n");
    for (;;) {
        cmd = uart_getc();
	switch (cmd) {
            case 0: 
                LEDS = ~LEDS;
                delay();
            break;
            case 'a':
                LEDS = 0;
            break;
            case 'b': 
                LEDS = 0xF;
            break;
            case 'c':
                LEDS = 0xA;
            break;
            case '1':
                LEDS = 0x1;
            break;
            case '2':
                LEDS = 0x2;
            break;
            case '3':
                LEDS = 0x4;
            break;
            case '4':
                LEDS = 0x8;
            break;
 	     
	    default:
               uart_puts("Unknown command\r\n");
	    break;
	}
    }
}
