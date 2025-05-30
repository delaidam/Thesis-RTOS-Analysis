/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>

/* Test configuration */
#define NUM_IPC_ITERATIONS     500
#define QUEUE_LENGTH          10
#define QUEUE_ITEM_SIZE       sizeof(uint32_t)
#define TEST_TASK_STACK_SIZE  (configMINIMAL_STACK_SIZE * 2)
#define SENDER_PRIORITY       (tskIDLE_PRIORITY + 2)
#define RECEIVER_PRIORITY     (tskIDLE_PRIORITY + 1)

/* Forward declarations */
static void print_ipc_statistics(void);

/* Global variables for measurements */
static uint32_t queue_send_cycles[NUM_IPC_ITERATIONS];
static uint32_t queue_receive_cycles[NUM_IPC_ITERATIONS];
static uint32_t end_to_end_cycles[NUM_IPC_ITERATIONS];
static volatile uint32_t ipc_iteration = 0;
static QueueHandle_t test_queue;

/* Cycle counter functions */
static inline uint32_t get_cycle_count(void) {
    uint32_t cycles;
    asm volatile ("csrr %0, mcycle" : "=r" (cycles));
    return cycles;
}

/* Sender task - sends messages and measures send time */
static void ipc_sender_task(void *pvParameters) {
    uint32_t start_cycles, end_cycles;
    uint32_t message_data;
    
    printf("Starting Queue Performance Test...\n");
    printf("Number of iterations: %d\n", NUM_IPC_ITERATIONS);
    printf("Queue length: %d\n", QUEUE_LENGTH);
    
    /* Wait for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    for (ipc_iteration = 0; ipc_iteration < NUM_IPC_ITERATIONS; ipc_iteration++) {
        
        message_data = ipc_iteration; /* Simple test data */
        
        /* Measure queue send time */
        start_cycles = get_cycle_count();
        
        /* Send message to queue */
        if (xQueueSend(test_queue, &message_data, portMAX_DELAY) != pdPASS) {
            printf("ERROR: Queue send failed at iteration %lu\n", ipc_iteration);
            queue_send_cycles[ipc_iteration] = 0;
        } else {
            end_cycles = get_cycle_count();
            queue_send_cycles[ipc_iteration] = end_cycles - start_cycles;
        }
        
        /* Small delay between sends */
        vTaskDelay(pdMS_TO_TICKS(5));
        
        /* Print progress every 50 iterations */
        if ((ipc_iteration + 1) % 50 == 0) {
            printf("Sent %lu/%d messages\n", ipc_iteration + 1, NUM_IPC_ITERATIONS);
        }
    }
    
    /* Wait a bit for receiver to finish */
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    /* Calculate and print statistics */
    print_ipc_statistics();
    
    printf("Queue test completed!\n");
    
    /* Delete self */
    vTaskDelete(NULL);
}

/* Receiver task - receives messages and measures receive time */
static void ipc_receiver_task(void *pvParameters) {
    uint32_t start_cycles, end_cycles;
    uint32_t received_data;
    uint32_t receive_iteration = 0;
    
    for (;;) {
        /* Measure queue receive time */
        start_cycles = get_cycle_count();
        
        /* Receive message from queue */
        if (xQueueReceive(test_queue, &received_data, portMAX_DELAY) == pdPASS) {
            end_cycles = get_cycle_count();
            
            if (receive_iteration < NUM_IPC_ITERATIONS) {
                queue_receive_cycles[receive_iteration] = end_cycles - start_cycles;
                
                /* Calculate end-to-end time (this is approximate) */
                /* Note: This is not perfectly accurate for end-to-end measurement 
                   but gives an indication of the total IPC latency */
                end_to_end_cycles[receive_iteration] = 
                    queue_send_cycles[receive_iteration] + queue_receive_cycles[receive_iteration];
                
                receive_iteration++;
            }
            
            /* Verify data integrity */
            if (received_data != (receive_iteration - 1) && receive_iteration <= NUM_IPC_ITERATIONS) {
                printf("WARNING: Data integrity issue at iteration %lu\n", receive_iteration - 1);
            }
        }
        
        /* Exit condition */
        if (receive_iteration >= NUM_IPC_ITERATIONS) {
            printf("Receiver completed %lu iterations\n", receive_iteration);
            vTaskSuspend(NULL); /* Suspend self, sender will print results */
        }
    }
}

/* Function to calculate and print IPC statistics */
static void print_ipc_statistics(void) {
    uint32_t send_min = UINT32_MAX, send_max = 0, send_sum = 0;
    uint32_t recv_min = UINT32_MAX, recv_max = 0, recv_sum = 0;
    uint32_t e2e_min = UINT32_MAX, e2e_max = 0, e2e_sum = 0;
    uint32_t send_avg, recv_avg, e2e_avg;
    
    printf("\n=== QUEUE PERFORMANCE RESULTS ===\n");
    
    for (int i = 0; i < NUM_IPC_ITERATIONS; i++) {
        uint32_t send_cycles = queue_send_cycles[i];
        uint32_t recv_cycles = queue_receive_cycles[i];
        uint32_t e2e_cycles = end_to_end_cycles[i];
        
        if (send_cycles > 0) {
            if (send_cycles < send_min) send_min = send_cycles;
            if (send_cycles > send_max) send_max = send_cycles;
            send_sum += send_cycles;
        }
        
        if (recv_cycles > 0) {
            if (recv_cycles < recv_min) recv_min = recv_cycles;
            if (recv_cycles > recv_max) recv_max = recv_cycles;
            recv_sum += recv_cycles;
        }
        
        if (e2e_cycles > 0) {
            if (e2e_cycles < e2e_min) e2e_min = e2e_cycles;
            if (e2e_cycles > e2e_max) e2e_max = e2e_cycles;
            e2e_sum += e2e_cycles;
        }
    }
    
    send_avg = send_sum / NUM_IPC_ITERATIONS;
    recv_avg = recv_sum / NUM_IPC_ITERATIONS;
    e2e_avg = e2e_sum / NUM_IPC_ITERATIONS;
    
    printf("QUEUE SEND CYCLES:\n");
    printf("  Min: %d cycles\n", (int)send_min);
    printf("  Max: %d cycles\n", (int)send_max);
    printf("  Avg: %d cycles\n", (int)send_avg);
    
    printf("QUEUE RECEIVE CYCLES:\n");
    printf("  Min: %d cycles\n", (int)recv_min);
    printf("  Max: %d cycles\n", (int)recv_max);
    printf("  Avg: %d cycles\n", (int)recv_avg);
    
    printf("END-TO-END IPC CYCLES:\n");
    printf("  Min: %d cycles\n", (int)e2e_min);
    printf("  Max: %d cycles\n", (int)e2e_max);
    printf("  Avg: %d cycles\n", (int)e2e_avg);
    
    uint32_t cpu_freq_mhz = 25;
    printf("\nTIME ESTIMATES (assuming %d MHz CPU):\n", (int)cpu_freq_mhz);
    printf("Queue Send Avg: %d.%d µs\n", 
           (int)(send_avg / cpu_freq_mhz), 
           (int)((send_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("Queue Receive Avg: %d.%d µs\n", 
           (int)(recv_avg / cpu_freq_mhz), 
           (int)((recv_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    printf("End-to-End IPC Avg: %d.%d µs\n", 
           (int)(e2e_avg / cpu_freq_mhz), 
           (int)((e2e_avg % cpu_freq_mhz) * 10 / cpu_freq_mhz));
    
    printf("\nFREE HEAP AFTER TEST: %d bytes\n", (int)xPortGetFreeHeapSize());
}

/* Main function to start the IPC test */
void start_ipc_test(void) {
    /* Create queue for communication */
    test_queue = xQueueCreate(QUEUE_LENGTH, QUEUE_ITEM_SIZE);
    
    if (test_queue == NULL) {
        printf("ERROR: Failed to create queue\n");
        return;
    }
    
    /* Create receiver task first (lower priority) */
    xTaskCreate(
        ipc_receiver_task,                /* Function pointer */
        "QueueReceiver",                  /* Task name */
        TEST_TASK_STACK_SIZE,             /* Stack size */
        NULL,                             /* Parameters */
        RECEIVER_PRIORITY,                /* Priority */
        NULL                              /* Task handle */
    );
    
    /* Create sender task (higher priority) */
    xTaskCreate(
        ipc_sender_task,                  /* Function pointer */
        "QueueSender",                    /* Task name */
        TEST_TASK_STACK_SIZE,             /* Stack size */
        NULL,                             /* Parameters */
        SENDER_PRIORITY,                  /* Priority */
        NULL                              /* Task handle */
    );
    
    printf("Queue test tasks created. Starting scheduler...\n");

    /* START THE SCHEDULER */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}