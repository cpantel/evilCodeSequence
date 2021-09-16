#include <stdint.h>

//  32'b00000000_00000001_00000000_000000??: leds_sel = 1;
//  32'b00000000_00000001_00000000_000001??: buttons_sel =

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define BUTTONS     *((volatile uint32_t *) 0x00010004)
#define PMOD0       *((volatile uint32_t *) 0x00010008)
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
