/*
 * Demo aplikacije za PicoTiny RT Kernel
 * Integrisaće se sa postojećim firmware.c
 */

#include "rt_kernel.h"

// Dodaj ovu definiciju:
typedef struct {
    volatile uint32_t IN;
    volatile uint32_t OUT;
    volatile uint32_t DIR;
    volatile uint32_t reserved;
} PICOGPIO;

extern PICOGPIO* GPIO0;
#define GPIO_BASE ((PICOGPIO*)0x82000000)

/*
 * Task 1: LED Blink Task
 * Blinka LED-om na GPIO pin-u svakih 500ms
 */
void led_blink_task(void) {
    static uint32_t last_toggle = 0;
    uint32_t current_time = get_system_uptime();
    
    while (1) {
        if ((current_time - last_toggle) >= 500) { // 500ms
            // Zameni: GPIO0->OUT ^= 0x01;
            *((volatile uint32_t*)0x82000004) ^= 0x01;
            last_toggle = current_time;
            uart_printf("LED Toggle at tick %d\n", current_time);
        }
        
        current_time = get_system_uptime();
        task_yield(); // Predaj kontrolu drugim task-ovima
    }
}

/*
 * Task 2: UART Debug Task  
 * Šalje debug informacije svakih 1000ms
 */
void uart_debug_task(void) {
    static uint32_t last_debug = 0;
    uint32_t current_time = get_system_uptime();
    
    while (1) {
        if ((current_time - last_debug) >= 1000) { // 1000ms
            uart_printf("=== RT System Status ===\n");
            uart_printf("Uptime: %d ticks\n", current_time);
            uart_printf("Context switches: %d\n", get_context_switch_count());
            uart_printf("Avg interrupt latency: %d cycles\n", get_average_interrupt_latency());
            print_task_info();
            uart_printf("========================\n");
            
            last_debug = current_time;
        }
        
        current_time = get_system_uptime();
        task_yield();
    }
}

/*
 * Task 3: Counter Task
 * Broji i periodično izveštava
 */
void counter_task(void) {
    static uint32_t counter = 0;
    static uint32_t last_report = 0;
    uint32_t current_time = get_system_uptime();
    
    while (1) {
        counter++;
        
        if ((current_time - last_report) >= 2000) { // 2000ms
            uart_printf("Counter Task: %d iterations\n", counter);
            last_report = current_time;
        }
        
        current_time = get_system_uptime();
        task_yield();
    }
}

/*
 * Task 4: GPIO Monitor Task
 * Čita GPIO input stanje i reaguje na promene
 */
void gpio_monitor_task(void) {
    static uint32_t last_gpio_state = 0;
    uint32_t current_gpio;
    
    while (1) {
        // Zameni: current_gpio = GPIO0->IN;
        current_gpio = *((volatile uint32_t*)0x82000000);
        
        if (current_gpio != last_gpio_state) {
            uart_printf("GPIO State Change: 0x%08x -> 0x%08x\n", 
                       last_gpio_state, current_gpio);
            last_gpio_state = current_gpio;
        }
        
        task_yield();
    }
}

/*
 * Inicijalizacija RT sistema
 */
void rt_system_init(void) {
    uart_printf("\n=== PicoTiny Real-Time Kernel Demo ===\n");
    uart_printf("Initializing RT system...\n");
    
    // Inicijalizuj kernel
    kernel_init();
    
    // Kreiraj task-ove
    int task_id;
    
    task_id = task_create(led_blink_task, 1, "LED_Blink");
    if (task_id >= 0) {
        uart_printf("Created LED Blink Task (ID: %d)\n", task_id);
    }
    
    task_id = task_create(uart_debug_task, 2, "UART_Debug");  
    if (task_id >= 0) {
        uart_printf("Created UART Debug Task (ID: %d)\n", task_id);
    }
    
    task_id = task_create(counter_task, 3, "Counter");
    if (task_id >= 0) {
        uart_printf("Created Counter Task (ID: %d)\n", task_id);
    }
    
    task_id = task_create(gpio_monitor_task, 2, "GPIO_Monitor");
    if (task_id >= 0) {
        uart_printf("Created GPIO Monitor Task (ID: %d)\n", task_id);
    }
    
    uart_printf("Starting RT kernel...\n");
    
    // Pokreni kernel
    kernel_start();
    
    uart_printf("RT Kernel started successfully!\n");
}

/*
 * Integracija sa postojećim firmware.c main loop
 * Poziva se umesto postojećeg while(1) loop-a
 */
void rt_main_loop(void) {
    // Inicijalizuj RT sistem
    rt_system_init();
    
    // Pokreni glavni scheduler loop
    kernel_run(); // Ova funkcija nikad ne vraća kontrolu
}