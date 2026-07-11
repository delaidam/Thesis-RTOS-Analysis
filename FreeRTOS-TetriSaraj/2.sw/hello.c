#include <stdint.h>

#define REG_UART_CLKDIV (*(volatile uint32_t *)0x02000004u)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008u)

#ifndef UART_CLKDIV
#define UART_CLKDIV 562
#endif

static void uart_putc(char c)
{
    if (c == '\n') {
        uart_putc('\r');
    }

    REG_UART_DATA = (uint32_t)(uint8_t)c;
}

static void uart_puts(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

static void uart_puthex32(uint32_t value)
{
    static const char digits[] = "0123456789ABCDEF";

    for (int shift = 28; shift >= 0; shift -= 4) {
        uart_putc(digits[(value >> shift) & 0xFu]);
    }
}

void main(void)
{
    uint32_t counter = 0;

    REG_UART_CLKDIV = UART_CLKDIV;

    uart_puts("\nTang Nano 9K PicoRV32 UART hello\n");
    uart_puts("UART base: 0x02000000\n");
    uart_puts("TX data : 0x02000008\n");

    for (;;) {
        uart_puts("hello counter=0x");
        uart_puthex32(counter++);
        uart_putc('\n');

        for (volatile uint32_t delay = 0; delay < 500000u; delay++) {
        }
    }
}
