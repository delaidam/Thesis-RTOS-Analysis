#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
#include "timers.h"
#include "queue.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>

// Interrupt event structure
typedef struct {
    uint8_t interrupt_type;
    uint32_t data;
    TickType_t timestamp;
    uint8_t priority;
    char description[32];
} interrupt_event_t;

// Interrupt performance tracking
typedef struct {
    uint32_t interrupt_count;
    uint32_t total_response_time;
    uint32_t min_response_time;
    uint32_t max_response_time;
    uint32_t missed_deadlines;
    uint32_t max_isr_time;
    TickType_t last_interrupt_time;
} interrupt_performance_t;

// Global variables
static SemaphoreHandle_t xInterruptSemaphore;
static SemaphoreHandle_t xTimerSemaphore;
static SemaphoreHandle_t xIOSemaphore;
static QueueHandle_t xInterruptQueue;
static TimerHandle_t xInterruptSimulationTimer;
static TimerHandle_t xPeriodicTimer;
static interrupt_performance_t interrupt_stats;
static volatile uint32_t isr_entry_time;
static volatile uint32_t isr_exit_time;
static volatile uint32_t io_operations_count = 0;

// Helper function to print integers via UART

// Timer callback - simulates interrupt source
void vInterruptSimulationCallback(TimerHandle_t xTimer) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    isr_entry_time = xTaskGetTickCountFromISR();
    
    interrupt_event_t event;
    event.interrupt_type = 1; // Timer interrupt
    event.data = interrupt_stats.interrupt_count++;
    event.timestamp = isr_entry_time;
    event.priority = 3;
    sprintf(event.description, "Timer ISR #");
    print_uint32(event.data);
    
    // Fast ISR simulation
    for(volatile int i = 0; i < 100; i++); // Short ISR processing
    
    // Signal waiting tasks
    xSemaphoreGiveFromISR(xInterruptSemaphore, &xHigherPriorityTaskWoken);
    xQueueSendFromISR(xInterruptQueue, &event, &xHigherPriorityTaskWoken);
    
    isr_exit_time = xTaskGetTickCountFromISR();
    uint32_t isr_duration = isr_exit_time - isr_entry_time;
    
    if(isr_duration > interrupt_stats.max_isr_time) {
        interrupt_stats.max_isr_time = isr_duration;
    }
    
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

// Periodic timer callback
void vPeriodicTimerCallback(TimerHandle_t xTimer) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    
    interrupt_event_t event;
    event.interrupt_type = 2; // Periodic timer
    event.data = 0xFF;
    event.timestamp = xTaskGetTickCountFromISR();
    event.priority = 2;
    sprintf(event.description, "Periodic Timer");
    
    xSemaphoreGiveFromISR(xTimerSemaphore, &xHigherPriorityTaskWoken);
    xQueueSendFromISR(xInterruptQueue, &event, &xHigherPriorityTaskWoken);
    
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

// High-priority interrupt handler task
void vInterruptHandlerTask(void *pvParameters) {
    TickType_t response_start, response_end, response_time;
    const TickType_t deadline = pdMS_TO_TICKS(5); // 5ms deadline
    
    for(;;) {
        // Wait for interrupt signal
        if(xSemaphoreTake(xInterruptSemaphore, portMAX_DELAY) == pdTRUE) {
            response_start = xTaskGetTickCount();
            
            // Deterministic interrupt processing
            printf("[INT-HANDLER] Processing interrupt #");
            print_uint32(interrupt_stats.interrupt_count);
            printf("\r\n");
            
            // Deterministic processing with fixed time
            for(volatile int i = 0; i < 1500; i++);
            
            response_end = xTaskGetTickCount();
            response_time = response_end - isr_entry_time;
            
            // Update statistics
            interrupt_stats.total_response_time += response_time;
            
            if(response_time < interrupt_stats.min_response_time || interrupt_stats.min_response_time == 0) {
                interrupt_stats.min_response_time = response_time;
            }
            if(response_time > interrupt_stats.max_response_time) {
                interrupt_stats.max_response_time = response_time;
            }
            
            // Check deadline
            if(response_time > deadline) {
                interrupt_stats.missed_deadlines++;
                printf("[WARNING] Interrupt deadline missed! Response time: ");
                print_uint32(response_time);
                printf(" ticks\r\n");
            }
            
            printf("[INT-HANDLER] Response time: ");
            print_uint32(response_time);
            printf(" ticks (ISR: ");
            print_uint32(isr_exit_time - isr_entry_time);
            printf(" ticks)\r\n");
            
            interrupt_stats.last_interrupt_time = response_end;
            
            // Signal I/O operation
            xSemaphoreGive(xIOSemaphore);
        }
    }
}

// I/O simulation task
void vIOSimulationTask(void *pvParameters) {
    interrupt_event_t event;
    
    for(;;) {
        // Wait for I/O signal or process queued events
        if(xSemaphoreTake(xIOSemaphore, pdMS_TO_TICKS(100)) == pdTRUE || 
           xQueueReceive(xInterruptQueue, &event, pdMS_TO_TICKS(10)) == pdTRUE) {
            
            TickType_t processing_start = xTaskGetTickCount();
            io_operations_count++;
            
            printf("[I/O-SIM] Processing I/O operation #");
            print_uint32(io_operations_count);
            
            if(xQueueReceive(xInterruptQueue, &event, 0) == pdTRUE) {
                printf(" - Event type ");
                print_uint32(event.interrupt_type);
                printf(", data: ");
                print_uint32(event.data);
            }
            printf("\r\n");
            
            // Simulate different types of I/O operations
            switch(event.interrupt_type) {
                case 1: // Timer interrupt - fast processing
                    for(volatile int i = 0; i < 1000; i++);
                    printf("[I/O-SIM] Fast timer I/O completed\r\n");
                    break;
                    
                case 2: // Periodic timer - medium processing
                    for(volatile int i = 0; i < 2500; i++);
                    printf("[I/O-SIM] Periodic I/O completed\r\n");
                    break;
                    
                default:
                    for(volatile int i = 0; i < 500; i++);
                    printf("[I/O-SIM] Default I/O completed\r\n");
                    break;
            }
            
            TickType_t processing_end = xTaskGetTickCount();
            TickType_t total_latency = processing_end - event.timestamp;
            
            printf("[I/O-SIM] Total I/O latency: ");
            print_uint32(total_latency);
            printf(" ticks\r\n");
        }
    }
}

// Periodic timer handler task
void vTimerHandlerTask(void *pvParameters) {
    uint32_t timer_events = 0;
    
    for(;;) {
        if(xSemaphoreTake(xTimerSemaphore, portMAX_DELAY) == pdTRUE) {
            timer_events++;
            printf("[TIMER-HANDLER] Periodic timer event #");
            print_uint32(timer_events);
            printf(" processed\r\n");
            
            // Periodic processing simulation
            for(volatile int i = 0; i < 800; i++);
        }
    }
}

// Performance monitoring task
void vInterruptMonitorTask(void *pvParameters) {
    TickType_t report_interval = pdMS_TO_TICKS(4000);
    
    for(;;) {
        vTaskDelay(report_interval);
        
        printf("\r\n=== INTERRUPT PERFORMANCE REPORT ===\r\n");
        printf("Total interrupts processed: ");
        print_uint32(interrupt_stats.interrupt_count);
        printf("\r\n");
        
        printf("Total I/O operations: ");
        print_uint32(io_operations_count);
        printf("\r\n");
        
        if(interrupt_stats.interrupt_count > 0) {
            uint32_t avg_response = interrupt_stats.total_response_time / interrupt_stats.interrupt_count;
            printf("Average response time: ");
            print_uint32(avg_response);
            printf(" ticks\r\n");
            
            printf("Min response time: ");
            print_uint32(interrupt_stats.min_response_time);
            printf(" ticks\r\n");
            
            printf("Max response time: ");
            print_uint32(interrupt_stats.max_response_time);
            printf(" ticks\r\n");
            
            printf("Max ISR duration: ");
            print_uint32(interrupt_stats.max_isr_time);
            printf(" ticks\r\n");
            
            printf("Missed deadlines: ");
            print_uint32(interrupt_stats.missed_deadlines);
            printf("\r\n");
            
            // Calculate success rate
            uint32_t successful_interrupts = interrupt_stats.interrupt_count - interrupt_stats.missed_deadlines;
            uint32_t success_rate = (successful_interrupts * 100) / interrupt_stats.interrupt_count;
            printf("Deadline success rate: ");
            print_uint32(success_rate);
            printf("%\r\n");
        }
        
        printf("====================================\r\n\r\n");
    }
}

void start_interrupt_driven_io_demo(void) {
    printf("\r\n*** STARTING INTERRUPT-DRIVEN I/O DEMO ***\r\n");
    printf("This demo shows interrupt handling and I/O operations.\r\n");
    printf("Timers simulate interrupts that trigger I/O tasks.\r\n\r\n");
    
    // Reset statistics
    memset(&interrupt_stats, 0, sizeof(interrupt_stats));
    io_operations_count = 0;
    
    // Create semaphores and queues
    xInterruptSemaphore = xSemaphoreCreateBinary();
    xTimerSemaphore = xSemaphoreCreateBinary();
    xIOSemaphore = xSemaphoreCreateBinary();
    xInterruptQueue = xQueueCreate(15, sizeof(interrupt_event_t));
    
    if(xInterruptSemaphore == NULL || xTimerSemaphore == NULL || 
       xIOSemaphore == NULL || xInterruptQueue == NULL) {
        printf("Failed to create interrupt handling objects!\r\n");
        return;
    }
    
    // Create timers for interrupt simulation
    xInterruptSimulationTimer = xTimerCreate("IntSim", pdMS_TO_TICKS(300), pdTRUE, 
                                           (void*)0, vInterruptSimulationCallback);
    xPeriodicTimer = xTimerCreate("Periodic", pdMS_TO_TICKS(800), pdTRUE, 
                                 (void*)1, vPeriodicTimerCallback);
    
    if(xInterruptSimulationTimer == NULL || xPeriodicTimer == NULL) {
        printf("Failed to create timers!\r\n");
        return;
    }
    
    // Create tasks
    xTaskCreate(vInterruptHandlerTask, "IntHandler", 1000, NULL, 4, NULL);
    xTaskCreate(vIOSimulationTask, "IOSim", 1000, NULL, 3, NULL);
    xTaskCreate(vTimerHandlerTask, "TimerHandler", 1000, NULL, 3, NULL);
    xTaskCreate(vInterruptMonitorTask, "Monitor", 1000, NULL, 2, NULL);
    
    printf("Interrupt-driven I/O demo tasks created successfully\r\n");
    
    // Start timers
    if(xTimerStart(xInterruptSimulationTimer, 0) != pdPASS) {
        printf("Failed to start interrupt simulation timer!\r\n");
        return;
    }
    
    if(xTimerStart(xPeriodicTimer, 0) != pdPASS) {
        printf("Failed to start periodic timer!\r\n");
        return;
    }
    
    printf("Timers started successfully\r\n");
    printf("Starting FreeRTOS scheduler...\r\n\r\n");
    
    // Start the scheduler
    vTaskStartScheduler();
    
    // Should never reach here
    printf("ERROR: Scheduler failed to start!\r\n");
    for(;;);
}