#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 9600

static void uart_init() {
    UART_BAUD = FREQ / BAUD_RATE;
}

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

static char uart_getc() {
    if ( UART_STATUS & UART_STATUS_RX_READY) {
        return UART_DATA;
    }
    return 0;
}

