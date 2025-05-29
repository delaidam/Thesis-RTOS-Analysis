/*
 * rt_kernel.c - Minimalni Real-Time Kernel za PicoTiny RISC-V
 * Dizajniran za Tang Nano 9K sa PicoRV32 core
 */

#include "rt_kernel.h"

// External functions from firmware.c
extern int putchar(int c);

// Jednostavna memset implementacija za linker
void* memset(void* s, int c, unsigned int n) {
    unsigned char* p = (unsigned char*)s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

// Konfiguracija sistema
#define MAX_TASKS 4
#define STACK_SIZE 256  // 256 bytes po task-u
#define TICK_FREQUENCY 1000  // 1ms tick

// Globalne varijable
static task_t tasks[MAX_TASKS];
static uint8_t current_task = 0;
static uint8_t task_count = 0;
static uint32_t system_tick = 0;
static bool scheduler_started = false;

// Stack storage - svaki task ima svoj stack
static uint32_t task_stacks[MAX_TASKS][STACK_SIZE/4];

// Performance counters za analizu
typedef struct {
    uint32_t context_switches;
    uint32_t tick_count;
    uint32_t interrupt_latency_sum;
    uint32_t interrupt_count;
} perf_stats_t;

static perf_stats_t perf_stats = {0};

/*
 * Hardware specifične funkcije za PicoTiny
 */

// Cycle counter - koristi PicoRV32 rdcycle instrukciju
inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
    return cycles;
}

// UART printf - koristi postojeći putchar iz firmware.c
void uart_printf(const char* format, ...) {
    // Jednostavan printf za debugging
    const char* p = format;
    while (*p) {
        putchar(*p);
        p++;
    }
}

// Softverski timer koristeći system tick count
static uint32_t timer_last_tick = 0;
static uint32_t timer_interval = 25175; // ~1ms na 25MHz

void configure_system_timer(uint32_t frequency) {
    // 25.175MHz je sistemski clock
    timer_interval = 25175000 / frequency;
    timer_last_tick = get_cycle_count();
}

// Provera da li je vreme za system tick
int check_system_tick(void) {
    uint32_t current = get_cycle_count();
    if ((current - timer_last_tick) >= timer_interval) {
        timer_last_tick = current;
        return 1;
    }
    return 0;
}

// Context switch - jednostavan zbog cooperative schedulinga
void context_switch(void) {
    // Za cooperative multitasking, context switch će biti pozvan
    // eksplicitno iz task_yield() funkcije
}

void start_first_task(void) {
    // Jednostavno postavi prvi task kao current i nastavi
    if (task_count > 0) {
        tasks[0].state = TASK_RUNNING;
        current_task = 0;
    }
}

/*
 * Funkcija koja sprečava kompajler da optimizuje petlje u memset
 */
static void __attribute__((noinline)) zero_stack_registers(uint32_t* stack_ptr, int count) {
    volatile int i;  // volatile sprečava optimizaciju
    for (i = 0; i < count; i++) {
        stack_ptr[-i-1] = 0;  // Direktno postavljanje bez pointer manipulacije
    }
}

/*
 * Task kreiranje i upravljanje
 */

// Kreira novi task
int task_create(void (*task_func)(void), uint8_t priority, const char* name) {
    if (task_count >= MAX_TASKS) {
        return -1; // Nema više mesta
    }
    
    uint8_t task_id = task_count++;
    
    // Postavi stack - stack raste nadole u RISC-V
    tasks[task_id].stack_base = task_stacks[task_id] + (STACK_SIZE/4 - 1);
    tasks[task_id].stack_ptr = tasks[task_id].stack_base;

    // Inicijalizuj stack sa početnim kontekstom
    *(tasks[task_id].stack_ptr) = (uint32_t)task_func;  // PC
    tasks[task_id].stack_ptr--;

    // Koristi anti-optimization funkciju za postavljanje registara
    zero_stack_registers(tasks[task_id].stack_ptr, 31);
    tasks[task_id].stack_ptr -= 31;

    tasks[task_id].priority = priority;
    tasks[task_id].state = TASK_READY;
    tasks[task_id].wake_time = 0;
    tasks[task_id].name = name;
    
    return task_id;
}

// Sleep funkcija - task spava određeni broj ticks
void task_sleep(uint32_t ticks) {
    tasks[current_task].wake_time = system_tick + ticks;
    tasks[current_task].state = TASK_BLOCKED;
    
    // Forsira context switch
    schedule();
}

/*
 * Scheduler implementacija
 */

// Round-robin scheduler sa priority support
uint8_t get_next_task(void) {
    uint8_t next = current_task;
    uint8_t highest_priority = 255;
    uint8_t selected_task = 0;
    
    // Prvo proveri da li neki task treba da se probudi
    for (int i = 0; i < task_count; i++) {
        if (tasks[i].state == TASK_BLOCKED && 
            tasks[i].wake_time <= system_tick) {
            tasks[i].state = TASK_READY;
        }
    }
    
    // Nađi task sa najvišim prioritetom koji je spreman
    for (int i = 0; i < task_count; i++) {
        if (tasks[i].state == TASK_READY && 
            tasks[i].priority < highest_priority) {
            highest_priority = tasks[i].priority;
            selected_task = i;
        }
    }
    
    return selected_task;
}

// Poziva context switch
void schedule(void) {
    if (!scheduler_started) return;
    
    uint8_t next_task = get_next_task();
    
    if (next_task != current_task) {
        // Promeni stanje task-ova
        if (tasks[current_task].state == TASK_RUNNING) {
            tasks[current_task].state = TASK_READY;
        }
        
        tasks[next_task].state = TASK_RUNNING;
        current_task = next_task;
        
        perf_stats.context_switches++;
        
        // Ovde bi trebao context_switch() u assembly-ju
        context_switch();
    }
}

/*
 * System tick handler - poziva se iz main loop-a
 * (Cooperative multitasking umesto preemptive)
 */
void system_tick_handler(void) {
    uint32_t start_cycle = get_cycle_count(); // Za merenje latencije
    
    system_tick++;
    perf_stats.tick_count++;
    
    // Schedule next task
    schedule();
    
    // Izmeri scheduler latency
    uint32_t end_cycle = get_cycle_count();
    perf_stats.interrupt_latency_sum += (end_cycle - start_cycle);
    perf_stats.interrupt_count++;
}

/*
 * Task yield - pozivaju task-ovi da predaju kontrolu
 */
void task_yield(void) {
    if (scheduler_started) {
        schedule();
    }
}

/*
 * Main scheduler loop - poziva se iz main() funkcije
 */
void kernel_run(void) {
    while (1) {
        // Proveri da li je vreme za system tick
        if (check_system_tick()) {
            system_tick_handler();
        }
        
        // Izvršava trenutni task
        if (scheduler_started && current_task < task_count) {
            // Task će sam pozvati task_yield() kada završi svoj deo posla
        }
    }
}

/*
 * Kernel inicijalizacija i start
 */
void kernel_init(void) {
    // Reset svih task-ova - eksplicitno jedan po jedan
    volatile int i;  // volatile sprečava optimizaciju
    for (i = 0; i < MAX_TASKS; i++) {
        tasks[i].state = TASK_TERMINATED;
        tasks[i].priority = 0;
        tasks[i].wake_time = 0;
        tasks[i].name = "unused";
        tasks[i].stack_base = 0;
        tasks[i].stack_ptr = 0;
    }
    
    current_task = 0;
    task_count = 0;
    system_tick = 0;
    scheduler_started = false;
    
    // Reset performance counters - eksplicitno
    perf_stats.context_switches = 0;
    perf_stats.tick_count = 0;
    perf_stats.interrupt_latency_sum = 0;
    perf_stats.interrupt_count = 0;
}

void kernel_start(void) {
    if (task_count == 0) {
        return; // Nema task-ova za pokretanje
    }
    
    // Prvi task postaje current
    tasks[0].state = TASK_RUNNING;
    current_task = 0;
    
    scheduler_started = true;
    
    // Konfiguracija timer-a (ovo zavisi od PicoTiny implementacije)
    configure_system_timer(TICK_FREQUENCY);
    
    // Pokreni prvi task
    start_first_task();
}

/*
 * Performance monitoring funkcije
 */
uint32_t get_context_switch_count(void) {
    return perf_stats.context_switches;
}

uint32_t get_average_interrupt_latency(void) {
    if (perf_stats.interrupt_count == 0) return 0;
    return perf_stats.interrupt_latency_sum / perf_stats.interrupt_count;
}

uint32_t get_system_uptime(void) {
    return system_tick;
}

void print_task_info(void) {
    // Debug funkcija za UART output
    for (int i = 0; i < task_count; i++) {
        uart_printf("Task[");
        // Simple number printing
        if (i == 0) uart_printf("0");
        else if (i == 1) uart_printf("1");
        else if (i == 2) uart_printf("2");
        else if (i == 3) uart_printf("3");
        uart_printf("]: ");
        uart_printf(tasks[i].name);
        uart_printf(", State: ");
        if (tasks[i].state == 0) uart_printf("READY");
        else if (tasks[i].state == 1) uart_printf("RUNNING");
        else if (tasks[i].state == 2) uart_printf("BLOCKED");
        else uart_printf("TERMINATED");
        uart_printf("\n");
    }
}