#include <stdint.h>


#define LEDS        *((volatile uint32_t *) 0x00010000)
#define BUTTONS     *((volatile uint32_t *) 0x00010004)
#define PMOD0       *((volatile uint32_t *) 0x00010008)
#define PMOD1       *((volatile uint32_t *) 0x0001000c)
#define ARDUINO     *((volatile uint32_t *) 0x00010010)
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
