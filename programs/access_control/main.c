/*
  This program waits some time using RTC as reference, reads buttons and conditionally moves the servo while printing messages in the uart and show the FSM state in the leds 
*/

#include <stdint.h>
#include "../memmap.h"

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 9600

#define BARRIER_UP   10
#define BARRIER_DOWN  0

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

enum State {Starting = 1, WaitingRTC, ReadingButtons, BarrierUp, Working, Rejected}; 

int main() {

    UART_BAUD = FREQ / BAUD_RATE; 

    enum State state = Starting;
    char buttons;
    char buttonAuth;
    char buttonReq;
    char position = BARRIER_DOWN;

    char msg[] = "RTC: ..:.. \0";

    for (;;) {
        uint32_t rtc = RTC;

        msg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
        msg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
        msg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
        msg[9] = ( rtc & 0xf ) + '0';
        uart_puts(msg);

        SERVO = position;
        switch (state) {
            case Starting:
                if (rtc >= 0x00000005  ) {
                    state = WaitingRTC; 
                    uart_puts("Waiting until 00:10 to enable buttons\r\n");
                } else {
                    uart_puts("Warming up until 00:05\r\n");
                }
            break;
            case WaitingRTC:
                if (rtc >= 0x00000010  ) {
                    state = ReadingButtons; 
                    uart_puts("It is 00:10, you have up to twenty seconds to push first and last buttons\r\n");
                } else {
                    uart_puts("\r\n");
                }
            break;
            case ReadingButtons:
                buttons = ~BUTTONS;
                buttonReq  = buttons & 8;
                buttonAuth = buttons & 1;
                if (buttonReq == 8  )   {   //// open request
                    if (buttonAuth == 1 ) {  //// auth button
                        state = BarrierUp;
                        position = BARRIER_UP;
                        uart_puts("Raising barrier, hurry!\r\n");  
                    } else {
                        uart_puts("Bad authentication button\r\n");  
                    }
                }
                if (rtc >= 0x00000030) {
                    uart_puts("Time is out, sorry\r\n");
                    state = Rejected;
                } else {
                    uart_puts("\r\n");
                }
            break;
            case BarrierUp:
                if (rtc >= 0x00000030) {
                    uart_puts("Lowering barrier\r\n");
                    position = BARRIER_DOWN;
                    state = Working;
                } else {
                    uart_puts("\r\n");
                }
            break;
            case Working:
                uart_puts("Enjoy\r\n");
            break;
            case Rejected:
                uart_puts("Cry alone\r\n");
            break;

        }
        LEDS = state;

        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }
}
