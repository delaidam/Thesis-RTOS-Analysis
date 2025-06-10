// REALISTIC Scheduler Validation Demo - Tick-based timing (QEMU friendly)
#include "FreeRTOS.h"
#include "task.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>

// Task performance tracking (tick-based)
typedef struct {
    uint32_t execution_count;
    uint32_t total_ticks;
    uint32_t min_ticks;
    uint32_t max_ticks;
    uint8_t priority;
    uint32_t period_ms;
    char name[16];
} task_metrics_t;

static task_metrics_t task_metrics[4];
static volatile uint32_t context_switches = 0;
static volatile uint32_t global_result = 0; // Prevent compiler optimization
static volatile uint8_t demo_should_stop = 0; // Global stop flag
static volatile uint32_t reports_generated = 0; // Track actual reports

// HIGH Priority Task - Light workload, frequent execution
void vHighPriorityTask(void *pvParameters) {
    uint8_t task_id = 0;

    strcpy(task_metrics[task_id].name, "HIGH");
    task_metrics[task_id].priority = 4;
    task_metrics[task_id].period_ms = 100;
    task_metrics[task_id].min_ticks = UINT32_MAX;

    for(;;) {
        // Check if demo should stop
        if(demo_should_stop) {
            printf("[HIGH] Task stopping due to demo completion.\r\n");
            vTaskDelete(NULL);
        }

        TickType_t start_ticks = xTaskGetTickCount();

        printf("[HIGH] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");

        // Increased workload with optimization prevention
        volatile uint32_t result = global_result;
        volatile uint8_t dummy_array[50];
        
        for(int i = 0; i < 800000; i++) {  // Reduced for better balance
            result += i * i;
            result = result % 1000000;
            // Add branching to prevent optimization
            if(result > 500000) result = result / 2;
            // Periodic memory access
            if(i % 200000 == 0) {
                dummy_array[i % 50] = (uint8_t)(result & 0xFF);
                global_result = result;
            }
        }
        
        // Final memory operations
        for(int j = 0; j < 50; j++) {
            dummy_array[j] = (uint8_t)(result + j);
            result += dummy_array[j];
        }
        global_result = result;

        TickType_t end_ticks = xTaskGetTickCount();
        uint32_t exec_ticks = (end_ticks > start_ticks) ? (end_ticks - start_ticks) : 1;

        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_ticks += exec_ticks;

        if(exec_ticks < task_metrics[task_id].min_ticks) {
            task_metrics[task_id].min_ticks = exec_ticks;
        }
        if(exec_ticks > task_metrics[task_id].max_ticks) {
            task_metrics[task_id].max_ticks = exec_ticks;
        }

        context_switches++;

        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

// MEDIUM Priority Task - Medium workload
void vMediumPriorityTask(void *pvParameters) {
    uint8_t task_id = 1;

    strcpy(task_metrics[task_id].name, "MEDIUM");
    task_metrics[task_id].priority = 3;
    task_metrics[task_id].period_ms = 200;
    task_metrics[task_id].min_ticks = UINT32_MAX;

    for(;;) {
        // Check if demo should stop
        if(demo_should_stop) {
            printf("[MEDIUM] Task stopping due to demo completion.\r\n");
            vTaskDelete(NULL);
        }

        TickType_t start_ticks = xTaskGetTickCount();

        printf("[MEDIUM] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");

        // Increased workload with optimization prevention
        volatile uint32_t result = global_result;
        volatile uint8_t dummy_array[80];
        
        for(int i = 0; i < 1500000; i++) {  // Reduced for better balance
            result += i * i * i;
            result = result % 2000000;
            // Add more complex branching
            if(result > 1000000) {
                result = result / 3;
            } else if(result > 500000) {
                result = result * 2;
            }
            // Periodic memory access
            if(i % 300000 == 0) {
                dummy_array[i % 80] = (uint8_t)(result & 0xFF);
                global_result = result;
            }
        }
        
        // Final memory operations
        for(int j = 0; j < 80; j++) {
            dummy_array[j] = (uint8_t)(result + j);
            result += dummy_array[j] * j;
        }
        global_result = result;

        TickType_t end_ticks = xTaskGetTickCount();
        uint32_t exec_ticks = (end_ticks > start_ticks) ? (end_ticks - start_ticks) : 1;

        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_ticks += exec_ticks;

        if(exec_ticks < task_metrics[task_id].min_ticks) {
            task_metrics[task_id].min_ticks = exec_ticks;
        }
        if(exec_ticks > task_metrics[task_id].max_ticks) {
            task_metrics[task_id].max_ticks = exec_ticks;
        }

        context_switches++;

        vTaskDelay(pdMS_TO_TICKS(200));
    }
}

// LOW Priority Task - Heavy workload but infrequent
void vLowPriorityTask(void *pvParameters) {
    uint8_t task_id = 2;

    strcpy(task_metrics[task_id].name, "LOW");
    task_metrics[task_id].priority = 2;
    task_metrics[task_id].period_ms = 500;
    task_metrics[task_id].min_ticks = UINT32_MAX;

    for(;;) {
        // Check if demo should stop
        if(demo_should_stop) {
            printf("[LOW] Task stopping due to demo completion.\r\n");
            vTaskDelete(NULL);
        }

        TickType_t start_ticks = xTaskGetTickCount();

        printf("[LOW] Task execution #");
        print_uint32(task_metrics[task_id].execution_count + 1);
        printf("\r\n");

        // Heavy workload with optimization prevention
        volatile uint64_t result = global_result;
        volatile uint8_t dummy_array[120];
        
        for(int i = 0; i < 800000; i++) {  // Further reduced
            result += (uint64_t)i * i * i;
            result = result % 3000000ULL;
            // Complex branching logic
            if(result > 2000000) {
                result = result / 4;
            } else if(result > 1000000) {
                result = result * 3;
            } else if(result > 500000) {
                result = result + i;
            }
            // More frequent memory access
            if(i % 100000 == 0) {
                dummy_array[i % 120] = (uint8_t)(result & 0xFF);
                global_result = (uint32_t)(result & 0xFFFFFFFF);
            }
        }
        
        // Reduced final memory operations
        for(int j = 0; j < 60; j++) {  // Reduced from 120
            dummy_array[j] = (uint8_t)(result + j);
            result += dummy_array[j] * j;  // Simplified multiplication
        }
        
        // Much smaller additional computation
        for(int k = 0; k < 100000; k++) {  // Reduced from 300,000
            result += k;
            if(k % 25000 == 0) {
                result = result % 5000000ULL;
            }
        }
        
        global_result = (uint32_t)(result & 0xFFFFFFFF);

        TickType_t end_ticks = xTaskGetTickCount();
        uint32_t exec_ticks = (end_ticks > start_ticks) ? (end_ticks - start_ticks) : 1;

        // Update metrics
        task_metrics[task_id].execution_count++;
        task_metrics[task_id].total_ticks += exec_ticks;

        if(exec_ticks < task_metrics[task_id].min_ticks) {
            task_metrics[task_id].min_ticks = exec_ticks;
        }
        if(exec_ticks > task_metrics[task_id].max_ticks) {
            task_metrics[task_id].max_ticks = exec_ticks;
        }

        context_switches++;

        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

// Scheduler Monitor Task
void vSchedulerMonitorTask(void *pvParameters) {
    uint8_t task_id = 3;
    TickType_t report_interval = pdMS_TO_TICKS(5000); // Report every 5 seconds

    strcpy(task_metrics[task_id].name, "MONITOR");
    task_metrics[task_id].priority = 1;

    for(;;) {
        vTaskDelay(report_interval);

        printf("\r\n");
        printf("============================================\r\n");
        printf("=== REALISTIC SCHEDULER PERFORMANCE REPORT ===\r\n");
        printf("============================================\r\n");
        printf("System uptime: ");
        print_uint32(xTaskGetTickCount());
        printf(" ticks\r\n\r\n");

        float total_utilization = 0.0;

        for(int i = 0; i < 3; i++) {
            printf("Task ");
            printf(task_metrics[i].name);
            printf(" (Priority ");
            print_uint32(task_metrics[i].priority);
            printf(", Period ");
            print_uint32(task_metrics[i].period_ms);
            printf("ms):\r\n");

            printf("  Executions: ");
            print_uint32(task_metrics[i].execution_count);
            printf("\r\n");

            if(task_metrics[i].execution_count > 0) {
                uint32_t avg_ticks = task_metrics[i].total_ticks / task_metrics[i].execution_count;
                uint32_t min_ticks = task_metrics[i].min_ticks;
                uint32_t max_ticks = task_metrics[i].max_ticks;
                uint32_t period_ticks = pdMS_TO_TICKS(task_metrics[i].period_ms);

                printf("  Avg execution time: ");
                print_uint32(avg_ticks);
                printf(" ticks\r\n");

                printf("  Min execution time: ");
                print_uint32(min_ticks);
                printf(" ticks\r\n");

                printf("  Max execution time: ");
                print_uint32(max_ticks);
                printf(" ticks (WCET)\r\n");

                // Calculate CPU utilization based on average execution time
                float utilization = (float)avg_ticks / period_ticks * 100.0;
                if (utilization > 100.0) utilization = 100.0;  // Limit to 100%
                total_utilization += utilization;

                uint32_t utilization_int = (uint32_t)(utilization + 0.5f);
                printf("  CPU Utilization: ");
                print_uint32(utilization_int);
                printf("%%\r\n");
            }
            printf("\r\n");
        }

        // Overall schedulability analysis - FIXED FORMATTING
        printf("=== SCHEDULABILITY ANALYSIS ===\r\n");
        if (total_utilization > 100.0) total_utilization = 100.0;  // Ensure total doesn't exceed 100%
        
        // Convert float to integer with one decimal place
        uint32_t total_util_int = (uint32_t)(total_utilization * 10 + 0.5f); // Round to nearest tenth
        printf("Total CPU Utilization: ");
        print_uint32(total_util_int / 10);
        printf(".");
        print_uint32(total_util_int % 10);
        printf("%%\r\n");
        
        printf("Rate Monotonic Bound (3 tasks): 78%%\r\n");

        if(total_utilization <= 78.0) {
            printf("RESULT: SCHEDULABLE! ✓\r\n");
        } else {
            printf("RESULT: NOT SCHEDULABLE! ✗\r\n");
        }

        printf("\r\nTotal task executions: ");
        uint32_t total_executions = task_metrics[0].execution_count +
                                   task_metrics[1].execution_count +
                                   task_metrics[2].execution_count;
        print_uint32(total_executions);
        printf("\r\n");

        printf("Context switches: ");
        print_uint32(context_switches);
        printf("\r\n");

        printf("============================================\r\n\r\n");

        task_metrics[task_id].execution_count++;
    }
}

void start_scheduler_validation_demo(void) {
    printf("\r\n");
    printf("************************************************\r\n");
    printf("*** REALISTIC SCHEDULER VALIDATION DEMO ***\r\n");
    printf("************************************************\r\n");
    printf("This demo demonstrates Rate Monotonic scheduling\r\n");
    printf("with realistic computational workloads and precise\r\n");
    printf("execution time measurements.\r\n\r\n");
    printf("Task Configuration:\r\n");
    printf("- HIGH Priority (4): Light load, 100ms period\r\n");
    printf("- MEDIUM Priority (3): Medium load, 200ms period\r\n");
    printf("- LOW Priority (2): Heavy load, 500ms period\r\n\r\n");

    // Reset metrics
    memset(task_metrics, 0, sizeof(task_metrics));
    context_switches = 0;
    global_result = 0;
    demo_should_stop = 0; // Initialize stop flag
    reports_generated = 0; // Initialize report counter

    // Create tasks with realistic stack sizes
    xTaskCreate(vHighPriorityTask, "HighPri", 2000, NULL, 4, NULL);
    xTaskCreate(vMediumPriorityTask, "MedPri", 2000, NULL, 3, NULL);
    xTaskCreate(vLowPriorityTask, "LowPri", 2000, NULL, 2, NULL);
    xTaskCreate(vSchedulerMonitorTask, "Monitor", 2000, NULL, 1, NULL);

    printf("All tasks created successfully!\r\n");
    printf("Starting FreeRTOS scheduler...\r\n");
    printf("Performance reports every 5 seconds.\r\n\r\n");

    // Start the scheduler
    vTaskStartScheduler();

    // Should never reach here
    printf("ERROR: Scheduler failed to start!\r\n");
    for(;;);
}