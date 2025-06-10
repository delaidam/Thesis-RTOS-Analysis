/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>

/* Test configuration */
#define NUM_MEMORY_ITERATIONS    200
#define TEST_TASK_STACK_SIZE    (configMINIMAL_STACK_SIZE * 2)
#define TEST_TASK_PRIORITY      (tskIDLE_PRIORITY + 1)

/* Different allocation sizes to test */
#define SMALL_ALLOC_SIZE        32
#define MEDIUM_ALLOC_SIZE       128
#define LARGE_ALLOC_SIZE        512

/* Forward declarations */
static void print_memory_statistics(uint32_t num_iterations, const char* size_name);

/* Global variables for measurements */
static uint32_t malloc_cycles[NUM_MEMORY_ITERATIONS];
static uint32_t free_cycles[NUM_MEMORY_ITERATIONS];
static volatile uint32_t memory_iteration = 0;
static void* allocated_pointers[NUM_MEMORY_ITERATIONS];

/* Cycle counter functions */
static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

/* Function to test memory allocation performance */
static void test_memory_allocation(size_t alloc_size, const char* size_name) {
    uint32_t start_cycles, end_cycles;
    
    printf("\n=== TESTING %s ALLOCATIONS (%d bytes) ===\n", size_name, (int)alloc_size);
    printf("Free heap before test: %d bytes\n", (int)xPortGetFreeHeapSize());
    
    /* Reset iteration counter */
    memory_iteration = 0;
    
    /* Test allocation phase */
    for (memory_iteration = 0; memory_iteration < NUM_MEMORY_ITERATIONS; memory_iteration++) {
        
        /* Measure allocation time */
        start_cycles = get_cycle_count();
        
        allocated_pointers[memory_iteration] = pvPortMalloc(alloc_size);
        
        end_cycles = get_cycle_count();
        
        if (allocated_pointers[memory_iteration] != NULL) {
            malloc_cycles[memory_iteration] = end_cycles - start_cycles;
            
            /* Write to allocated memory to ensure it's properly allocated */
            *((uint32_t*)allocated_pointers[memory_iteration]) = memory_iteration;
        } else {
            printf("ERROR: Allocation failed at iteration %lu\n", memory_iteration);
            malloc_cycles[memory_iteration] = 0;
            break;
        }
        
        /* Print progress every 50 iterations */
        if ((memory_iteration + 1) % 50 == 0) {
            printf("Allocated %lu/%d blocks\n", memory_iteration + 1, NUM_MEMORY_ITERATIONS);
        }
    }
    
    uint32_t successful_allocations = memory_iteration;
    
    printf("Free heap after allocations: %d bytes\n", (int)xPortGetFreeHeapSize());
    
    /* Test deallocation phase */
    for (uint32_t i = 0; i < successful_allocations; i++) {
        
        if (allocated_pointers[i] != NULL) {
            /* Verify data integrity before freeing */
            uint32_t stored_value = *((uint32_t*)allocated_pointers[i]);
            if (stored_value != i) {
                printf("WARNING: Data corruption detected at block %lu\n", i);
            }
            
            /* Measure deallocation time */
            start_cycles = get_cycle_count();
            
            vPortFree(allocated_pointers[i]);
            
            end_cycles = get_cycle_count();
            
            free_cycles[i] = end_cycles - start_cycles;
            allocated_pointers[i] = NULL;
        } else {
            free_cycles[i] = 0;
        }
        
        /* Print progress every 50 iterations */
        if ((i + 1) % 50 == 0) {
            printf("Freed %lu/%lu blocks\n", i + 1, successful_allocations);
        }
    }
    
    printf("Free heap after deallocations: %d bytes\n", (int)xPortGetFreeHeapSize());
    
    /* Calculate and print statistics for this allocation size */
    print_memory_statistics(successful_allocations, size_name);
}

/* Memory performance test task */
static void memory_performance_task(void *pvParameters) {
    
    printf("Starting Memory Allocation Performance Test...\n");
    printf("Number of iterations per size: %d\n", NUM_MEMORY_ITERATIONS);
    
    /* Wait for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    /* Test different allocation sizes */
    test_memory_allocation(SMALL_ALLOC_SIZE, "SMALL");
    vTaskDelay(pdMS_TO_TICKS(500));
    
    test_memory_allocation(MEDIUM_ALLOC_SIZE, "MEDIUM");
    vTaskDelay(pdMS_TO_TICKS(500));
    
    test_memory_allocation(LARGE_ALLOC_SIZE, "LARGE");
    
    printf("\nMemory allocation test completed!\n");
    
    /* Delete self */
    vTaskDelete(NULL);
}

/* Function to calculate and print memory allocation statistics */
static void print_memory_statistics(uint32_t num_iterations, const char* size_name) {
    uint32_t malloc_min = UINT32_MAX, malloc_max = 0, malloc_sum = 0;
    uint32_t free_min = UINT32_MAX, free_max = 0, free_sum = 0;
    uint32_t malloc_avg, free_avg;
    uint32_t valid_malloc_count = 0, valid_free_count = 0;
    
    printf("\n=== %s ALLOCATION STATISTICS ===\n", size_name);
    
    for (uint32_t i = 0; i < num_iterations; i++) {
        uint32_t malloc_time = malloc_cycles[i];
        uint32_t free_time = free_cycles[i];
        
        if (malloc_time > 0) {
            if (malloc_time < malloc_min) malloc_min = malloc_time;
            if (malloc_time > malloc_max) malloc_max = malloc_time;
            malloc_sum += malloc_time;
            valid_malloc_count++;
        }
        
        if (free_time > 0) {
            if (free_time < free_min) free_min = free_time;
            if (free_time > free_max) free_max = free_time;
            free_sum += free_time;
            valid_free_count++;
        }
    }
    
    if (valid_malloc_count > 0) {
        malloc_avg = malloc_sum / valid_malloc_count;
        
        printf("MALLOC CYCLES (%lu successful):\n", valid_malloc_count);
        printf("  Min: %d cycles\n", (int)malloc_min);
        printf("  Max: %d cycles\n", (int)malloc_max);
        printf("  Avg: %d cycles\n", (int)malloc_avg);
    }
    
    if (valid_free_count > 0) {
        free_avg = free_sum / valid_free_count;
        
        printf("FREE CYCLES (%lu successful):\n", valid_free_count);
        printf("  Min: %d cycles\n", (int)free_min);
        printf("  Max: %d cycles\n", (int)free_max);
        printf("  Avg: %d cycles\n", (int)free_avg);
    }
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    if (valid_malloc_count > 0) {
        printf("Malloc Avg: %d.%d µs\n", 
               (int)(malloc_avg / cpu_freq_mhz), 
               (int)((malloc_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    }
    if (valid_free_count > 0) {
        printf("Free Avg: %d.%d µs\n", 
               (int)(free_avg / cpu_freq_mhz), 
               (int)((free_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    }
}

/* Main function to start the memory allocation test */
void start_memory_allocation_test(void) {
    /* Create the main test task */
    xTaskCreate(
        memory_performance_task,          /* Function pointer */
        "MemoryTest",                     /* Task name */
        configMINIMAL_STACK_SIZE * 4,     /* Stack size */
        NULL,                             /* Parameters */
        TEST_TASK_PRIORITY,               /* Priority */
        NULL                              /* Task handle */
    );
    
    printf("Memory allocation test task created. Starting scheduler...\n");

    /* START THE SCHEDULER */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}