#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "riscv-virt.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

// Definicije tipova na početku
typedef enum {
    MSG_CRITICAL = 0,    // Highest priority - emergency responses
    MSG_HIGH = 1,        // High priority - control commands  
    MSG_NORMAL = 2,      // Normal priority - data updates
    MSG_LOW = 3          // Low priority - housekeeping
} message_priority_t;

typedef struct {
    message_priority_t priority;
    uint32_t sequence_id;
    uint32_t timestamp;
    uint32_t data_payload;
    uint16_t checksum;
} priority_message_t;

typedef struct {
    uint32_t messages_sent;
    uint32_t messages_received;
    uint32_t total_latency;
    uint32_t min_latency;
    uint32_t max_latency;
    uint32_t queue_full_events;
    uint32_t checksum_errors;
} queue_metrics_t;

static volatile uint32_t demo_run_cycles = 0;
#define MAX_CYCLES 500  // Završi demo nakon 500 ciklusa
static volatile bool demo_complete = false;

// Forward declaration
void print_queue_performance_report(void);

// Queue handles
static QueueHandle_t critical_queue;
static QueueHandle_t high_queue;
static QueueHandle_t normal_queue;
static QueueHandle_t low_queue;

static queue_metrics_t queue_metrics[4];
static volatile uint32_t global_sequence = 0;

// Calculate simple checksum for message integrity
uint16_t calculate_checksum(priority_message_t* msg) {
    uint16_t checksum = 0;
    checksum ^= (uint16_t)msg->priority;
    checksum ^= (uint16_t)(msg->sequence_id & 0xFFFF);
    checksum ^= (uint16_t)(msg->sequence_id >> 16);
    checksum ^= (uint16_t)(msg->timestamp & 0xFFFF);
    checksum ^= (uint16_t)(msg->timestamp >> 16);
    checksum ^= (uint16_t)(msg->data_payload & 0xFFFF);
    checksum ^= (uint16_t)(msg->data_payload >> 16);
    return checksum;
}

// Smart Producer Task - Implements Priority-based Message Generation Algorithm
void vSmartProducerTask(void *pvParameters) {
    printf("[SMART-PRODUCER] Task started!\r\n");
    vTaskDelay(pdMS_TO_TICKS(500)); // Kratka pauza na početku

    priority_message_t message;
    uint32_t cycle_count = 0;
    
    printf("[SMART-PRODUCER] Starting priority-based message generation\r\n");
    
    for(;;) {
        if (demo_complete) {
            printf("[SMART-PRODUCER] Demo complete, task exiting...\r\n");
            vTaskDelete(NULL);  // Završi task ako je demo gotov
            return;
        }

        cycle_count++;
        printf("[SMART-PRODUCER] Cycle %u\r\n", cycle_count); // Debug
        
        message_priority_t msg_priority;
        QueueHandle_t target_queue;
        
        if(cycle_count % 50 == 0) {
            msg_priority = MSG_CRITICAL;
            target_queue = critical_queue;
            message.data_payload = 0xDEADBEEF; // Emergency code
        }
        else if(cycle_count % 10 == 0) {
            msg_priority = MSG_HIGH;
            target_queue = high_queue;
            message.data_payload = cycle_count * 10; // Control value
        }
        else if(cycle_count % 3 == 0) {
            msg_priority = MSG_NORMAL;
            target_queue = normal_queue;
            message.data_payload = cycle_count; // Data update
        }
        else {
            msg_priority = MSG_LOW;
            target_queue = low_queue;
            message.data_payload = cycle_count % 256; // Housekeeping
        }
        
        message.priority = msg_priority;
        message.sequence_id = global_sequence++;
        message.timestamp = xTaskGetTickCount();
        message.checksum = calculate_checksum(&message);
        
        TickType_t send_start = xTaskGetTickCount();
        BaseType_t result = xQueueSend(target_queue, &message, pdMS_TO_TICKS(10));
        TickType_t send_end = xTaskGetTickCount();
        
        if(result == pdTRUE) {
            queue_metrics[msg_priority].messages_sent++;
            printf("[SMART-PRODUCER] Sent %s priority msg #%u, Queue time: %u ticks\r\n",
                   (msg_priority == MSG_CRITICAL) ? "CRITICAL" :
                   (msg_priority == MSG_HIGH) ? "HIGH" :
                   (msg_priority == MSG_NORMAL) ? "NORMAL" : "LOW",
                   (unsigned int)message.sequence_id,
                   (unsigned int)(send_end - send_start));
        } else {
            queue_metrics[msg_priority].queue_full_events++;
            printf("[SMART-PRODUCER] Queue FULL for %s priority message!\r\n",
                   (msg_priority == MSG_CRITICAL) ? "CRITICAL" :
                   (msg_priority == MSG_HIGH) ? "HIGH" :
                   (msg_priority == MSG_NORMAL) ? "NORMAL" : "LOW");
        }
        
        vTaskDelay(pdMS_TO_TICKS(msg_priority == MSG_CRITICAL ? 100 : 
                                msg_priority == MSG_HIGH ? 50 :
                                msg_priority == MSG_NORMAL ? 25 : 10));
    }
}

// Priority-aware Consumer Task - Implements Multi-Queue Polling Algorithm
void vPriorityConsumerTask(void *pvParameters) {
    printf("[PRIORITY-CONSUMER] Task started!\r\n");

    priority_message_t received_msg;
    uint32_t processing_cycles = 0;
    
    printf("[PRIORITY-CONSUMER] Starting multi-queue priority polling\r\n");
    
    for(;;) {
        if (demo_complete) {
            printf("[PRIORITY-CONSUMER] Demo complete, task exiting...\r\n");
            vTaskDelete(NULL);  // Završi task ako je demo gotov
            return;
        }

        processing_cycles++;
        demo_run_cycles++;
        BaseType_t received = pdFALSE;
        QueueHandle_t source_queue = NULL;
        message_priority_t msg_priority;
        
        if(xQueueReceive(critical_queue, &received_msg, 0) == pdTRUE) {
            received = pdTRUE;
            source_queue = critical_queue;
            msg_priority = MSG_CRITICAL;
        }
        else if(xQueueReceive(high_queue, &received_msg, 0) == pdTRUE) {
            received = pdTRUE;
            source_queue = high_queue;
            msg_priority = MSG_HIGH;
        }
        else if(xQueueReceive(normal_queue, &received_msg, 0) == pdTRUE) {
            received = pdTRUE;
            source_queue = normal_queue;
            msg_priority = MSG_NORMAL;
        }
        else if(xQueueReceive(low_queue, &received_msg, pdMS_TO_TICKS(5)) == pdTRUE) {
            received = pdTRUE;
            source_queue = low_queue;
            msg_priority = MSG_LOW;
        }
        
        if(received == pdTRUE) {
            TickType_t current_time = xTaskGetTickCount();
            uint32_t latency = current_time - received_msg.timestamp;
            
            uint16_t expected_checksum = calculate_checksum(&received_msg);
            if(received_msg.checksum != expected_checksum) {
                queue_metrics[msg_priority].checksum_errors++;
                printf("[PRIORITY-CONSUMER] CHECKSUM ERROR in %s message #%u!\r\n",
                       (msg_priority == MSG_CRITICAL) ? "CRITICAL" :
                       (msg_priority == MSG_HIGH) ? "HIGH" :
                       (msg_priority == MSG_NORMAL) ? "NORMAL" : "LOW",
                       (unsigned int)received_msg.sequence_id);
                continue;
            }
            
            queue_metrics[msg_priority].messages_received++;
            queue_metrics[msg_priority].total_latency += latency;
            
            if(queue_metrics[msg_priority].messages_received == 1) {
                queue_metrics[msg_priority].min_latency = latency;
                queue_metrics[msg_priority].max_latency = latency;
            } else {
                if(latency < queue_metrics[msg_priority].min_latency) {
                    queue_metrics[msg_priority].min_latency = latency;
                }
                if(latency > queue_metrics[msg_priority].max_latency) {
                    queue_metrics[msg_priority].max_latency = latency;
                }
            }
            
            uint32_t processing_time = (msg_priority == MSG_CRITICAL) ? 1 :
                                     (msg_priority == MSG_HIGH) ? 2 :
                                     (msg_priority == MSG_NORMAL) ? 3 : 5;
            
            printf("[PRIORITY-CONSUMER] Processed %s msg #%u, Latency: %u ticks, Data: 0x%X\r\n",
                   (msg_priority == MSG_CRITICAL) ? "CRITICAL" :
                   (msg_priority == MSG_HIGH) ? "HIGH" :
                   (msg_priority == MSG_NORMAL) ? "NORMAL" : "LOW",
                   (unsigned int)received_msg.sequence_id,
                   (unsigned int)latency,
                   (unsigned int)received_msg.data_payload);
            
            vTaskDelay(pdMS_TO_TICKS(processing_time));

            if(demo_run_cycles >= MAX_CYCLES) {
                demo_complete = true;
                print_queue_performance_report();
                printf("Demo completed after %u cycles, exiting...\n", (unsigned int)demo_run_cycles);
                vTaskDelete(NULL);  // Završi ovaj task
            }
        }
        
        if(processing_cycles % 100 == 0) {
            print_queue_performance_report();
        }
    }
}

void print_queue_performance_report(void) {
    printf("\r\n=== ADVANCED QUEUE PERFORMANCE ANALYSIS ===\r\n");
    
    const char* priority_names[] = {"CRITICAL", "HIGH", "NORMAL", "LOW"};
    
    for(int i = 0; i < 4; i++) {
        printf("%s Priority Queue:\r\n", priority_names[i]);
        printf("  Messages sent: %u\r\n", (unsigned int)queue_metrics[i].messages_sent);
        printf("  Messages received: %u\r\n", (unsigned int)queue_metrics[i].messages_received);
        
        if(queue_metrics[i].messages_received > 0) {
            uint32_t avg_latency = queue_metrics[i].total_latency / queue_metrics[i].messages_received;
            printf("  Avg latency: %u ticks\r\n", (unsigned int)avg_latency);
            printf("  Min latency: %u ticks\r\n", (unsigned int)queue_metrics[i].min_latency);
            printf("  Max latency: %u ticks\r\n", (unsigned int)queue_metrics[i].max_latency);
        }
        
        printf("  Queue full events: %u\r\n", (unsigned int)queue_metrics[i].queue_full_events);
        printf("  Checksum errors: %u\r\n", (unsigned int)queue_metrics[i].checksum_errors);
        printf("\r\n");
    }
    
    uint32_t total_sent = 0, total_received = 0, total_errors = 0;
    for(int i = 0; i < 4; i++) {
        total_sent += queue_metrics[i].messages_sent;
        total_received += queue_metrics[i].messages_received;
        total_errors += queue_metrics[i].checksum_errors + queue_metrics[i].queue_full_events;
    }
    
    printf("=== SYSTEM PERFORMANCE SUMMARY ===\r\n");
    printf("Total messages sent: %u\r\n", (unsigned int)total_sent);
    printf("Total messages received: %u\r\n", (unsigned int)total_received);
    uint32_t loss_rate = 0, error_rate = 0;
    if (total_sent > 0) {
        loss_rate = ((total_sent - total_received) * 10000) / total_sent; // x100 za dvije decimale
        error_rate = (total_errors * 10000) / total_sent;
    }
    printf("Message loss rate: %u.%02u%%\r\n", loss_rate / 100, loss_rate % 100);
    printf("Error rate: %u.%02u%%\r\n", error_rate / 100, error_rate % 100);
    printf("=======================================\r\n\r\n");
}

void start_queue_communication_demo(void) {
    printf("\r\n*** ADVANCED MULTI-PRIORITY QUEUE COMMUNICATION DEMO ***\r\n");
    printf("This demo demonstrates advanced queue algorithms:\r\n");
    printf("1. Priority-based message generation\r\n");
    printf("2. Multi-queue priority polling\r\n");
    printf("3. Message integrity verification\r\n");
    printf("4. Comprehensive performance analytics\r\n\r\n");
    
    critical_queue = xQueueCreate(5, sizeof(priority_message_t));
    high_queue = xQueueCreate(10, sizeof(priority_message_t));
    normal_queue = xQueueCreate(20, sizeof(priority_message_t));
    low_queue = xQueueCreate(50, sizeof(priority_message_t));
    
    if(critical_queue == NULL || high_queue == NULL || 
       normal_queue == NULL || low_queue == NULL) {
        printf("ERROR: Failed to create queues!\r\n");
        return;
    }
    printf("All queues created successfully\r\n");
    
    memset(queue_metrics, 0, sizeof(queue_metrics));
    
    printf("Creating Smart Producer task...\r\n");
    xTaskCreate(vSmartProducerTask, "SmartProd", 4000, NULL, 3, NULL);
    printf("Creating Priority Consumer task...\r\n");
    xTaskCreate(vPriorityConsumerTask, "PriCons", 4000, NULL, 4, NULL);
    
    printf("Advanced queue demo tasks created successfully!\r\n");
    printf("Starting FreeRTOS scheduler...\r\n\r\n");
    vTaskStartScheduler();
    printf("ERROR: Scheduler failed to start!\r\n");
    for(;;);
}