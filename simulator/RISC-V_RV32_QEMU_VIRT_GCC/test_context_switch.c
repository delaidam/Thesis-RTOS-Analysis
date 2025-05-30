/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>

/* Test configuration */
#define NUM_CONTEXT_SWITCH_ITERATIONS 1000
#define TEST_TASK_STACK_SIZE    (configMINIMAL_STACK_SIZE * 2)
#define TEST_TASK_PRIORITY      (tskIDLE_PRIORITY + 1)

/* Forward declarations */
static void print_context_switch_statistics(void);

/* Global variables for measurements */
static uint32_t context_switch_cycles[NUM_CONTEXT_SWITCH_ITERATIONS];
static volatile uint32_t context_switch_iteration = 0;
static SemaphoreHandle_t context_switch_semaphore;
static volatile uint32_t start_cycles, end_cycles;

/* Cycle counter functions */
static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

/* Task A - starts measurement and yields to Task B */
static void context_switch_task_a(void *pvParameters) {
    
    printf("Starting Context Switch Performance Test...\n");
    printf("Number of iterations: %d\n", NUM_CONTEXT_SWITCH_ITERATIONS);
    
    /* Wait for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    for (context_switch_iteration = 0; context_switch_iteration < NUM_CONTEXT_SWITCH_ITERATIONS; context_switch_iteration++) {
        
        /* Start measurement */
        start_cycles = get_cycle_count();
        
        /* Trigger context switch by giving semaphore to Task B */
        xSemaphoreGive(context_switch_semaphore);
        
        /* Wait for Task B to return control */
        xSemaphoreTake(context_switch_semaphore, portMAX_DELAY);
        
        /* End measurement when we get back control */
        end_cycles = get_cycle_count();
        
        /* Store the measurement (round-trip context switch time) */
        context_switch_cycles[context_switch_iteration] = end_cycles - start_cycles;
        
        /* Small delay between iterations */
        vTaskDelay(pdMS_TO_TICKS(2));
        
        /* Print progress every 100 iterations */
        if ((context_switch_iteration + 1) % 100 == 0) {
            printf("Completed %lu/%d context switch iterations\n", 
                   context_switch_iteration + 1, NUM_CONTEXT_SWITCH_ITERATIONS);
        }
    }
    
    /* Calculate and print statistics */
    print_context_switch_statistics();
    
    printf("Context switch test completed!\n");
    
    /* Delete self */
    vTaskDelete(NULL);
}

/* Task B - receives semaphore and immediately gives it back */
static void context_switch_task_b(void *pvParameters) {
    for (;;) {
        /* Wait for semaphore from Task A */
        xSemaphoreTake(context_switch_semaphore, portMAX_DELAY);
        
        /* Immediately give it back to complete the round-trip */
        xSemaphoreGive(context_switch_semaphore);
    }
}

/* Function to calculate and print context switch statistics */
static void print_context_switch_statistics(void) {
    uint32_t min_cycles = UINT32_MAX, max_cycles = 0, sum_cycles = 0;
    uint32_t avg_cycles;
    
    printf("\n=== CONTEXT SWITCH PERFORMANCE RESULTS ===\n");
    
    for (int i = 0; i < NUM_CONTEXT_SWITCH_ITERATIONS; i++) {
        uint32_t cycles = context_switch_cycles[i];
        
        if (cycles < min_cycles) min_cycles = cycles;
        if (cycles > max_cycles) max_cycles = cycles;
        sum_cycles += cycles;
    }
    
    avg_cycles = sum_cycles / NUM_CONTEXT_SWITCH_ITERATIONS;
    
    printf("ROUND-TRIP CONTEXT SWITCH CYCLES:\n");
    printf("  Min: %d cycles\n", (int)min_cycles);
    printf("  Max: %d cycles\n", (int)max_cycles);
    printf("  Avg: %d cycles\n", (int)avg_cycles);
    
    /* Note: Round-trip includes two context switches, so divide by 2 for single switch */
    uint32_t single_switch_avg = avg_cycles / 2;
    
    printf("SINGLE CONTEXT SWITCH (estimated):\n");
    printf("  Avg: %d cycles\n", (int)single_switch_avg);
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    printf("Round-trip Context Switch Avg: %d.%d µs\n", 
           (int)(avg_cycles / cpu_freq_mhz), 
           (int)((avg_cycles % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Single Context Switch Avg: %d.%d µs\n", 
           (int)(single_switch_avg / cpu_freq_mhz), 
           (int)((single_switch_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
}

/* Main function to start the context switch test */
void start_context_switch_test(void) {
    /* Create binary semaphore for synchronization */
    context_switch_semaphore = xSemaphoreCreateBinary();
    
    if (context_switch_semaphore == NULL) {
        printf("ERROR: Failed to create semaphore\n");
        return;
    }
    
    /* Create Task B first (lower priority) */
    xTaskCreate(
        context_switch_task_b,            /* Function pointer */
        "CtxSwitchB",                     /* Task name */
        TEST_TASK_STACK_SIZE,             /* Stack size */
        NULL,                             /* Parameters */
        TEST_TASK_PRIORITY,               /* Priority */
        NULL                              /* Task handle */
    );
    
    /* Create Task A (same priority, will start first) */
    xTaskCreate(
        context_switch_task_a,            /* Function pointer */
        "CtxSwitchA",                     /* Task name */
        TEST_TASK_STACK_SIZE,             /* Stack size */
        NULL,                             /* Parameters */
        TEST_TASK_PRIORITY,               /* Priority */
        NULL                              /* Task handle */
    );
    
    printf("Context switch test tasks created. Starting scheduler...\n");

    /* START THE SCHEDULER */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}