#include "FreeRTOS.h"
#include "task.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>

// Task performance tracking
typedef struct {
    uint32_t execution_count;
    TickType_t total_execution_time;
    TickType_t min_execution_time;
    TickType_t max_execution_time;
    uint8_t priority;
    char name[16];
} task_metrics_t;

static task_metrics_t task_metrics[4];
static volatile uint32_t context_switches = 0;

// High Priority Task (Priority 4)
void vHighPriorityTask(void *pvParameters) {
    uint8_t task_id = 0;
    TickType_t start_time, end_time, execution_time;
    
    // Initialize metrics
    strcpy(task_metrics[task_id].name, "HIGH");
    task_metrics[task_id].priority = 4;
    task_metrics[task_id].min_execution_time = portMAX_DELAY;
    
    for(;;) {
        start_time = xTaskGetTickCount();
        
        // Critical high-priority work simulation
        printf("[HIGH] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");
        
        // Short but important operation
        for(volatile int i = 0; i < 500; i++) {
            // Fast processing simulation
        }
        
        end_time = xTaskGetTickCount();
        execution_time = end_time - start_time;
        
        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_execution_time += execution_time;
        
        if(execution_time < task_metrics[task_id].min_execution_time) {
            task_metrics[task_id].min_execution_time = execution_time;
        }
        if(execution_time > task_metrics[task_id].max_execution_time) {
            task_metrics[task_id].max_execution_time = execution_time;
        }
        
        context_switches++;
        
        // Execute every 100ms
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

// Medium Priority Task (Priority 3)
void vMediumPriorityTask(void *pvParameters) {
    uint8_t task_id = 1;
    TickType_t start_time, end_time, execution_time;
    
    // Initialize metrics
    strcpy(task_metrics[task_id].name, "MEDIUM");
    task_metrics[task_id].priority = 3;
    task_metrics[task_id].min_execution_time = portMAX_DELAY;
    
    for(;;) {
        start_time = xTaskGetTickCount();
        
        printf("[MEDIUM] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");
        
        // Medium complexity operation
        for(volatile int i = 0; i < 2000; i++) {
            // Computation simulation
        }
        
        end_time = xTaskGetTickCount();
        execution_time = end_time - start_time;
        
        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_execution_time += execution_time;
        
        if(execution_time < task_metrics[task_id].min_execution_time) {
            task_metrics[task_id].min_execution_time = execution_time;
        }
        if(execution_time > task_metrics[task_id].max_execution_time) {
            task_metrics[task_id].max_execution_time = execution_time;
        }
        
        context_switches++;
        
        // Execute every 200ms
        vTaskDelay(pdMS_TO_TICKS(200));
    }
}

// Low Priority Task (Priority 2)
void vLowPriorityTask(void *pvParameters) {
    uint8_t task_id = 2;
    TickType_t start_time, end_time, execution_time;
    
    // Initialize metrics
    strcpy(task_metrics[task_id].name, "LOW");
    task_metrics[task_id].priority = 2;
    task_metrics[task_id].min_execution_time = portMAX_DELAY;
    
    for(;;) {
        start_time = xTaskGetTickCount();
        
        printf("[LOW] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");
        
        // Long background operation
        for(volatile int i = 0; i < 5000; i++) {
            // Background processing simulation
        }
        
        end_time = xTaskGetTickCount();
        execution_time = end_time - start_time;
        
        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_execution_time += execution_time;
        
        if(execution_time < task_metrics[task_id].min_execution_time) {
            task_metrics[task_id].min_execution_time = execution_time;
        }
        if(execution_time > task_metrics[task_id].max_execution_time) {
            task_metrics[task_id].max_execution_time = execution_time;
        }
        
        context_switches++;
        
        // Execute every 500ms
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

// Scheduler Monitor Task (Priority 1)
void vSchedulerMonitorTask(void *pvParameters) {
    uint8_t task_id = 3;
    TickType_t report_interval = pdMS_TO_TICKS(3000); // Report every 3 seconds
    
    strcpy(task_metrics[task_id].name, "MONITOR");
    task_metrics[task_id].priority = 1;
    
    for(;;) {
        vTaskDelay(report_interval);
        
        printf("\r\n=== SCHEDULER PERFORMANCE REPORT ===\r\n");
        printf("Uptime: ");
        print_uint32(xTaskGetTickCount());
        printf(" ticks\r\n");
        
        for(int i = 0; i < 3; i++) {
            printf("Task ");
            printf(task_metrics[i].name);
            printf(" (Priority ");
            print_uint32(task_metrics[i].priority);
            printf("):\r\n");
            
            printf("  Executions: ");
            print_uint32(task_metrics[i].execution_count);
            printf("\r\n");
            
            if(task_metrics[i].execution_count > 0) {
                uint32_t avg_time = task_metrics[i].total_execution_time / task_metrics[i].execution_count;
                printf("  Avg execution time: ");
                print_uint32(avg_time);
                printf(" ticks\r\n");
                
                printf("  Min execution time: ");
                print_uint32(task_metrics[i].min_execution_time);
                printf(" ticks\r\n");
                
                printf("  Max execution time: ");
                print_uint32(task_metrics[i].max_execution_time);
                printf(" ticks\r\n");
            }
            printf("\r\n");
        }
        
        uint32_t total_executions = task_metrics[0].execution_count + 
                                   task_metrics[1].execution_count + 
                                   task_metrics[2].execution_count;
        
        printf("Total task executions: ");
        print_uint32(total_executions);
        printf("\r\n");
        
        printf("Context switches: ");
        print_uint32(context_switches);
        printf("\r\n");
        
        printf("======================================\r\n\r\n");
        
        task_metrics[task_id].execution_count++;
    }
}

// Helper function to print integers via UART

void start_scheduler_validation_demo(void) {
    printf("\r\n*** STARTING SCHEDULER VALIDATION DEMO ***\r\n");
    printf("This demo shows multi-task scheduling with different priorities.\r\n");
    printf("Tasks will run and report their execution statistics.\r\n\r\n");
    
    // Reset metrics
    memset(task_metrics, 0, sizeof(task_metrics));
    context_switches = 0;
    
    // Create tasks with different priorities
    xTaskCreate(vHighPriorityTask, "HighPri", 1000, NULL, 4, NULL);
    xTaskCreate(vMediumPriorityTask, "MedPri", 1000, NULL, 3, NULL);
    xTaskCreate(vLowPriorityTask, "LowPri", 1000, NULL, 2, NULL);
    xTaskCreate(vSchedulerMonitorTask, "Monitor", 1000, NULL, 1, NULL);
    
    printf("Scheduler validation demo tasks created successfully\r\n");
    printf("Starting FreeRTOS scheduler...\r\n\r\n");
    
    // Start the scheduler
    vTaskStartScheduler();
    
    // Should never reach here
    printf("ERROR: Scheduler failed to start!\r\n");
    for(;;);
}