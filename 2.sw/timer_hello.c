#include <stdint.h>

#define REG_UART_CLKDIV (*(volatile uint32_t *)0x02000004u)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008u)

#define REG_TIMER_COUNT (*(volatile uint32_t *)0x03000000u)
#define REG_TIMER_HZ (*(volatile uint32_t *)0x03000004u)

#ifndef UART_CLKDIV
#define UART_CLKDIV 234
#endif

#define TIMER_WAIT_TICKS 2700000u

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

static void timer_wait_ticks(uint32_t ticks)
{
    uint32_t start = REG_TIMER_COUNT;

    while ((uint32_t)(REG_TIMER_COUNT - start) < ticks) {
    }
}

void main(void)
{
    REG_UART_CLKDIV = UART_CLKDIV;

    uart_puts("\nTang Nano 9K PicoRV32 timer validation\n");
    uart_puts("Timer count: 0x03000000\n");
    uart_puts("Timer Hz   : 0x03000004\n");
    uart_puts("timer_hz=0x");
    uart_puthex32(REG_TIMER_HZ);
    uart_putc('\n');
    uart_puts("wait_ticks=0x");
    uart_puthex32(TIMER_WAIT_TICKS);
    uart_putc('\n');

    for (;;) {
        uint32_t start = REG_TIMER_COUNT;
        timer_wait_ticks(TIMER_WAIT_TICKS);
        uint32_t end = REG_TIMER_COUNT;

        uart_puts("start=0x");
        uart_puthex32(start);
        uart_puts(" end=0x");
        uart_puthex32(end);
        uart_puts(" delta=0x");
        uart_puthex32(end - start);
        uart_putc('\n');
    }
}
