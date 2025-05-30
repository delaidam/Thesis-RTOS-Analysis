#ifndef RT_KERNEL_H
#define RT_KERNEL_H

#include <stdint.h>
#include <stdbool.h>

#define MAX_TASKS 8
#define STACK_SIZE 256
#define TICK_FREQUENCY 1000

// Task states
typedef enum {
    TASK_READY = 0,
    TASK_RUNNING,
    TASK_BLOCKED,
    TASK_TERMINATED
} task_state_t;

// Task structure
typedef struct {
    uint32_t* stack_ptr;
    uint32_t stack[STACK_SIZE];
    task_state_t state;
    uint8_t priority;
    uint32_t sleep_ticks;
    void (*task_func)(void);
    char name[16];
} task_t;

// Performance statistics
typedef struct {
    uint32_t context_switches;
    uint32_t total_interrupt_latency;
    uint32_t interrupt_count;
} perf_stats_t;

// Function declarations
int task_create(void (*task_func)(void), uint8_t priority, const char* name);
void task_sleep(uint32_t ticks);
uint8_t get_next_task(void);
void schedule(void);
void system_tick_handler(void);
void task_yield(void);
void kernel_run(void);
void kernel_init(void);
void kernel_start(void);
uint32_t get_context_switch_count(void);
uint32_t get_average_interrupt_latency(void);
uint32_t get_system_uptime(void);
void print_task_info(void);

// Hardware abstraction functions (implement in firmware.c)
extern void context_switch(void);
extern void start_first_task(void);
extern uint32_t get_cycle_count(void);
extern void configure_system_timer(uint32_t frequency);
extern bool check_system_tick(void);
extern void uart_printf(const char* format, ...);

#endif // RT_KERNEL_H