#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>

// Message structure for inter-task communication
typedef struct {
    uint32_t message_id;
    uint32_t data_payload;
    TickType_t timestamp_sent;
    uint8_t sender_task_id;
    uint8_t priority_level;
    char message_text[32];
} queue_message_t;

// Performance tracking structure
typedef struct {
    uint32_t messages_sent;
    uint32_t messages_received;
    uint32_t total_latency;
    uint32_t min_latency;
    uint32_t max_latency;
    uint32_t queue_full_errors;
    uint32_t queue_empty_errors;
    char task_name[16];
} queue_performance_t;

// Global variables
static QueueHandle_t xHighPriorityQueue;
static QueueHandle_t xMediumPriorityQueue;
static QueueHandle_t xResultQueue;
static SemaphoreHandle_t xSyncSemaphore;
static queue_performance_t queue_stats[4];

// Helper function to print integers via UART

// Producer Task - generates different types of messages
void vQueueProducerTask(void *pvParameters) {
    queue_message_t message;
    uint32_t message_counter = 0;
    uint8_t task_id = 0;
    
    strcpy(queue_stats[task_id].task_name, "PRODUCER");
    
    for(;;) {
        // Generate high-priority message
        message.message_id = message_counter++;
        message.data_payload = message_counter * 10;
        message.timestamp_sent = xTaskGetTickCount();
        message.sender_task_id = task_id;
        message.priority_level = 3;
        sprintf(message.message_text, "High-Pri Msg %lu", message.message_id);
        
        TickType_t send_start = xTaskGetTickCount();
        
        if(xQueueSend(xHighPriorityQueue, &message, pdMS_TO_TICKS(100)) == pdTRUE) {
            TickType_t send_end = xTaskGetTickCount();
            queue_stats[task_id].messages_sent++;
            
            printf("[PRODUCER] Sent high-priority message ");
            print_uint32(message.message_id);
            printf(", Queue delay: ");
            print_uint32(send_end - send_start);
            printf(" ticks\r\n");
        } else {
            queue_stats[task_id].queue_full_errors++;
            printf("[PRODUCER] High-priority queue full! Message ");
            print_uint32(message.message_id);
            printf(" dropped\r\n");
        }
        
        // Generate medium-priority message (every second message)
        if(message_counter % 2 == 0) {
            message.message_id = message_counter++;
            message.data_payload = message_counter * 5;
            message.timestamp_sent = xTaskGetTickCount();
            message.priority_level = 2;
            sprintf(message.message_text, "Med-Pri Msg %lu", message.message_id);
            
            if(xQueueSend(xMediumPriorityQueue, &message, pdMS_TO_TICKS(50)) == pdTRUE) {
                queue_stats[task_id].messages_sent++;
                printf("[PRODUCER] Sent medium-priority message ");
                print_uint32(message.message_id);
                printf("\r\n");
            } else {
                queue_stats[task_id].queue_full_errors++;
                printf("[PRODUCER] Medium-priority queue full!\r\n");
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(150));
    }
}

// High Priority Consumer Task
void vQueueHighPriorityConsumer(void *pvParameters) {
    queue_message_t received_message;
    uint8_t task_id = 1;
    
    strcpy(queue_stats[task_id].task_name, "HIGH-CONS");
    queue_stats[task_id].min_latency = UINT32_MAX;
    
    for(;;) {
        if(xQueueReceive(xHighPriorityQueue, &received_message, portMAX_DELAY) == pdTRUE) {
            TickType_t receive_time = xTaskGetTickCount();
            uint32_t latency = receive_time - received_message.timestamp_sent;
            
            // Update statistics
            queue_stats[task_id].messages_received++;
            queue_stats[task_id].total_latency += latency;
            
            if(latency < queue_stats[task_id].min_latency) {
                queue_stats[task_id].min_latency = latency;
            }
            if(latency > queue_stats[task_id].max_latency) {
                queue_stats[task_id].max_latency = latency;
            }
            
            printf("[HIGH-CONSUMER] Processed message ");
            print_uint32(received_message.message_id);
            printf(", Latency: ");
            print_uint32(latency);
            printf(" ticks, Data: ");
            print_uint32(received_message.data_payload);
            printf("\r\n");
            
            // Fast processing simulation for high priority
            for(volatile int i = 0; i < 1000; i++);
            
            // Send result to result queue
            queue_message_t result = {
                .message_id = received_message.message_id,
                .data_payload = received_message.data_payload * 2,
                .timestamp_sent = xTaskGetTickCount(),
                .sender_task_id = task_id,
                .priority_level = 3
            };
            sprintf(result.message_text, "Result for ");
            print_uint32(received_message.message_id);
            
            xQueueSend(xResultQueue, &result, pdMS_TO_TICKS(10));
        }
    }
}

// Medium Priority Consumer Task
void vQueueMediumPriorityConsumer(void *pvParameters) {
    queue_message_t received_message;
    uint8_t task_id = 2;
    
    strcpy(queue_stats[task_id].task_name, "MED-CONS");
    queue_stats[task_id].min_latency = UINT32_MAX;
    
    for(;;) {
        if(xQueueReceive(xMediumPriorityQueue, &received_message, portMAX_DELAY) == pdTRUE) {
            TickType_t receive_time = xTaskGetTickCount();
            uint32_t latency = receive_time - received_message.timestamp_sent;
            
            // Update statistics
            queue_stats[task_id].messages_received++;
            queue_stats[task_id].total_latency += latency;
            
            if(latency < queue_stats[task_id].min_latency) {
                queue_stats[task_id].min_latency = latency;
            }
            if(latency > queue_stats[task_id].max_latency) {
                queue_stats[task_id].max_latency = latency;
            }
            
            printf("[MED-CONSUMER] Processed message ");
            print_uint32(received_message.message_id);
            printf(", Latency: ");
            print_uint32(latency);
            printf(" ticks, Data: ");
            print_uint32(received_message.data_payload);
            printf("\r\n");
            
            // Slower processing simulation for medium priority
            for(volatile int i = 0; i < 3000; i++);
            
            // Signal completion
            xSemaphoreGive(xSyncSemaphore);
        }
    }
}

// Result Monitor Task
void vQueueResultMonitor(void *pvParameters) {
    queue_message_t result;
    uint8_t task_id = 3;
    
    strcpy(queue_stats[task_id].task_name, "MONITOR");
    
    for(;;) {
        if(xQueueReceive(xResultQueue, &result, portMAX_DELAY) == pdTRUE) {
            TickType_t process_time = xTaskGetTickCount() - result.timestamp_sent;
            
            printf("[RESULT-MONITOR] Result for message ");
            print_uint32(result.message_id);
            printf(": ");
            print_uint32(result.data_payload);
            printf(" (Processing time: ");
            print_uint32(process_time);
            printf(" ticks)\r\n");
            
            queue_stats[task_id].messages_received++;
            
            // Periodic reporting every 10 messages
            if(queue_stats[task_id].messages_received % 10 == 0 && queue_stats[task_id].messages_received > 0) {
                printf("\r\n=== QUEUE COMMUNICATION PERFORMANCE SUMMARY ===\r\n");
                
                for(int i = 0; i < 3; i++) {
                    printf("Task ");
                    printf(queue_stats[i].task_name);
                    printf(":\r\n");
                    
                    printf("  Messages sent: ");
                    print_uint32(queue_stats[i].messages_sent);
                    printf("\r\n");
                    
                    printf("  Messages received: ");
                    print_uint32(queue_stats[i].messages_received);
                    printf("\r\n");
                    
                    if(queue_stats[i].messages_received > 0) {
                        uint32_t avg_latency = queue_stats[i].total_latency / queue_stats[i].messages_received;
                        printf("  Average latency: ");
                        print_uint32(avg_latency);
                        printf(" ticks\r\n");
                        
                        printf("  Min latency: ");
                        print_uint32(queue_stats[i].min_latency);
                        printf(" ticks\r\n");
                        
                        printf("  Max latency: ");
                        print_uint32(queue_stats[i].max_latency);
                        printf(" ticks\r\n");
                    }
                    
                    printf("  Queue errors: ");
                    print_uint32(queue_stats[i].queue_full_errors);
                    printf("\r\n\r\n");
                }
                
                printf("==============================================\r\n\r\n");
            }
        }
    }
}

void start_queue_communication_demo(void) {
    printf("\r\n*** STARTING QUEUE COMMUNICATION DEMO ***\r\n");
    printf("This demo shows inter-task communication using queues.\r\n");
    printf("Multiple producers and consumers exchange messages.\r\n\r\n");
    
    // Reset statistics
    memset(queue_stats, 0, sizeof(queue_stats));
    
    // Create queues
    xHighPriorityQueue = xQueueCreate(10, sizeof(queue_message_t));
    xMediumPriorityQueue = xQueueCreate(5, sizeof(queue_message_t));
    xResultQueue = xQueueCreate(8, sizeof(queue_message_t));
    xSyncSemaphore = xSemaphoreCreateBinary();
    
    if(xHighPriorityQueue == NULL || xMediumPriorityQueue == NULL || 
       xResultQueue == NULL || xSyncSemaphore == NULL) {
        printf("Failed to create queue communication objects!\r\n");
        return;
    }
    
    // Create tasks
    xTaskCreate(vQueueProducerTask, "Producer", 1000, NULL, 3, NULL);
    xTaskCreate(vQueueHighPriorityConsumer, "HighCons", 1000, NULL, 4, NULL);
    xTaskCreate(vQueueMediumPriorityConsumer, "MedCons", 1000, NULL, 3, NULL);
    xTaskCreate(vQueueResultMonitor, "Monitor", 1000, NULL, 2, NULL);
    
    printf("Queue communication demo tasks created successfully\r\n");
    printf("Starting FreeRTOS scheduler...\r\n\r\n");
    
    // Start the scheduler
    vTaskStartScheduler();
    
    // Should never reach here
    printf("ERROR: Scheduler failed to start!\r\n");
    for(;;);
}