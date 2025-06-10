/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>

/* Test configuration */
#define NUM_SYNC_ITERATIONS     300
#define TEST_TASK_STACK_SIZE   (configMINIMAL_STACK_SIZE * 2)
#define TEST_TASK_PRIORITY     (tskIDLE_PRIORITY + 1)

/* Forward declarations */
static void print_synchronization_statistics(void);

/* Global variables for measurements */
static uint32_t semaphore_give_cycles[NUM_SYNC_ITERATIONS];
static uint32_t semaphore_take_cycles[NUM_SYNC_ITERATIONS];
static uint32_t mutex_give_cycles[NUM_SYNC_ITERATIONS];
static uint32_t mutex_take_cycles[NUM_SYNC_ITERATIONS];
static volatile uint32_t sync_iteration = 0;

static SemaphoreHandle_t test_binary_semaphore;
static SemaphoreHandle_t test_counting_semaphore;
static SemaphoreHandle_t test_mutex;

/* Cycle counter functions */
static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

/* Function to test binary semaphore performance */
static void test_binary_semaphore_performance(void) {
    uint32_t start_cycles, end_cycles;
    
    printf("\n=== TESTING BINARY SEMAPHORE PERFORMANCE ===\n");
    
    for (uint32_t i = 0; i < NUM_SYNC_ITERATIONS; i++) {
        
        /* Test semaphore give */
        start_cycles = get_cycle_count();
        xSemaphoreGive(test_binary_semaphore);
        end_cycles = get_cycle_count();
        semaphore_give_cycles[i] = end_cycles - start_cycles;
        
        /* Test semaphore take */
        start_cycles = get_cycle_count();
        if (xSemaphoreTake(test_binary_semaphore, 0) == pdTRUE) {
            end_cycles = get_cycle_count();
            semaphore_take_cycles[i] = end_cycles - start_cycles;
        } else {
            semaphore_take_cycles[i] = 0;
            printf("ERROR: Semaphore take failed at iteration %lu\n", i);
        }
        
        /* Print progress every 50 iterations */
        if ((i + 1) % 50 == 0) {
            printf("Completed %lu/%d semaphore operations\n", i + 1, NUM_SYNC_ITERATIONS);
        }
    }
}

/* Function to test mutex performance */
static void test_mutex_performance(void) {
    uint32_t start_cycles, end_cycles;
    
    printf("\n=== TESTING MUTEX PERFORMANCE ===\n");
    
    for (uint32_t i = 0; i < NUM_SYNC_ITERATIONS; i++) {
        
        /* Test mutex take */
        start_cycles = get_cycle_count();
        if (xSemaphoreTake(test_mutex, portMAX_DELAY) == pdTRUE) {
            end_cycles = get_cycle_count();
            mutex_take_cycles[i] = end_cycles - start_cycles;
        } else {
            mutex_take_cycles[i] = 0;
            printf("ERROR: Mutex take failed at iteration %lu\n", i);
        }
        
        /* Test mutex give */
        start_cycles = get_cycle_count();
        xSemaphoreGive(test_mutex);
        end_cycles = get_cycle_count();
        mutex_give_cycles[i] = end_cycles - start_cycles;
        
        /* Print progress every 50 iterations */
        if ((i + 1) % 50 == 0) {
            printf("Completed %lu/%d mutex operations\n", i + 1, NUM_SYNC_ITERATIONS);
        }
    }
}

/* Main synchronization test task */
static void synchronization_test_task(void *pvParameters) {
    
    printf("Starting Synchronization Performance Test...\n");
    printf("Number of iterations: %d\n", NUM_SYNC_ITERATIONS);
    
    /* Wait for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    /* Test binary semaphore performance */
    test_binary_semaphore_performance();
    
    vTaskDelay(pdMS_TO_TICKS(500));
    
    /* Test mutex performance */
    test_mutex_performance();
    
    /* Print all statistics */
    print_synchronization_statistics();
    
    printf("Synchronization test completed!\n");
    
    /* Delete self */
    vTaskDelete(NULL);
}

/* Function to calculate and print synchronization statistics */
static void print_synchronization_statistics(void) {
    uint32_t sem_give_min = UINT32_MAX, sem_give_max = 0, sem_give_sum = 0;
    uint32_t sem_take_min = UINT32_MAX, sem_take_max = 0, sem_take_sum = 0;
    uint32_t mutex_give_min = UINT32_MAX, mutex_give_max = 0, mutex_give_sum = 0;
    uint32_t mutex_take_min = UINT32_MAX, mutex_take_max = 0, mutex_take_sum = 0;
    uint32_t sem_give_avg, sem_take_avg, mutex_give_avg, mutex_take_avg;
    
    printf("\n=== SYNCHRONIZATION PERFORMANCE RESULTS ===\n");
    
    for (int i = 0; i < NUM_SYNC_ITERATIONS; i++) {
        uint32_t sg_cycles = semaphore_give_cycles[i];
        uint32_t st_cycles = semaphore_take_cycles[i];
        uint32_t mg_cycles = mutex_give_cycles[i];
        uint32_t mt_cycles = mutex_take_cycles[i];
        
        if (sg_cycles > 0) {
            if (sg_cycles < sem_give_min) sem_give_min = sg_cycles;
            if (sg_cycles > sem_give_max) sem_give_max = sg_cycles;
            sem_give_sum += sg_cycles;
        }
        
        if (st_cycles > 0) {
            if (st_cycles < sem_take_min) sem_take_min = st_cycles;
            if (st_cycles > sem_take_max) sem_take_max = st_cycles;
            sem_take_sum += st_cycles;
        }
        
        if (mg_cycles > 0) {
            if (mg_cycles < mutex_give_min) mutex_give_min = mg_cycles;
            if (mg_cycles > mutex_give_max) mutex_give_max = mg_cycles;
            mutex_give_sum += mg_cycles;
        }
        
        if (mt_cycles > 0) {
            if (mt_cycles < mutex_take_min) mutex_take_min = mt_cycles;
            if (mt_cycles > mutex_take_max) mutex_take_max = mt_cycles;
            mutex_take_sum += mt_cycles;
        }
    }
    
    sem_give_avg = sem_give_sum / NUM_SYNC_ITERATIONS;
    sem_take_avg = sem_take_sum / NUM_SYNC_ITERATIONS;
    mutex_give_avg = mutex_give_sum / NUM_SYNC_ITERATIONS;
    mutex_take_avg = mutex_take_sum / NUM_SYNC_ITERATIONS;
    
    printf("BINARY SEMAPHORE GIVE CYCLES:\n");
    printf("  Min: %d cycles\n", (int)sem_give_min);
    printf("  Max: %d cycles\n", (int)sem_give_max);
    printf("  Avg: %d cycles\n", (int)sem_give_avg);
    
    printf("BINARY SEMAPHORE TAKE CYCLES:\n");
    printf("  Min: %d cycles\n", (int)sem_take_min);
    printf("  Max: %d cycles\n", (int)sem_take_max);
    printf("  Avg: %d cycles\n", (int)sem_take_avg);
    
    printf("MUTEX GIVE CYCLES:\n");
    printf("  Min: %d cycles\n", (int)mutex_give_min);
    printf("  Max: %d cycles\n", (int)mutex_give_max);
    printf("  Avg: %d cycles\n", (int)mutex_give_avg);
    
    printf("MUTEX TAKE CYCLES:\n");
    printf("  Min: %d cycles\n", (int)mutex_take_min);
    printf("  Max: %d cycles\n", (int)mutex_take_max);
    printf("  Avg: %d cycles\n", (int)mutex_take_avg);
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    printf("Semaphore Give Avg: %d.%d µs\n", 
           (int)(sem_give_avg / cpu_freq_mhz), 
           (int)((sem_give_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Semaphore Take Avg: %d.%d µs\n", 
           (int)(sem_take_avg / cpu_freq_mhz), 
           (int)((sem_take_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Mutex Give Avg: %d.%d µs\n", 
           (int)(mutex_give_avg / cpu_freq_mhz), 
           (int)((mutex_give_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Mutex Take Avg: %d.%d µs\n", 
           (int)(mutex_take_avg / cpu_freq_mhz), 
           (int)((mutex_take_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    
    printf("\nFREE HEAP AFTER TEST: %d bytes\n", (int)xPortGetFreeHeapSize());
}

/* Main function to start the synchronization test */
void start_synchronization_test(void) {
    /* Create binary semaphore */
    test_binary_semaphore = xSemaphoreCreateBinary();
    if (test_binary_semaphore == NULL) {
        printf("ERROR: Failed to create binary semaphore\n");
        return;
    }
    
    /* Create counting semaphore */
    test_counting_semaphore = xSemaphoreCreateCounting(10, 0);
    if (test_counting_semaphore == NULL) {
        printf("ERROR: Failed to create counting semaphore\n");
        return;
    }
    
    /* Create mutex */
    test_mutex = xSemaphoreCreateMutex();
    if (test_mutex == NULL) {
        printf("ERROR: Failed to create mutex\n");
        return;
    }
    
    /* Create the main test task */
    xTaskCreate(
        synchronization_test_task,        /* Function pointer */
        "SyncTest",                       /* Task name */
        configMINIMAL_STACK_SIZE * 4,     /* Stack size */
        NULL,                             /* Parameters */
        TEST_TASK_PRIORITY,               /* Priority */
        NULL                              /* Task handle */
    );
    
    printf("Synchronization test task created. Starting scheduler...\n");

    /* START THE SCHEDULER */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}