/*
 * FreeRTOS Demo za PicoRV32 na Tang Nano 9K
 * Pokreće se iz BRAM memorije
 */

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

// Static allocation buffers
static StaticTask_t xIdleTaskTCB;
static StackType_t uxIdleTaskStack[configMINIMAL_STACK_SIZE];

#if (configUSE_TIMERS == 1)
static StaticTask_t xTimerTaskTCB;
static StackType_t uxTimerTaskStack[configTIMER_TASK_STACK_DEPTH];
#endif

// Required functions for static allocation
void vApplicationGetIdleTaskMemory(StaticTask_t **ppxIdleTaskTCBBuffer,
                                   StackType_t **ppxIdleTaskStackBuffer,
                                   uint32_t *pulIdleTaskStackSize) {
    *ppxIdleTaskTCBBuffer = &xIdleTaskTCB;
    *ppxIdleTaskStackBuffer = uxIdleTaskStack;
    *pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

#if (configUSE_TIMERS == 1)
void vApplicationGetTimerTaskMemory(StaticTask_t **ppxTimerTaskTCBBuffer,
                                    StackType_t **ppxTimerTaskStackBuffer,
                                    uint32_t *pulTimerTaskStackSize) {
    *ppxTimerTaskTCBBuffer = &xTimerTaskTCB;
    *ppxTimerTaskStackBuffer = uxTimerTaskStack;
    *pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
}
#endif

// Optional: Implement assert function if you want to use it
void vAssertCalled(unsigned long ulLine, const char * const pcFileName) {
    // Handle assertion failure - you can add custom logic here
    (void)ulLine;
    (void)pcFileName;
    taskDISABLE_INTERRUPTS();
    for(;;);
}

// Hardware definicije za Tang Nano 9K
#define UART_BASE     0x10000000
#define GPIO_BASE     0x20000000
#define TIMER_BASE    0x30000000

// UART registri
#define UART_TX       (*(volatile uint32_t*)(UART_BASE + 0x00))
#define UART_RX       (*(volatile uint32_t*)(UART_BASE + 0x04))
#define UART_STATUS   (*(volatile uint32_t*)(UART_BASE + 0x08))

// GPIO registri  
#define GPIO_OUT      (*(volatile uint32_t*)(GPIO_BASE + 0x00))
#define GPIO_IN       (*(volatile uint32_t*)(GPIO_BASE + 0x04))
#define GPIO_DIR      (*(volatile uint32_t*)(GPIO_BASE + 0x08))

// Performance monitoring
//static uint32_t context_switch_count = 0;
static uint32_t task_switch_times[100];
static uint8_t time_index = 0;

// UART funkcije
int putchar(int c) {
    while (!(UART_STATUS & 0x01)); // Wait for TX ready
    UART_TX = c;
    return c;
}

void uart_puts(const char* str) {
    while (*str) {
        putchar(*str);
        str++;
    }
}

void uart_printf_simple(const char* str, int num) {
    uart_puts(str);
    
    // Jednostavan broj print
    if (num >= 1000) putchar('0' + (num/1000)%10);
    if (num >= 100)  putchar('0' + (num/100)%10);  
    if (num >= 10)   putchar('0' + (num/10)%10);
    putchar('0' + num%10);
}

// PicoRV32 cycle counter
uint32_t get_cycle_count(void) {
    uint32_t cycles;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
    return cycles;
}

/*
 * TASK 1: LED Blink Task
 * Demonstrira timer functionality i GPIO kontrolu
 */
void vLedBlinkTask(void *pvParameters) {
    uint32_t blink_counter = 0;
    uint32_t start_cycles, end_cycles;
    
    uart_puts("\n[LED_TASK] Started - PicoRV32 RTOS LED Demo\n");
    
    // Configure GPIO as output
    GPIO_DIR = 0x01; // Pin 0 as output
    
    for (;;) {
        start_cycles = get_cycle_count();
        
        // LED ON
        GPIO_OUT |= 0x01;
        uart_printf_simple("[LED_TASK] LED ON - Blink #", blink_counter + 1);
        uart_puts(" at cycle ");
        uart_printf_simple("", start_cycles);
        uart_puts("\n");
        
        vTaskDelay(pdMS_TO_TICKS(500)); // 500ms delay
        
        // LED OFF  
        GPIO_OUT &= ~0x01;
        end_cycles = get_cycle_count();
        uart_printf_simple("[LED_TASK] LED OFF - Duration: ", end_cycles - start_cycles);
        uart_puts(" cycles\n");
        
        vTaskDelay(pdMS_TO_TICKS(500)); // 500ms delay
        
        blink_counter++;
        
        // Performance monitoring
        if (time_index < 100) {
            task_switch_times[time_index++] = end_cycles - start_cycles;
        }
        
        // Stop after 20 blinks for demo
        if (blink_counter >= 20) {
            uart_puts("[LED_TASK] Completed 20 blinks - task finishing\n");
            break;
        }
    }
    
    vTaskDelete(NULL);
}

/*
 * TASK 2: UART Echo Task  
 * Demonstrira UART komunikaciju i message handling
 */
void vUartEchoTask(void *pvParameters) {
    char received_char;
    uint32_t message_count = 0;
    
    uart_puts("[UART_TASK] Started - UART Echo Demo\n");
    uart_puts("[UART_TASK] Send characters via UART - they will be echoed back\n");
    
    for (;;) {
        // Check if character received (non-blocking)
        if (UART_STATUS & 0x02) { // RX data available
            received_char = UART_RX & 0xFF;
            
            uart_puts("[UART_TASK] Received: '");
            putchar(received_char);
            uart_printf_simple("' (ASCII ", received_char);
            uart_puts(") - Message #");
            uart_printf_simple("", message_count + 1);
            uart_puts("\n");
            
            // Echo back with modification
            uart_puts("[UART_TASK] Echo: '");
            putchar(received_char);
            uart_puts("' -> Processed\n");
            
            message_count++;
            
            // Stop after 10 messages for demo
            if (message_count >= 10) {
                uart_puts("[UART_TASK] Processed 10 messages - task finishing\n");
                break;
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(10)); // 10ms polling interval
    }
    
    vTaskDelete(NULL);
}

/*
 * TASK 3: Performance Monitor Task
 * Meri RTOS performance i prikazuje statistike
 */
void vPerformanceTask(void *pvParameters) {
    uint32_t start_time, current_time;
    uint32_t last_report_time = 0;
    uint32_t report_counter = 0;
    
    uart_puts("[PERF_TASK] Started - RTOS Performance Monitor\n");
    
    start_time = xTaskGetTickCount();
    
    for (;;) {
        current_time = xTaskGetTickCount();
        
        // Report every 2 seconds
        if ((current_time - last_report_time) >= pdMS_TO_TICKS(2000)) {
            uart_puts("\n=== RTOS PERFORMANCE REPORT #");
            uart_printf_simple("", report_counter + 1);
            uart_puts(" ===\n");
            
            uart_printf_simple("[PERF_TASK] System uptime: ", current_time - start_time);
            uart_puts(" ticks\n");
            
            uart_printf_simple("[PERF_TASK] Active tasks: ", uxTaskGetNumberOfTasks());
            uart_puts("\n");
            
            uart_printf_simple("[PERF_TASK] Free heap: ", xPortGetFreeHeapSize());
            uart_puts(" bytes\n");
            
            uart_printf_simple("[PERF_TASK] CPU frequency: ", configCPU_CLOCK_HZ/1000000);
            uart_puts(" MHz\n");
            
            // Context switch performance
            if (time_index > 0) {
                uint32_t avg_cycles = 0;
                for (int i = 0; i < time_index && i < 10; i++) {
                    avg_cycles += task_switch_times[i];
                }
                avg_cycles /= (time_index < 10 ? time_index : 10);
                
                uart_printf_simple("[PERF_TASK] Avg task duration: ", avg_cycles);
                uart_puts(" cycles\n");
                
                // Convert to microseconds (approx)
                uint32_t avg_us = avg_cycles / (configCPU_CLOCK_HZ / 1000000);
                uart_printf_simple("[PERF_TASK] Task duration: ", avg_us);
                uart_puts(" us\n");
            }
            
            uart_puts("=====================================\n\n");
            
            last_report_time = current_time;
            report_counter++;
            
            // Stop after 5 reports
            if (report_counter >= 5) {
                uart_puts("[PERF_TASK] Completed 5 reports - task finishing\n");
                break;
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(100)); // 100ms check interval
    }
    
    vTaskDelete(NULL);
}

/*
 * TASK 4: System Status Task
 * Prikazuje opšte informacije o sistemu
 */
void vSystemStatusTask(void *pvParameters) {
    uint32_t status_counter = 0;
    
    uart_puts("[STATUS_TASK] Started - System Status Monitor\n");
    
    for (;;) {
        uart_puts("\n[STATUS_TASK] === SYSTEM STATUS CHECK #");
        uart_printf_simple("", status_counter + 1);
        uart_puts(" ===\n");
        
        uart_puts("[STATUS_TASK] Tang Nano 9K + PicoRV32 RISC-V\n");
        uart_puts("[STATUS_TASK] FreeRTOS running from BRAM\n");
        uart_printf_simple("[STATUS_TASK] Tick rate: ", configTICK_RATE_HZ);
        uart_puts(" Hz\n");
        
        // GPIO status
        uint32_t gpio_state = GPIO_IN;
        uart_printf_simple("[STATUS_TASK] GPIO input state: 0x", gpio_state);
        uart_puts("\n");
        
        uart_printf_simple("[STATUS_TASK] Current cycle count: ", get_cycle_count());
        uart_puts("\n");
        
        uart_puts("[STATUS_TASK] All systems operational\n");
        uart_puts("=======================================\n\n");
        
        status_counter++;
        
        // Stop after 3 status checks
        if (status_counter >= 3) {
            uart_puts("[STATUS_TASK] Completed 3 status checks - task finishing\n");
            break;
        }
        
        vTaskDelay(pdMS_TO_TICKS(3000)); // 3 second interval
    }
    
    vTaskDelete(NULL);
}

// FreeRTOS hook functions
void vApplicationIdleHook(void) {
    // Called when no tasks are running
    __asm__ volatile ("wfi"); // Wait for interrupt (power saving)
}

void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName) {
    uart_puts("\n[ERROR] Stack overflow in task: ");
    uart_puts(pcTaskName);
    uart_puts("\n");
    for (;;); // Stop system
}

void vApplicationMallocFailedHook(void) {
    uart_puts("\n[ERROR] Memory allocation failed!\n");
    for (;;); // Stop system
}

/*
 * Main function - entry point
 */
int main(void) {
    // System initialization
    uart_puts("\n\n");
    uart_puts("****************************************\n");
    uart_puts("*    Tang Nano 9K + PicoRV32 Demo     *\n");
    uart_puts("*         FreeRTOS from BRAM           *\n");
    uart_puts("*     RISC-V Real-Time System          *\n");
    uart_puts("****************************************\n\n");
    
    uart_puts("[MAIN] System initializing...\n");
    uart_printf_simple("[MAIN] CPU Clock: ", configCPU_CLOCK_HZ/1000000);
    uart_puts(" MHz\n");
    uart_printf_simple("[MAIN] Tick Rate: ", configTICK_RATE_HZ);
    uart_puts(" Hz\n");
    uart_printf_simple("[MAIN] Available heap: ", configTOTAL_HEAP_SIZE);
    uart_puts(" bytes\n\n");
    
    // Create tasks
    uart_puts("[MAIN] Creating tasks...\n");
    
    BaseType_t xReturned;
    
    xReturned = xTaskCreate(vLedBlinkTask, "LED", 256, NULL, 3, NULL);
    if (xReturned == pdPASS) {
        uart_puts("[MAIN] ✓ LED Blink Task created (Priority 3)\n");
    }
    
    xReturned = xTaskCreate(vUartEchoTask, "UART", 256, NULL, 2, NULL);
    if (xReturned == pdPASS) {
        uart_puts("[MAIN] ✓ UART Echo Task created (Priority 2)\n");
    }
    
    xReturned = xTaskCreate(vPerformanceTask, "PERF", 512, NULL, 1, NULL);
    if (xReturned == pdPASS) {
        uart_puts("[MAIN] ✓ Performance Task created (Priority 1)\n");
    }
    
    xReturned = xTaskCreate(vSystemStatusTask, "STATUS", 256, NULL, 1, NULL);
    if (xReturned == pdPASS) {
        uart_puts("[MAIN] ✓ System Status Task created (Priority 1)\n");
    }
    
    uart_puts("[MAIN] All tasks created successfully!\n");
    uart_puts("[MAIN] Starting FreeRTOS scheduler...\n\n");
    
    // Start the scheduler - this function never returns
    vTaskStartScheduler();
    
    // Should never reach here
    uart_puts("[ERROR] Scheduler failed to start!\n");
    return 0;
}