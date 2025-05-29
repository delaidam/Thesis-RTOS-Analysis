#ifndef RT_KERNEL_H
#define RT_KERNEL_H

#include <stdint.h>
#include <stdbool.h>

// Task states
typedef enum {
    TASK_READY = 0,
    TASK_RUNNING,
    TASK_BLOCKED,
    TASK_TERMINATED
} task_state_t;

// Task Control Block (TCB)
typedef struct {
    uint32_t* stack_ptr;        // Trenutni stack pointer
    uint32_t* stack_base;       // Početak stack-a
    uint8_t priority;           // Task prioritet (0 = najviši)
    task_state_t state;         // Trenutno stanje task-a
    uint32_t wake_time;         // Za sleep funkcionalnost
    const char* name;           // Debug naziv
} task_t;

// Osnovne funkcije
int task_create(void (*task_func)(void), uint8_t priority, const char* name);
void task_yield(void);
void task_sleep(uint32_t ticks);
void kernel_init(void);
void kernel_start(void);
void kernel_run(void);
void schedule(void);

// Performance funkcije  
uint32_t get_context_switch_count(void);
uint32_t get_average_interrupt_latency(void);
uint32_t get_system_uptime(void);
void print_task_info(void);

// Demo funkcije
void rt_system_init(void);
void rt_main_loop(void);

// Hardware funkcije
uint32_t get_cycle_count(void);
int check_system_tick(void);
void configure_system_timer(uint32_t frequency);
void start_first_task(void);
void context_switch(void);
void uart_printf(const char* format, ...);
void system_tick_handler(void);

#endif // RT_KERNEL_H