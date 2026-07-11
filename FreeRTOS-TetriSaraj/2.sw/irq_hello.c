#include <stdint.h>

#define REG_UART_CLKDIV (*(volatile uint32_t *)0x02000004u)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008u)

#define REG_TIMER_COUNT (*(volatile uint32_t *)0x03000000u)
#define REG_TIMER_HZ (*(volatile uint32_t *)0x03000004u)
#define REG_TIMER_IRQ_ENABLE (*(volatile uint32_t *)0x03000008u)
#define REG_TIMER_IRQ_PENDING (*(volatile uint32_t *)0x0300000Cu)
#define REG_TIMER_IRQ_PERIOD (*(volatile uint32_t *)0x03000010u)
#define REG_TIMER_IRQ_COUNTDOWN (*(volatile uint32_t *)0x03000014u)

#ifndef UART_CLKDIV
#define UART_CLKDIV 234
#endif

#define TIMER_IRQ_PERIOD_TICKS 2700000u
#define IRQ5_MASK (1u << 5)

extern volatile uint32_t irq_count;
extern volatile uint32_t last_irq_pending;

void picorv32_set_irq_mask(uint32_t mask);

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
    uint32_t printed_irq_count = 0;

    REG_UART_CLKDIV = UART_CLKDIV;

    uart_puts("\nTang Nano 9K PicoRV32 IRQ validation\n");
    uart_puts("Timer count       : 0x03000000\n");
    uart_puts("Timer IRQ enable  : 0x03000008\n");
    uart_puts("Timer IRQ pending : 0x0300000C\n");
    uart_puts("Timer IRQ period  : 0x03000010\n");
    uart_puts("timer_hz=0x");
    uart_puthex32(REG_TIMER_HZ);
    uart_putc('\n');
    uart_puts("irq_period=0x");
    uart_puthex32(TIMER_IRQ_PERIOD_TICKS);
    uart_putc('\n');

    irq_count = 0;
    last_irq_pending = 0;

    REG_TIMER_IRQ_ENABLE = 0;
    REG_TIMER_IRQ_PENDING = 1;
    REG_TIMER_IRQ_PERIOD = TIMER_IRQ_PERIOD_TICKS;

    picorv32_set_irq_mask(~IRQ5_MASK);
    REG_TIMER_IRQ_ENABLE = 1;

    uart_puts("IRQ5 unmasked, waiting for timer interrupts...\n");

    for (;;) {
        while (irq_count == printed_irq_count) {
        }

        printed_irq_count = irq_count;

        uart_puts("irq_count=0x");
        uart_puthex32(printed_irq_count);
        uart_puts(" pending_seen=0x");
        uart_puthex32(last_irq_pending);
        uart_puts(" hw_pending=0x");
        uart_puthex32(REG_TIMER_IRQ_PENDING);
        uart_puts(" timer=0x");
        uart_puthex32(REG_TIMER_COUNT);
        uart_putc('\n');
    }
}
