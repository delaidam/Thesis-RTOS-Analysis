/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>

/* Test configuration */
#define TEST_TASK_STACK_SIZE    (configMINIMAL_STACK_SIZE * 2)
#define TEST_TASK_PRIORITY      (tskIDLE_PRIORITY + 1)
#define NUM_TEST_ITERATIONS     100

/* Forward declaration */
static void print_performance_statistics(void);

/* Global variables for measurements */
static uint32_t task_creation_cycles[NUM_TEST_ITERATIONS];
static uint32_t task_deletion_cycles[NUM_TEST_ITERATIONS];
static volatile uint32_t test_iteration = 0;

/* Simple cycle counter functions - we'll implement these */
static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    /* Read RISC-V cycle counter (mcycle CSR) */
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

/* Test task that will be created and deleted */
static void test_task_function(void *pvParameters) {
    /* Simple task that just delays and exits */
    vTaskDelay(pdMS_TO_TICKS(1));
    
    /* Task will be deleted by the test task */
    vTaskSuspend(NULL);
}

/* Main test task */
static void performance_test_task(void *pvParameters) {
    TaskHandle_t test_task_handle = NULL;
    uint32_t start_cycles, end_cycles;
    BaseType_t result;
    
    printf("Starting Task Creation/Deletion Performance Test...\n");
    printf("Number of iterations: %d\n", NUM_TEST_ITERATIONS);
    
    /* Wait a moment for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    for (test_iteration = 0; test_iteration < NUM_TEST_ITERATIONS; test_iteration++) {
        
        /* === TEST TASK CREATION === */
        start_cycles = get_cycle_count();
        
        result = xTaskCreate(
            test_task_function,           /* Function pointer */
            "TestTask",                   /* Task name */
            TEST_TASK_STACK_SIZE,         /* Stack size */
            NULL,                         /* Parameters */
            TEST_TASK_PRIORITY,           /* Priority */
            &test_task_handle             /* Task handle */
        );
        
        end_cycles = get_cycle_count();
        
        if (result == pdPASS) {
            task_creation_cycles[test_iteration] = end_cycles - start_cycles;
        } else {
            printf("ERROR: Task creation failed at iteration %lu\n", test_iteration);
            task_creation_cycles[test_iteration] = 0;
        }
        
        /* Let the task run briefly */
        vTaskDelay(pdMS_TO_TICKS(5));
        
        /* === TEST TASK DELETION === */
        start_cycles = get_cycle_count();
        
        vTaskDelete(test_task_handle);
        
        end_cycles = get_cycle_count();
        task_deletion_cycles[test_iteration] = end_cycles - start_cycles;
        
        /* Small delay between iterations */
        vTaskDelay(pdMS_TO_TICKS(10));
        
        /* Print progress every 10 iterations */
        if ((test_iteration + 1) % 10 == 0) {
            printf("Completed %lu/%d iterations\n", test_iteration + 1, NUM_TEST_ITERATIONS);
        }
    }
    
    /* Calculate and print statistics */
    print_performance_statistics();
    
    printf("Performance test completed!\n");
    
    /* Delete self */
    vTaskDelete(NULL);
}

/* Function to calculate and print statistics */
static void print_performance_statistics(void) {
    uint32_t creation_min = UINT32_MAX, creation_max = 0, creation_sum = 0;
    uint32_t deletion_min = UINT32_MAX, deletion_max = 0, deletion_sum = 0;
    uint32_t creation_avg, deletion_avg;
    
    printf("\n=== TASK CREATION/DELETION PERFORMANCE RESULTS ===\n");
    
    for (int i = 0; i < NUM_TEST_ITERATIONS; i++) {
        uint32_t creation_time = task_creation_cycles[i];
        uint32_t deletion_time = task_deletion_cycles[i];
        
        if (creation_time > 0) {
            if (creation_time < creation_min) creation_min = creation_time;
            if (creation_time > creation_max) creation_max = creation_time;
            creation_sum += creation_time;
        }
        
        if (deletion_time < deletion_min) deletion_min = deletion_time;
        if (deletion_time > deletion_max) deletion_max = deletion_time;
        deletion_sum += deletion_time;
    }
    
    creation_avg = creation_sum / NUM_TEST_ITERATIONS;
    deletion_avg = deletion_sum / NUM_TEST_ITERATIONS;
    
    printf("TASK CREATION CYCLES:\n");
    printf("  Min: %d cycles\n", (int)creation_min);
    printf("  Max: %d cycles\n", (int)creation_max);
    printf("  Avg: %d cycles\n", (int)creation_avg);
    
    printf("TASK DELETION CYCLES:\n");
    printf("  Min: %d cycles\n", (int)deletion_min);
    printf("  Max: %d cycles\n", (int)deletion_max);
    printf("  Avg: %d cycles\n", (int)deletion_avg);
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    printf("Task Creation Avg: %d.%d µs\n", 
           (int)(creation_avg / cpu_freq_mhz), 
           (int)((creation_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Task Deletion Avg: %d.%d µs\n", 
           (int)(deletion_avg / cpu_freq_mhz), 
           (int)((deletion_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    
    printf("\nFREE HEAP AFTER TEST: %d bytes\n", (int)xPortGetFreeHeapSize());
}

/* Main function to start the performance test */
void start_performance_test(void) {
    /* Create the main test task */
    xTaskCreate(
        performance_test_task,            /* Function pointer */
        "PerfTest",                       /* Task name */
        configMINIMAL_STACK_SIZE * 4,     /* Stack size */
        NULL,                             /* Parameters */
        tskIDLE_PRIORITY + 2,             /* Priority */
        NULL                              /* Task handle */
    );
    
    printf("Performance test task created. Starting scheduler...\n");

    /* START THE SCHEDULER - ovo je najvažnije! */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}