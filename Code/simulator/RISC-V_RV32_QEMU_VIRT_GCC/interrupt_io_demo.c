/* Complete fixed wrapper file to be added as interrupt_io_demo.c 
   This will replace the original interrupt_io_demo.c */

#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
#include "timers.h"
#include "queue.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h> // za rand()

/* Use external print function to avoid conflicts */
extern void print_uint32(uint32_t value);

/* C89 compatible definitions */
#define ADAPTIVE_TRUE  1
#define ADAPTIVE_FALSE 0
typedef int adaptive_bool_t;

#define MAX_CYCLES 5  // Završi demo nakon 5 ciklusa
#define CYCLE_DURATION_MS 3000  // 3 sekunde po ciklusu

/* All the structures and variables from the adaptive demo */
typedef struct {
    uint8_t interrupt_type;
    uint32_t data;
    TickType_t timestamp;
    uint8_t priority;           
    uint8_t complexity_level;   
    char description[32];
    TickType_t deadline;        
} interrupt_event_t;

typedef struct {
    uint32_t cpu_utilization;   
    uint32_t queue_depth;       
    uint32_t active_interrupts; 
    uint32_t system_load_score; 
    TickType_t last_measurement;
} system_load_t;

typedef struct {
    uint32_t interrupt_count;
    uint32_t total_response_time;
    uint32_t min_response_time;
    uint32_t max_response_time;
    uint32_t missed_deadlines;
    uint32_t max_isr_time;
    TickType_t last_interrupt_time;
    
    uint32_t priority_counts[5];     
    uint32_t complexity_adjustments; 
    uint32_t deadline_adjustments;   
    uint32_t load_based_optimizations;
} interrupt_performance_t;

typedef struct {
    TickType_t base_deadline;        
    uint8_t max_complexity;          
    uint32_t load_threshold_low;     
    uint32_t load_threshold_high;    
    adaptive_bool_t adaptive_enabled; 
} adaptive_config_t;

/* Deklaracija globalne varijable (definirana u main.c) */
extern volatile uint32_t total_cycles;

/* Global variables */
static SemaphoreHandle_t xInterruptSemaphore;
static SemaphoreHandle_t xTimerSemaphore;
static SemaphoreHandle_t xIOSemaphore;
static SemaphoreHandle_t xAdaptiveMutex;
static QueueHandle_t xInterruptQueue;
static QueueHandle_t xHighPriorityQueue;   
static TimerHandle_t xInterruptSimulationTimer;
static TimerHandle_t xPeriodicTimer;
static TimerHandle_t xCriticalTimer;       
static TimerHandle_t xAdaptiveTimer;       

static interrupt_performance_t interrupt_stats;
static system_load_t system_load;
static adaptive_config_t adaptive_config;
static volatile uint32_t isr_entry_time;
static volatile uint32_t isr_exit_time;
static volatile uint32_t io_operations_count = 0;

/* Queue overflow tracking */
static uint32_t queue_overflow_count = 0;
static uint32_t high_priority_overflow_count = 0;

/* Termination flag */
static volatile adaptive_bool_t demo_should_terminate = ADAPTIVE_FALSE;
static TickType_t demo_start_time = 0;

/* Function to force system termination */
void force_system_exit(void) {
    printf("\n\n=== DEMO TERMINATION SEQUENCE ===\n");
    printf("Stopping all timers...\n");
    
    // Stop all timers
    if (xInterruptSimulationTimer) xTimerStop(xInterruptSimulationTimer, 0);
    if (xPeriodicTimer) xTimerStop(xPeriodicTimer, 0);
    if (xCriticalTimer) xTimerStop(xCriticalTimer, 0);
    if (xAdaptiveTimer) xTimerStop(xAdaptiveTimer, 0);
    
    printf("All timers stopped.\n");
    printf("Demo completed successfully after %u cycles.\n", (unsigned int)total_cycles);
    printf("=== END OF LOG DATA ===\n");
    
    // Force exit - različiti pristupi ovisno o sistemu
    #ifdef __QEMU__
        // QEMU specific exit
        asm volatile("li a0, 0; li a7, 93; ecall"); // exit syscall
    #endif
    
    // Fallback - infinite loop with periodic messages
    printf("System halted. Please terminate QEMU manually (Ctrl+A then X).\n");
    for(;;) {
        vTaskDelay(pdMS_TO_TICKS(5000));
        printf(">>> System halted - terminate QEMU manually <<<\n");
    }
}

/* Check if demo should terminate */
adaptive_bool_t should_terminate_demo(void) {
    if (demo_should_terminate) return ADAPTIVE_TRUE;
    
    TickType_t current_time = xTaskGetTickCount();
    TickType_t elapsed_time = current_time - demo_start_time;
    
    // Terminiraj nakon MAX_CYCLES * CYCLE_DURATION_MS
    if (elapsed_time >= pdMS_TO_TICKS(MAX_CYCLES * CYCLE_DURATION_MS)) {
        demo_should_terminate = ADAPTIVE_TRUE;
        total_cycles = MAX_CYCLES;
        return ADAPTIVE_TRUE;
    }
    
    // Ili ako je total_cycles dostigao MAX_CYCLES
    if (total_cycles >= MAX_CYCLES) {
        demo_should_terminate = ADAPTIVE_TRUE;
        return ADAPTIVE_TRUE;
    }
    
    return ADAPTIVE_FALSE;
}

/* Improved system load calculation */
void calculate_system_load(void) {
    if (should_terminate_demo()) return;
    
    TickType_t current_time = xTaskGetTickCount();
    if (system_load.last_measurement == 0) {
        system_load.last_measurement = current_time - pdMS_TO_TICKS(1000);
    }

    UBaseType_t queue_items = uxQueueMessagesWaiting(xInterruptQueue);
    UBaseType_t high_priority_items = uxQueueMessagesWaiting(xHighPriorityQueue);

    system_load.queue_depth = queue_items + high_priority_items;
    system_load.active_interrupts = queue_items + high_priority_items;

    // Poboljšano računanje CPU utilization
    if (interrupt_stats.interrupt_count > 5) {
        uint32_t avg_processing_time = interrupt_stats.total_response_time / interrupt_stats.interrupt_count;
        uint32_t time_since_last = current_time - system_load.last_measurement;

        if (time_since_last > 0) {
            system_load.cpu_utilization = (avg_processing_time * 150) / time_since_last;
            if (system_load.cpu_utilization > 100) system_load.cpu_utilization = 100;
        }
    } else {
        system_load.cpu_utilization = 20 + (system_load.queue_depth * 5);
        if (system_load.cpu_utilization > 100) system_load.cpu_utilization = 100;
    }

    // Poboljšano računanje load score sa boljim faktorima
    system_load.system_load_score = (system_load.cpu_utilization * 50 +
                                   system_load.queue_depth * 30 +
                                   system_load.active_interrupts * 20) / 100;

    // Dodaj penalizaciju za missed deadlines
    if(interrupt_stats.interrupt_count > 0) {
        uint32_t miss_rate = (interrupt_stats.missed_deadlines * 100) / interrupt_stats.interrupt_count;
        system_load.system_load_score += miss_rate;
    }

    if(system_load.system_load_score > 100) system_load.system_load_score = 100;

    system_load.last_measurement = current_time;
}

/* Improved adaptive deadline calculation */
TickType_t calculate_adaptive_deadline(uint8_t priority, uint8_t complexity) {
    TickType_t base_deadline = adaptive_config.base_deadline * (priority + 1);

    // Prioritet faktori
    switch(priority) {
        case 1: base_deadline = (base_deadline * 3) / 4; break;
        case 2: base_deadline = (base_deadline * 7) / 8; break;
        case 3: base_deadline = base_deadline; break;
        case 4: base_deadline = (base_deadline * 5) / 4; break;
        default: base_deadline = base_deadline; break;
    }

    if (base_deadline == 0) base_deadline = 1;

    // Agresivnije prilagođavanje na osnovu load
    if (system_load.system_load_score > 60) {
        base_deadline = (base_deadline * 200) / 100;
        interrupt_stats.deadline_adjustments++;
        printf("[ADAPTIVE] Deadline extended due to high load (%u%%)\r\n",
               (unsigned int)system_load.system_load_score);
    } else if (system_load.system_load_score > 40) {
        base_deadline = (base_deadline * 130) / 100;
        interrupt_stats.deadline_adjustments++;
    }

    // Prilagodi na osnovu kompleksnosti
    base_deadline = (base_deadline * (complexity + 2)) / 4;

    return (base_deadline > 0) ? base_deadline : 1;
}

/* Aggressive complexity optimization */
uint8_t optimize_processing_complexity(uint8_t original_complexity) {
    uint8_t optimized_complexity = original_complexity;
    
    if(adaptive_config.adaptive_enabled == ADAPTIVE_FALSE) return original_complexity;
    
    if(system_load.system_load_score > 45 && optimized_complexity > 1) {
        optimized_complexity = (optimized_complexity > 2) ? optimized_complexity - 2 : 1;
        interrupt_stats.complexity_adjustments++;
        printf("[ADAPTIVE] Complexity reduced from %u to %u (Load: %u%%)\r\n",
               (unsigned int)original_complexity, (unsigned int)optimized_complexity,
               (unsigned int)system_load.system_load_score);
    } else if(system_load.system_load_score < 25 && optimized_complexity < adaptive_config.max_complexity) {
        optimized_complexity++;
    }
    
    return optimized_complexity;
}

/* Improved Critical ISR */
void vCriticalInterruptCallback(TimerHandle_t xTimer) {
    if (should_terminate_demo()) return;
    
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    interrupt_event_t event;
    volatile int i;

    isr_entry_time = xTaskGetTickCountFromISR();

    event.interrupt_type = 3;
    event.data = interrupt_stats.interrupt_count++;
    event.timestamp = isr_entry_time;
    event.priority = 1;
    event.complexity_level = 2;
    sprintf(event.description, "Critical ISR #");

    event.deadline = calculate_adaptive_deadline(event.priority, event.complexity_level);

    for(i = 0; i < 30; i++);

    if(xQueueSendFromISR(xHighPriorityQueue, &event, &xHigherPriorityTaskWoken) != pdPASS) {
        high_priority_overflow_count++;
        printf("[ERROR] Critical Queue full! Count: %u\r\n", 
               (unsigned int)high_priority_overflow_count);
    }
    xSemaphoreGiveFromISR(xInterruptSemaphore, &xHigherPriorityTaskWoken);

    isr_exit_time = xTaskGetTickCountFromISR();
    uint32_t isr_duration = isr_exit_time - isr_entry_time;
    if (isr_duration > interrupt_stats.max_isr_time) {
        interrupt_stats.max_isr_time = isr_duration;
    }
    interrupt_stats.priority_counts[1]++;

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

/* Improved main ISR with better queue management */
void vInterruptSimulationCallback(TimerHandle_t xTimer) {
    if (should_terminate_demo()) return;
    
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    interrupt_event_t event;
    volatile int i;

    isr_entry_time = xTaskGetTickCountFromISR();

    event.interrupt_type = 1;
    event.data = interrupt_stats.interrupt_count++;
    event.timestamp = isr_entry_time;
    event.priority = (rand() % 3) + 1;
    event.complexity_level = (rand() % 5) + 1;
    sprintf(event.description, "Adaptive ISR #");

    event.deadline = calculate_adaptive_deadline(event.priority, event.complexity_level);

    for(i = 0; i < (30 * event.complexity_level); i++);

    xSemaphoreGiveFromISR(xInterruptSemaphore, &xHigherPriorityTaskWoken);
    
    if(event.priority == 1) {
        if(xQueueSendFromISR(xHighPriorityQueue, &event, &xHigherPriorityTaskWoken) != pdPASS) {
            high_priority_overflow_count++;
            printf("[ERROR] High Priority Queue full! Count: %u\r\n", 
                   (unsigned int)high_priority_overflow_count);
        }
    } else {
        if(xQueueSendFromISR(xInterruptQueue, &event, &xHigherPriorityTaskWoken) != pdPASS) {
            queue_overflow_count++;
            printf("[ERROR] Normal Queue full! Count: %u, Priority: %u\r\n", 
                   (unsigned int)queue_overflow_count, (unsigned int)event.priority);
        }
    }

    isr_exit_time = xTaskGetTickCountFromISR();
    interrupt_stats.priority_counts[event.priority]++;

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

void vPeriodicTimerCallback(TimerHandle_t xTimer) {
    if (should_terminate_demo()) return;
    
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    interrupt_event_t event;
    
    event.interrupt_type = 2; 
    event.data = 0xFF;
    event.timestamp = xTaskGetTickCountFromISR();
    event.priority = 2; 
    event.complexity_level = optimize_processing_complexity(4);
    sprintf(event.description, "Periodic Timer");
    
    event.deadline = calculate_adaptive_deadline(event.priority, event.complexity_level);
    
    xSemaphoreGiveFromISR(xTimerSemaphore, &xHigherPriorityTaskWoken);
    if(xQueueSendFromISR(xInterruptQueue, &event, &xHigherPriorityTaskWoken) != pdPASS) {
        queue_overflow_count++;
    }
    
    interrupt_stats.priority_counts[2]++;
    
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

/* Enhanced adaptive timer callback */
void vAdaptiveTimerCallback(TimerHandle_t xTimer) {
    if (should_terminate_demo()) return;
    
    if(xSemaphoreTake(xAdaptiveMutex, pdMS_TO_TICKS(50)) == pdTRUE) {
        calculate_system_load();
        
        // Agresivnije reagovanje na missed deadlines
        if(interrupt_stats.missed_deadlines > 0 && interrupt_stats.interrupt_count > 5) {
            uint32_t miss_rate = (interrupt_stats.missed_deadlines * 100) / 
                               interrupt_stats.interrupt_count;
            
            if(miss_rate > 5) {
                adaptive_config.load_threshold_high = (adaptive_config.load_threshold_high > 10) ? 
                                                      adaptive_config.load_threshold_high - 10 : 10;
                adaptive_config.load_threshold_low = (adaptive_config.load_threshold_low > 5) ? 
                                                     adaptive_config.load_threshold_low - 5 : 5;
                adaptive_config.base_deadline += pdMS_TO_TICKS(2);
                interrupt_stats.load_based_optimizations++;
                
                printf("[ADAPTIVE] System tuning due to %u%% miss rate\r\n", 
                       (unsigned int)miss_rate);
            }
        }
        
        if(system_load.system_load_score < 20 && adaptive_config.base_deadline > pdMS_TO_TICKS(3)) {
            adaptive_config.base_deadline--;
            interrupt_stats.load_based_optimizations++;
        }
        
        if (adaptive_config.base_deadline < pdMS_TO_TICKS(2)) {
            adaptive_config.base_deadline = pdMS_TO_TICKS(2);
        }
        if (adaptive_config.load_threshold_low < 5) {
            adaptive_config.load_threshold_low = 5;
        }
        if (adaptive_config.load_threshold_high < 30) {
            adaptive_config.load_threshold_high = 30;
        }

        xSemaphoreGive(xAdaptiveMutex);
    }
}

/* Optimized interrupt handler task */
void vInterruptHandlerTask(void *pvParameters) {
    interrupt_event_t event;
    TickType_t response_start, response_end, response_time;
    adaptive_bool_t event_processed = ADAPTIVE_FALSE;
    uint32_t processing_cycles;
    volatile uint32_t i;
    uint8_t optimized_complexity;
    
    for(;;) {
        if (should_terminate_demo()) {
            printf("[INT-HANDLER] Task terminating...\n");
            vTaskDelete(NULL);
        }
        
        event_processed = ADAPTIVE_FALSE;
        
        if(xQueueReceive(xHighPriorityQueue, &event, 0) == pdTRUE) {
            event_processed = ADAPTIVE_TRUE;
            system_load.active_interrupts++;
            
            printf("[CRITICAL-HANDLER] Processing critical interrupt #");
            print_uint32(event.data);
            printf(" (Priority: ");
            print_uint32(event.priority);
            printf(")\r\n");
            
        } else if(xSemaphoreTake(xInterruptSemaphore, pdMS_TO_TICKS(100)) == pdTRUE) {
            if(xQueueReceive(xInterruptQueue, &event, 0) == pdTRUE) {
                event_processed = ADAPTIVE_TRUE;
                system_load.active_interrupts++;
            }
        }
        
        if(event_processed == ADAPTIVE_TRUE) {
            response_start = xTaskGetTickCount();
            
            optimized_complexity = optimize_processing_complexity(event.complexity_level);
            
            printf("[INT-HANDLER] Processing interrupt #");
            print_uint32(event.data);
            printf(" (Priority: ");
            print_uint32(event.priority);
            printf(", Complexity: ");
            print_uint32(event.complexity_level);
            if(optimized_complexity != event.complexity_level) {
                printf(" -> ");
                print_uint32(optimized_complexity);
            }
            printf(")\r\n");
            
            processing_cycles = 200 * optimized_complexity;
            
            switch(event.priority) {
                case 1: processing_cycles = processing_cycles / 2; break;
                case 2: processing_cycles = (processing_cycles * 3) / 4; break;
                case 3: processing_cycles = processing_cycles; break;
                case 4: processing_cycles = (processing_cycles * 5) / 4; break;
                default: processing_cycles = processing_cycles; break;
            }
            
            for (i = 0; i < processing_cycles; i++);
            
            TickType_t delay_time = 1;
            if(system_load.system_load_score > 70) {
                delay_time = 3;
            } else if(system_load.system_load_score < 30) {
                delay_time = 1;
            } else {
                delay_time = 2;
            }
            vTaskDelay(delay_time);
            
            response_end = xTaskGetTickCount();
            response_time = response_end - response_start;
            
            interrupt_stats.total_response_time += response_time;
            
            if(response_time < interrupt_stats.min_response_time || interrupt_stats.min_response_time == 0) {
                interrupt_stats.min_response_time = response_time;
            }
            if(response_time > interrupt_stats.max_response_time) {
                interrupt_stats.max_response_time = response_time;
            }
            
            TickType_t adjusted_deadline = calculate_adaptive_deadline(event.priority, optimized_complexity);
            if(response_time > adjusted_deadline) {
                interrupt_stats.missed_deadlines++;
                printf("[WARNING] Adaptive deadline missed! Response: ");
                print_uint32(response_time);
                printf(" > Deadline: ");
                print_uint32(adjusted_deadline);
                printf(" ticks (Load: ");
                print_uint32(system_load.system_load_score);
                printf("%%)\r\n");
            }
            
            printf("[INT-HANDLER] Response time: ");
            print_uint32(response_time);
            printf(" ticks (Deadline: ");
            print_uint32(adjusted_deadline);
            printf(" ticks)\r\n");
            
            system_load.active_interrupts--;
            xSemaphoreGive(xIOSemaphore);
        }
    }
}

/* Enhanced monitoring task with cycle-based termination */
void vInterruptMonitorTask(void *pvParameters) {
    TickType_t report_interval = pdMS_TO_TICKS(CYCLE_DURATION_MS);
    TickType_t last_report_time = xTaskGetTickCount();

    for(;;) {
        vTaskDelay(pdMS_TO_TICKS(500)); // Check every 500ms
        
        TickType_t current_time = xTaskGetTickCount();
        
        // Check if it's time for a report (every CYCLE_DURATION_MS)
        if ((current_time - last_report_time) >= report_interval) {
            total_cycles++;
            last_report_time = current_time;
            
            printf("\n=== CYCLE %u REPORT ===\n", (unsigned int)total_cycles);
            
            if(xSemaphoreTake(xAdaptiveMutex, pdMS_TO_TICKS(100)) == pdTRUE) {
                calculate_system_load();
                
                printf("=== ADAPTIVE INTERRUPT PERFORMANCE REPORT ===\r\n");
                printf("Total interrupts processed: ");
                print_uint32(interrupt_stats.interrupt_count);
                printf("\r\n");
                
                printf("Priority distribution:\r\n");
                printf("  Critical (1): ");
                print_uint32(interrupt_stats.priority_counts[1]);
                printf("\r\n");
                printf("  High (2): ");
                print_uint32(interrupt_stats.priority_counts[2]);
                printf("\r\n");
                printf("  Normal (3): ");
                print_uint32(interrupt_stats.priority_counts[3]);
                printf("\r\n");
                
                printf("Queue Statistics:\r\n");
                printf("  Normal Queue Overflows: ");
                print_uint32(queue_overflow_count);
                printf("\r\n");
                printf("  High Priority Queue Overflows: ");
                print_uint32(high_priority_overflow_count);
                printf("\r\n");
                printf("  Current Queue Depth: ");
                print_uint32(system_load.queue_depth);
                printf("\r\n");
                
                printf("System Load Metrics:\r\n");
                printf("  CPU Utilization: ");
                print_uint32(system_load.cpu_utilization);
                printf("%%\r\n");
                printf("  Active Interrupts: ");
                print_uint32(system_load.active_interrupts);
                printf("\r\n");
                printf("  Load Score: ");
                print_uint32(system_load.system_load_score);
                printf("\r\n");
                
                printf("Performance Metrics:\r\n");
                if(interrupt_stats.interrupt_count > 0) {
                    uint32_t avg_response = interrupt_stats.total_response_time / interrupt_stats.interrupt_count;
                    printf("  Min/Avg/Max Response: ");
                    print_uint32(interrupt_stats.min_response_time);
                    printf("/");
                    print_uint32(avg_response);
                    printf("/");
                    print_uint32(interrupt_stats.max_response_time);
                    printf(" ticks\r\n");
                    
                    printf("  Max ISR Time: ");
                    print_uint32(interrupt_stats.max_isr_time);
                    printf(" ticks\r\n");
                    
                    uint32_t successful_interrupts = interrupt_stats.interrupt_count - interrupt_stats.missed_deadlines;
                    uint32_t success_rate = (successful_interrupts * 100) / interrupt_stats.interrupt_count;
                    
                    printf("  Deadline Success Rate: ");
                    print_uint32(success_rate);
                    printf("%% (");
                    print_uint32(interrupt_stats.missed_deadlines);
                    printf(" missed)\r\n");
                }
                
                printf("Adaptive Algorithm Stats:\r\n");
                printf("  Complexity Adjustments: ");
                print_uint32(interrupt_stats.complexity_adjustments);
                printf("\r\n");
                printf("  Deadline Adjustments: ");
                print_uint32(interrupt_stats.deadline_adjustments);
                printf("\r\n");
                printf("  Load-based Optimizations: ");
                print_uint32(interrupt_stats.load_based_optimizations);
                printf("\r\n");
                
                printf("Current Adaptive Config:\r\n");
                printf("  Base Deadline: ");
                print_uint32(adaptive_config.base_deadline);
                printf(" ticks\r\n");
                printf("  Load Thresholds: ");
                print_uint32(adaptive_config.load_threshold_low);
                printf("%% - ");
                print_uint32(adaptive_config.load_threshold_high);
                printf("%%\r\n");
                
                printf("============================================\r\n\r\n");
                
                xSemaphoreGive(xAdaptiveMutex);
            }
        }

        // Check for termination
        if (should_terminate_demo()) {
            printf("[MONITOR] Demo termination detected - stopping...\n");
            force_system_exit();
            break;
        }
    }
}

/* Fixed I/O simulation task */
void vIOSimulationTask(void *pvParameters) {
    interrupt_event_t event;
    TickType_t processing_start, processing_end, total_latency;
    uint32_t io_cycles;
    volatile uint32_t i;
    adaptive_bool_t event_received = ADAPTIVE_FALSE;
    
    for(;;) {
        if (should_terminate_demo()) {
            printf("[I/O-SIM] Task terminating...\n");
            vTaskDelete(NULL);
        }
        
        event_received = ADAPTIVE_FALSE;
        
        if(xQueueReceive(xInterruptQueue, &event, pdMS_TO_TICKS(10)) == pdTRUE) {
            event_received = ADAPTIVE_TRUE;
        }
        else if(xSemaphoreTake(xIOSemaphore, pdMS_TO_TICKS(100)) == pdTRUE) {
            event.interrupt_type = 4;
            event.data = io_operations_count;
            event.timestamp = xTaskGetTickCount();
            event.priority = 3;
            event.complexity_level = 2;
            sprintf(event.description, "IO Signal #");
            event.deadline = calculate_adaptive_deadline(event.priority, event.complexity_level);
            event_received = ADAPTIVE_TRUE;
        }

        if(event_received == ADAPTIVE_TRUE) {
            processing_start = xTaskGetTickCount();
            io_operations_count++;

            printf("[I/O-SIM] Processing adaptive I/O operation #%u (Priority: %u)\r\n",
                   (unsigned int)io_operations_count, (unsigned int)event.priority);

            io_cycles = 500;
            switch(event.priority) {
                case 1: io_cycles = 200; break;
                case 2: io_cycles = 400; break;
                case 3: io_cycles = 800; break;
                case 4: io_cycles = 1200; break;
                default: io_cycles = 600; break;
            }

            io_cycles = (io_cycles * event.complexity_level) / 2;

            for(i = 0; i < io_cycles; i++);
            vTaskDelay(1);

            processing_end = xTaskGetTickCount();
            total_latency = processing_end - event.timestamp;

            printf("[I/O-SIM] Adaptive I/O completed, latency: ");
            print_uint32(total_latency);
            printf(" ticks (Priority: ");
            print_uint32(event.priority);
            printf(")\r\n");
        }
    }
}

void vTimerHandlerTask(void *pvParameters) {
    uint32_t timer_events = 0;
    volatile int i;
    
    for(;;) {
        if (should_terminate_demo()) {
            printf("[TIMER-HANDLER] Task terminating...\n");
            vTaskDelete(NULL);
        }
        
        if(xSemaphoreTake(xTimerSemaphore, pdMS_TO_TICKS(100)) == pdTRUE) {
            timer_events++;
            printf("[TIMER-HANDLER] Periodic timer event #");
            print_uint32(timer_events);
            printf(" processed\r\n");
            
            for(i = 0; i < 600; i++);
        }
    }
}

/* This is the function that main.c expects to find */
void start_interrupt_driven_io_demo(void) {
    printf("\r\n*** ENHANCED ADAPTIVE INTERRUPT HANDLING SYSTEM DEMO ***\r\n");
    printf("This demo demonstrates advanced interrupt algorithms:\r\n");
    printf("1. Multi-level interrupt priority handling with overflow protection\r\n");
    printf("2. Adaptive deadline adjustment based on system load\r\n");
    printf("3. Dynamic processing complexity optimization\r\n");
    printf("4. Real-time performance monitoring and analysis\r\n");
    printf("5. Enhanced queue management and error handling\r\n");
    printf("6. Automatic termination after %d cycles (%d seconds each)\r\n\r\n", 
           MAX_CYCLES, CYCLE_DURATION_MS/1000);
    
    // Initialize demo start time
    demo_start_time = xTaskGetTickCount();
    demo_should_terminate = ADAPTIVE_FALSE;
    total_cycles = 0;
    
    /* Initialize adaptive configuration with better defaults */
    adaptive_config.base_deadline = pdMS_TO_TICKS(6);
    adaptive_config.max_complexity = 5;
    adaptive_config.load_threshold_low = 25;
    adaptive_config.load_threshold_high = 60;
    adaptive_config.adaptive_enabled = ADAPTIVE_TRUE;
    
    /* Reset all statistics */
    memset(&interrupt_stats, 0, sizeof(interrupt_stats));
    memset(&system_load, 0, sizeof(system_load));
    io_operations_count = 0;
    queue_overflow_count = 0;
    high_priority_overflow_count = 0;
    
    /* Create semaphores and queues with increased capacity */
    xInterruptSemaphore = xSemaphoreCreateBinary();
    xTimerSemaphore = xSemaphoreCreateBinary();
    xIOSemaphore = xSemaphoreCreateBinary();
    xAdaptiveMutex = xSemaphoreCreateMutex();
    xInterruptQueue = xQueueCreate(50, sizeof(interrupt_event_t));
    xHighPriorityQueue = xQueueCreate(30, sizeof(interrupt_event_t));
    
    if(xInterruptSemaphore == NULL || xTimerSemaphore == NULL || 
       xIOSemaphore == NULL || xInterruptQueue == NULL || 
       xHighPriorityQueue == NULL || xAdaptiveMutex == NULL) {
        printf("Failed to create adaptive interrupt handling objects!\r\n");
        return;
    }
    
    /* Create timers with optimized frequencies for better performance */
    xInterruptSimulationTimer = xTimerCreate("AdaptiveInt", pdMS_TO_TICKS(30), pdTRUE, 
                                           (void*)0, vInterruptSimulationCallback);
    xPeriodicTimer = xTimerCreate("Periodic", pdMS_TO_TICKS(120), pdTRUE, 
                                 (void*)1, vPeriodicTimerCallback);
    xCriticalTimer = xTimerCreate("Critical", pdMS_TO_TICKS(180), pdTRUE,
                                 (void*)2, vCriticalInterruptCallback);
    xAdaptiveTimer = xTimerCreate("Adaptive", pdMS_TO_TICKS(1500), pdTRUE,
                                (void*)3, vAdaptiveTimerCallback);
    
    if(xInterruptSimulationTimer == NULL || xPeriodicTimer == NULL || 
       xCriticalTimer == NULL || xAdaptiveTimer == NULL) {
        printf("Failed to create adaptive timers!\r\n");
        return;
    }
    
    /* Create tasks with appropriate priorities */
    xTaskCreate(vInterruptHandlerTask, "AdaptiveIntHandler", 1200, NULL, 5, NULL);
    xTaskCreate(vIOSimulationTask, "AdaptiveIOSim", 1000, NULL, 3, NULL);
    xTaskCreate(vTimerHandlerTask, "TimerHandler", 1000, NULL, 3, NULL);
    xTaskCreate(vInterruptMonitorTask, "AdaptiveMonitor", 1200, NULL, 2, NULL);
    
    printf("Enhanced adaptive interrupt handling tasks created successfully\r\n");
    
    /* Start all timers */
    if(xTimerStart(xInterruptSimulationTimer, 0) != pdPASS ||
       xTimerStart(xPeriodicTimer, 0) != pdPASS ||
       xTimerStart(xCriticalTimer, 0) != pdPASS ||
       xTimerStart(xAdaptiveTimer, 0) != pdPASS) {
        printf("Failed to start adaptive timers!\r\n");
        return;
    }
    
    printf("All enhanced adaptive timers started successfully\r\n");
    printf("Starting FreeRTOS scheduler with optimized adaptive algorithms...\r\n");
    printf("Demo will automatically terminate after %d cycles...\r\n\r\n", MAX_CYCLES);
    
    /* Start the scheduler */
    vTaskStartScheduler();
    
    /* Should never reach here */
    printf("ERROR: Enhanced adaptive scheduler failed to start!\r\n");
    for(;;);
}