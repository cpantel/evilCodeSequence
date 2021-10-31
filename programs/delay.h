static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

void delay() {
    uint32_t start = rdcycle();
    while ((rdcycle() - start) <= FREQ);
}
