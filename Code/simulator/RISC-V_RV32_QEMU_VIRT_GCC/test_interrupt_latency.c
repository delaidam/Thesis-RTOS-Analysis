/* Simple interrupt latency test */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include <stdio.h>
#include <stdint.h>

#define NUM_INTERRUPT_ITERATIONS  50
#define TEST_TASK_STACK_SIZE     (configMINIMAL_STACK_SIZE * 2)

static uint32_t interrupt_latency_cycles[NUM_INTERRUPT_ITERATIONS];
static volatile uint32_t test_iteration = 0;
static QueueHandle_t test_queue;

static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

static void simple_interrupt_test_task(void *pvParameters) {
    uint32_t start_cycles, end_cycles;
    uint32_t test_data;
    
    printf("Starting Simple Interrupt Latency Test...\n");
    printf("Number of iterations: %d\n", NUM_INTERRUPT_ITERATIONS);
    
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    for (test_iteration = 0; test_iteration < NUM_INTERRUPT_ITERATIONS; test_iteration++) {
        
        /* Measure time to send to queue */
        start_cycles = get_cycle_count();
        
        test_data = test_iteration;
        xQueueSend(test_queue, &test_data, 0);
        
        end_cycles = get_cycle_count();
        interrupt_latency_cycles[test_iteration] = end_cycles - start_cycles;
        
        /* Consume the data */
        xQueueReceive(test_queue, &test_data, 0);
        
        vTaskDelay(pdMS_TO_TICKS(10));
        
        if ((test_iteration + 1) % 10 == 0) {
            printf("Completed %lu/%d iterations\n", test_iteration + 1, NUM_INTERRUPT_ITERATIONS);
        }
    }
    
    /* Print results */
    uint32_t min_cycles = UINT32_MAX, max_cycles = 0, sum_cycles = 0;
    
    printf("\n=== SIMPLE INTERRUPT TEST RESULTS ===\n");
    
    for (int i = 0; i < NUM_INTERRUPT_ITERATIONS; i++) {
        uint32_t cycles = interrupt_latency_cycles[i];
        if (cycles < min_cycles) min_cycles = cycles;
        if (cycles > max_cycles) max_cycles = cycles;
        sum_cycles += cycles;
    }
    
    uint32_t avg_cycles = sum_cycles / NUM_INTERRUPT_ITERATIONS;
    
    printf("QUEUE OPERATION CYCLES:\n");
    printf("  Min: %d cycles\n", (int)min_cycles);
    printf("  Max: %d cycles\n", (int)max_cycles);
    printf("  Avg: %d cycles\n", (int)avg_cycles);
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    printf("Queue Operation Avg: %d.%d µs\n", 
           (int)(avg_cycles / cpu_freq_mhz), 
           (int)((avg_cycles % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    
    printf("\nSimple interrupt test completed!\n");
    printf("FREE HEAP: %d bytes\n", (int)xPortGetFreeHeapSize());
    
    vTaskDelete(NULL);
}

void start_interrupt_latency_test(void) {
    test_queue = xQueueCreate(5, sizeof(uint32_t));
    
    if (test_queue == NULL) {
        printf("ERROR: Failed to create queue\n");
        return;
    }
    
    xTaskCreate(
        simple_interrupt_test_task,
        "SimpleIntTest",
        TEST_TASK_STACK_SIZE,
        NULL,
        tskIDLE_PRIORITY + 1,
        NULL
    );
    
    printf("Simple interrupt test created. Starting scheduler...\n");
    vTaskStartScheduler();
    
    for(;;);
}