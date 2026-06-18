#define BENCHMARK_SAMPLES 32u
#define TIMER_IRQ_PERIOD_TICKS 270000u

#include "benchmark_common.h"

#define ALERT_THRESHOLD 850u
#define ALERT_DEADLINE_CYCLES 12000u
#define ALERT_PROCESSING_LOOPS 192u

extern volatile uint32_t irq_count;
extern volatile uint32_t last_irq_pending;
extern volatile uint32_t irq_timestamp;
extern volatile uint32_t irq_event_timestamp;
extern volatile uint32_t irq_latency_last;

void picorv32_set_irq_mask(uint32_t mask);

static uint32_t synthetic_sensor_value(uint32_t event_id)
{
    uint32_t value = (event_id * 137u + 211u) % 1024u;

    if ((event_id % 8u) == 0u) {
        value = 930u + (event_id % 64u);
    }

    return value;
}

static void simulate_processing(uint32_t loops)
{
    volatile uint32_t sink = 0;

    for (uint32_t i = 0; i < loops; i++) {
        sink += (i * 17u) ^ (sink >> 1);
    }
}

static void uart_putdec_padded(uint32_t value, uint32_t width)
{
    uint32_t divisor = 1;

    for (uint32_t i = 1; i < width; i++) {
        divisor *= 10u;
    }

    while (divisor > 1u && value < divisor) {
        uart_putc('0');
        divisor /= 10u;
    }

    uart_putdec32(value);
}

static void print_event_line(
    uint32_t event_id,
    uint32_t sensor,
    const char *status,
    uint32_t latency,
    uint32_t missed_deadline)
{
    uart_puts("event=");
    uart_putdec_padded(event_id, 3u);
    uart_puts(" sensor=");
    uart_putdec_padded(sensor, 3u);
    uart_puts(" status=");
    uart_puts(status);

    if (status[0] == 'O') {
        uart_puts("     ");
    } else {
        uart_putc(' ');
    }

    uart_puts("latency=");
    uart_putdec32(latency);
    uart_puts(" cycles deadline=");
    uart_puts(missed_deadline ? "MISS" : "OK");
    uart_putc('\n');
}

void main(void)
{
    uint32_t printed_irq_count = 0;
    uint32_t events = 0;
    uint32_t alerts = 0;
    uint32_t missed_deadlines = 0;
    uint32_t missed_events = 0;
    uint32_t latency_total = 0;
    uint32_t latency_max = 0;

    REG_UART_CLKDIV = UART_CLKDIV;

    uart_puts("\nTiny Real-Time Monitor Demo\n");
    uart_puts("Target: Tang Nano 9K / PicoRV32\n");
    uart_puts("Mode: interrupt-driven\n");
    uart_puts("Deadline: ");
    uart_putdec32(ALERT_DEADLINE_CYCLES);
    uart_puts(" cycles\n");
    uart_puts("Threshold: ");
    uart_putdec32(ALERT_THRESHOLD);
    uart_puts(" synthetic sensor units\n");
    uart_puts("Timer period: ");
    uart_putdec32(TIMER_IRQ_PERIOD_TICKS);
    uart_puts(" cycles\n\n");
    uart_puts("This is a timing-path demo, not a medical or safety device.\n\n");

    irq_count = 0;
    last_irq_pending = 0;

    REG_TIMER_IRQ_ENABLE = 0;
    REG_TIMER_IRQ_PENDING = 1;
    REG_TIMER_IRQ_PERIOD = TIMER_IRQ_PERIOD_TICKS;

    picorv32_set_irq_mask(~IRQ5_MASK);
    REG_TIMER_IRQ_ENABLE = 1;

    while (events < BENCHMARK_SAMPLES) {
        while (irq_count == printed_irq_count) {
        }

        uint32_t previous_irq_count = printed_irq_count;
        printed_irq_count = irq_count;

        if (printed_irq_count > previous_irq_count + 1u) {
            missed_events += printed_irq_count - previous_irq_count - 1u;
        }

        uint32_t event_id = printed_irq_count;
        uint32_t t_event = irq_event_timestamp;
        uint32_t sensor = synthetic_sensor_value(event_id);
        const char *status = (sensor >= ALERT_THRESHOLD) ? "ALERT" : "OK";

        simulate_processing(ALERT_PROCESSING_LOOPS);
        uint32_t t_alert = REG_TIMER_COUNT;
        uint32_t alert_latency = t_alert - t_event;
        uint32_t missed_deadline = alert_latency > ALERT_DEADLINE_CYCLES;

        events++;
        latency_total += alert_latency;

        if (alert_latency > latency_max) {
            latency_max = alert_latency;
        }

        if (sensor >= ALERT_THRESHOLD) {
            alerts++;
        }

        if (missed_deadline) {
            missed_deadlines++;
        }

        print_event_line(event_id, sensor, status, alert_latency, missed_deadline);
    }

    REG_TIMER_IRQ_ENABLE = 0;
    picorv32_set_irq_mask(0xffffffffu);

    uart_puts("\nSummary:\n");
    uart_puts("events=");
    uart_putdec32(events);
    uart_putc('\n');
    uart_puts("alerts=");
    uart_putdec32(alerts);
    uart_putc('\n');
    uart_puts("avg_latency=");
    uart_putdec32(latency_total / events);
    uart_puts(" cycles\n");
    uart_puts("max_latency=");
    uart_putdec32(latency_max);
    uart_puts(" cycles\n");
    uart_puts("missed_deadlines=");
    uart_putdec32(missed_deadlines);
    uart_putc('\n');
    uart_puts("missed_events=");
    uart_putdec32(missed_events);
    uart_putc('\n');

    uart_puts("\nCSV summary:\n");
    uart_puts("events,alerts,avg_latency_cycles,max_latency_cycles,missed_deadlines,missed_events\n");
    uart_putdec32(events);
    uart_putc(',');
    uart_putdec32(alerts);
    uart_putc(',');
    uart_putdec32(latency_total / events);
    uart_putc(',');
    uart_putdec32(latency_max);
    uart_putc(',');
    uart_putdec32(missed_deadlines);
    uart_putc(',');
    uart_putdec32(missed_events);
    uart_putc('\n');

    for (;;) {
    }
}
