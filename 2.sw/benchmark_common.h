#ifndef BENCHMARK_COMMON_H
#define BENCHMARK_COMMON_H

#include <stdint.h>

#define REG_UART_CLKDIV (*(volatile uint32_t *)0x02000004u)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008u)

#define REG_TIMER_COUNT (*(volatile uint32_t *)0x03000000u)
#define REG_TIMER_HZ (*(volatile uint32_t *)0x03000004u)
#define REG_TIMER_IRQ_ENABLE (*(volatile uint32_t *)0x03000008u)
#define REG_TIMER_IRQ_PENDING (*(volatile uint32_t *)0x0300000Cu)
#define REG_TIMER_IRQ_PERIOD (*(volatile uint32_t *)0x03000010u)
#define REG_TIMER_IRQ_COUNTDOWN (*(volatile uint32_t *)0x03000014u)
#define REG_TIMER_IRQ_EVENT_COUNT (*(volatile uint32_t *)0x03000018u)

#ifndef UART_CLKDIV
#define UART_CLKDIV 234
#endif

#ifndef BENCHMARK_SAMPLES
#define BENCHMARK_SAMPLES 256u
#endif

#ifndef TIMER_IRQ_PERIOD_TICKS
#define TIMER_IRQ_PERIOD_TICKS 27000u
#endif
#define IRQ5_MASK (1u << 5)

static inline void uart_putc(char c)
{
    if (c == '\n') {
        uart_putc('\r');
    }

    REG_UART_DATA = (uint32_t)(uint8_t)c;
}

static inline void uart_puts(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

static inline void uart_puthex32(uint32_t value)
{
    static const char digits[] = "0123456789ABCDEF";

    for (int shift = 28; shift >= 0; shift -= 4) {
        uart_putc(digits[(value >> shift) & 0xFu]);
    }
}

static inline void uart_putdec32(uint32_t value)
{
    char buf[10];
    int pos = 0;

    if (value == 0) {
        uart_putc('0');
        return;
    }

    while (value != 0 && pos < (int)sizeof(buf)) {
        buf[pos++] = (char)('0' + (value % 10u));
        value /= 10u;
    }

    while (pos > 0) {
        uart_putc(buf[--pos]);
    }
}

static inline void benchmark_print_metric(const char *name, uint32_t ticks)
{
    uart_puts(name);
    uart_putc(',');
    uart_putdec32(ticks);
    uart_putc(',');
    uart_putdec32((ticks * 1000u) / 27u);
    uart_putc('\n');
}

static inline void benchmark_print_header(const char *name)
{
    REG_UART_CLKDIV = UART_CLKDIV;

    uart_putc('\n');
    uart_puts(name);
    uart_putc('\n');
    uart_puts("timer_hz,");
    uart_putdec32(REG_TIMER_HZ);
    uart_putc('\n');
    uart_puts("period_ticks,");
    uart_putdec32(TIMER_IRQ_PERIOD_TICKS);
    uart_putc('\n');
    uart_puts("samples,");
    uart_putdec32(BENCHMARK_SAMPLES);
    uart_putc('\n');
    uart_puts("metric,ticks,ns\n");
}

#endif
