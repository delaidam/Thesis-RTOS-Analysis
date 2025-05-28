/* main.c - Minimal FreeRTOS application for Picorv32 on Tang Nano 9K */

#include "FreeRTOS.h"
#include "task.h"
#include <stdio.h> // For printf

// External functions from your drivers
extern int outbyte(int c); // From uart_driver.c
extern void init_uart(void); // We'll assume you'll add this to uart_driver.c or create it

// Define the UART base address as a macro for init_uart to use
// NOTE: This must match the UART_BASE_ADDR in uart_driver.c
#define MY_UART_BASE_ADDRESS 0x80000000UL // Replace with your actual UART base address on Picorv32

// Simple initialization for UART
void init_uart(void) {
    // In a real scenario, you'd configure baud rate, parity, etc. here.
    // For now, we just rely on the memory-mapped access in outbyte.
    // If your Picorv32's UART needs initialization, this is where it goes.
    // For picotiny example, the UART is usually ready for basic byte operations.
}


#define GPIO_BASE_ADDR 0x82000000UL // Your actual GPIO base address
#define LED_PIN        (1 << 0)     // Assuming LED is on gpio[0]

/* Task 1: Blinks an LED */
void vTaskBlink(void *pvParameters) {
    (void) pvParameters; // Cast to void to suppress unused parameter warning

    volatile uint32_t *gpio_reg = (volatile uint32_t *) GPIO_BASE_ADDR;

    for (;;) {
        printf("Task 1: LED Blink\r\n");
        if (gpio_reg) {
            *gpio_reg ^= LED_PIN; // Toggle LED
        }
        vTaskDelay(pdMS_TO_TICKS(1000)); // Delay for 1000ms (1 second)
    }
}

/* Task 2: Prints a message */
void vTaskPrint(void *pvParameters) {
    (void) pvParameters; // Cast to void to suppress unused parameter warning

    for (;;) {
        printf("Task 2: Hello from FreeRTOS!\r\n");
        vTaskDelay(pdMS_TO_TICKS(500)); // Delay for 500ms
    }
}

/* Main function - entry point for the application */
int main(void) {
    // Initialize UART
    init_uart();
    printf("Starting FreeRTOS application...\r\n");

    // Create tasks
    xTaskCreate(vTaskBlink,      // Task function
                "Blinky",        // Task name
                configMINIMAL_STACK_SIZE, // Stack size
                NULL,            // Parameters
                tskIDLE_PRIORITY + 1, // Priority (higher than idle)
                NULL);           // Task handle

    xTaskCreate(vTaskPrint,
                "Printer",
                configMINIMAL_STACK_SIZE,
                NULL,
                tskIDLE_PRIORITY + 2, // Higher priority
                NULL);

    // Start the FreeRTOS scheduler
    vTaskStartScheduler();

    // Should never reach here
    for (;;) {
        // If scheduler returns, something went wrong
    }
}

/* FreeRTOS hook functions (optional, but good practice to include stubs) */

void vApplicationMallocFailedHook(void) {
    /* Called if a call to pvPortMalloc() fails because there is insufficient
    free memory in the FreeRTOS heap.  pvPortMalloc() is called internally by
    FreeRTOS API functions that create tasks, queues, software timers, and
    semaphores. */
    taskDISABLE_INTERRUPTS();
    for (;;) {
        // Handle error or loop indefinitely
        printf("Malloc failed!\r\n");
    }
}

void vApplicationStackOverflowHook(TaskHandle_t pxTask, char *pcTaskName) {
    /* Run time stack overflow checking is performed if
    configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook
    function is only called if a stack overflow is detected. */
    (void) pxTask;
    (void) pcTaskName;
    taskDISABLE_INTERRUPTS();
    for (;;) {
        // Handle error or loop indefinitely
        printf("Stack overflow in task: %s\r\n", pcTaskName);
    }
}

void vApplicationIdleHook(void) {
    /* vApplicationIdleHook() will only be called if configUSE_IDLE_HOOK is set
    to 1 in FreeRTOSConfig.h.  It will be called on each iteration of the idle
    task.  It is essential that this function does not enter a block state. */
    // For low power modes, etc.
}

void vApplicationTickHook(void) {
    /* vApplicationTickHook() will only be called if configUSE_TICK_HOOK is set
    to 1 in FreeRTOSConfig.h.  It will be called on each tick interrupt. */
    // For applications needing tick-level processing
}

/* Optional: If you need to trace execution for analysis */
// void vPortGenerateSimulatedInterrupt( uint32_t ulInterruptID ) { /* ... */ }
// void vPortYield( void ) { /* ... */ }