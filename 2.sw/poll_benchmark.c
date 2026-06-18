#include "benchmark_common.h"

static uint32_t latency_min;
static uint32_t latency_max;
static uint32_t latency_total;
static uint32_t interval_min;
static uint32_t interval_max;
static uint32_t interval_total;

void picorv32_set_irq_mask(uint32_t mask);

static void update_stats(uint32_t sample, uint32_t *min, uint32_t *max, uint32_t *total)
{
    if (*min == 0 || sample < *min) {
        *min = sample;
    }

    if (sample > *max) {
        *max = sample;
    }

    *total += sample;
}

void main(void)
{
    uint32_t samples = 0;
    uint32_t interval_samples = 0;
    uint32_t previous_detection = 0;

    benchmark_print_header("Tang Nano 9K PicoRV32 polling latency benchmark");

    picorv32_set_irq_mask(0xffffffffu);
    REG_TIMER_IRQ_ENABLE = 0;
    REG_TIMER_IRQ_PENDING = 1;
    REG_TIMER_IRQ_PERIOD = TIMER_IRQ_PERIOD_TICKS;
    REG_TIMER_IRQ_ENABLE = 1;

    while (samples < BENCHMARK_SAMPLES) {
        if (REG_TIMER_IRQ_PENDING != 0) {
            uint32_t detected = REG_TIMER_COUNT;
            uint32_t event_time = REG_TIMER_IRQ_EVENT_COUNT;
            uint32_t latency = detected - event_time;

            REG_TIMER_IRQ_PENDING = 1;
            update_stats(latency, &latency_min, &latency_max, &latency_total);

            if (previous_detection != 0) {
                update_stats(detected - previous_detection,
                             &interval_min,
                             &interval_max,
                             &interval_total);
                interval_samples++;
            }

            previous_detection = detected;
            samples++;
        }
    }

    REG_TIMER_IRQ_ENABLE = 0;

    benchmark_print_metric("poll_latency_min", latency_min);
    benchmark_print_metric("poll_latency_avg", latency_total / samples);
    benchmark_print_metric("poll_latency_max", latency_max);
    benchmark_print_metric("poll_interval_min", interval_min);
    benchmark_print_metric("poll_interval_avg", interval_total / interval_samples);
    benchmark_print_metric("poll_interval_max", interval_max);

    for (;;) {
    }
}
