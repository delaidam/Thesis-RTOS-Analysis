#include "benchmark_common.h"

extern volatile uint32_t irq_count;
extern volatile uint32_t last_irq_pending;
extern volatile uint32_t irq_latency_samples;
extern volatile uint32_t irq_latency_min;
extern volatile uint32_t irq_latency_max;
extern volatile uint32_t irq_latency_total;
extern volatile uint32_t irq_interval_samples;
extern volatile uint32_t irq_interval_min;
extern volatile uint32_t irq_interval_max;
extern volatile uint32_t irq_interval_total;

void picorv32_set_irq_mask(uint32_t mask);

static void reset_irq_stats(void)
{
    irq_count = 0;
    last_irq_pending = 0;
    irq_latency_samples = 0;
    irq_latency_min = 0;
    irq_latency_max = 0;
    irq_latency_total = 0;
    irq_interval_samples = 0;
    irq_interval_min = 0;
    irq_interval_max = 0;
    irq_interval_total = 0;
}

void main(void)
{
    benchmark_print_header("Tang Nano 9K PicoRV32 IRQ latency benchmark");
    reset_irq_stats();

    REG_TIMER_IRQ_ENABLE = 0;
    REG_TIMER_IRQ_PENDING = 1;
    REG_TIMER_IRQ_PERIOD = TIMER_IRQ_PERIOD_TICKS;

    picorv32_set_irq_mask(~IRQ5_MASK);
    REG_TIMER_IRQ_ENABLE = 1;

    while (irq_latency_samples < BENCHMARK_SAMPLES) {
    }

    REG_TIMER_IRQ_ENABLE = 0;
    picorv32_set_irq_mask(0xffffffffu);

    benchmark_print_metric("irq_latency_min", irq_latency_min);
    benchmark_print_metric("irq_latency_avg", irq_latency_total / irq_latency_samples);
    benchmark_print_metric("irq_latency_max", irq_latency_max);
    benchmark_print_metric("irq_interval_min", irq_interval_min);
    benchmark_print_metric("irq_interval_avg", irq_interval_total / irq_interval_samples);
    benchmark_print_metric("irq_interval_max", irq_interval_max);

    uart_puts("irq_count,");
    uart_putdec32(irq_count);
    uart_putc('\n');
    uart_puts("pending_seen_hex,0x");
    uart_puthex32(last_irq_pending);
    uart_putc('\n');

    for (;;) {
    }
}
