#define BENCHMARK_SAMPLES 64u
#define TIMER_IRQ_PERIOD_TICKS 270000u

#include "benchmark_common.h"

extern volatile uint32_t irq_count;
extern volatile uint32_t irq_event_timestamp;

void picorv32_set_irq_mask(uint32_t mask);

static void busy_work(uint32_t loops)
{
    volatile uint32_t sink = 0x12345678u;

    for (uint32_t i = 0; i < loops; i++) {
        sink = (sink << 3) ^ (sink >> 2) ^ i;
    }
}

static void reset_timer_irq(void)
{
    irq_count = 0;
    REG_TIMER_IRQ_ENABLE = 0;
    REG_TIMER_IRQ_PENDING = 1;
    REG_TIMER_IRQ_PERIOD = TIMER_IRQ_PERIOD_TICKS;
    REG_TIMER_IRQ_ENABLE = 1;
}

static void run_level(uint32_t loops)
{
    uint32_t seen = 0;
    uint32_t latency_min = 0;
    uint32_t latency_max = 0;
    uint32_t latency_total = 0;
    uint32_t missed_events = 0;

    reset_timer_irq();

    while (seen < BENCHMARK_SAMPLES) {
        while (irq_count == seen) {
        }

        uint32_t new_count = irq_count;

        if (new_count > seen + 1u) {
            missed_events += new_count - seen - 1u;
        }

        seen = new_count;
        uint32_t t_event = irq_event_timestamp;
        busy_work(loops);
        uint32_t latency = REG_TIMER_COUNT - t_event;

        if (latency_min == 0 || latency < latency_min) {
            latency_min = latency;
        }

        if (latency > latency_max) {
            latency_max = latency;
        }

        latency_total += latency;
    }

    REG_TIMER_IRQ_ENABLE = 0;

    uart_putdec32(loops);
    uart_putc(',');
    uart_putdec32(BENCHMARK_SAMPLES);
    uart_putc(',');
    uart_putdec32(latency_min);
    uart_putc(',');
    uart_putdec32(latency_total / BENCHMARK_SAMPLES);
    uart_putc(',');
    uart_putdec32(latency_max);
    uart_putc(',');
    uart_putdec32(missed_events);
    uart_putc('\n');
}

void main(void)
{
    static const uint32_t workloads[] = {0u, 64u, 256u, 1024u, 4096u, 8192u};

    REG_UART_CLKDIV = UART_CLKDIV;

    uart_puts("\nTang Nano 9K workload sweep demo\n");
    uart_puts("period_ticks,");
    uart_putdec32(TIMER_IRQ_PERIOD_TICKS);
    uart_putc('\n');
    uart_puts("workload_loops,samples,latency_min,latency_avg,latency_max,missed_events\n");

    picorv32_set_irq_mask(~IRQ5_MASK);

    for (uint32_t i = 0; i < sizeof(workloads) / sizeof(workloads[0]); i++) {
        run_level(workloads[i]);
    }

    picorv32_set_irq_mask(0xffffffffu);

    for (;;) {
    }
}
