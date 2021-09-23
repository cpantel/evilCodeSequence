#include <stdint.h>

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define BUTTONS     *((volatile uint32_t *) 0x00010004)
#define PMOD0       *((volatile uint32_t *) 0x00010008)
#define PMOD1       *((volatile uint32_t *) 0x0001000c)
#define ARDUINO     *((volatile uint32_t *) 0x00010010)
#define RTC         *((volatile uint32_t *) 0x00010014)
#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)
#define MTIME       *((volatile uint64_t *) 0x00030000)
#define MTIMECMP    *((volatile uint64_t *) 0x00030008)

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
//    char msg[] = "RTC: ..:..\r\n";
//    char msg[11] = {'R','T','C',':',' ','.','.',':','.','.','\r','\n'};
    char msg[13];
    msg[0]='R';
    msg[1]='T';
    msg[2]='C';
    msg[3]=':';
    msg[4]=' ';
    msg[5]='.';
    msg[6]='.';
    msg[7]=':';
    msg[8]='.';
    msg[9]='.';
    msg[10]='\r';
    msg[11]='\n';
    msg[12]='\0';

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
