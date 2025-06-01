/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* Standard includes */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

/* External test function declarations */
extern void start_performance_test(void);
extern void start_context_switch_test(void);
extern void start_ipc_test(void);
extern void start_interrupt_latency_test(void);
extern void start_memory_allocation_test(void);
extern void start_synchronization_test(void);

/* Test selection menu */
typedef enum {
    TEST_TASK_CREATION_DELETION = 1,
    TEST_CONTEXT_SWITCH = 2,
    TEST_IPC_QUEUE = 3,
    TEST_INTERRUPT_LATENCY = 4,
    TEST_MEMORY_ALLOCATION = 5,
    TEST_SYNCHRONIZATION = 6,
    TEST_ALL_SEQUENTIAL = 7,
    TEST_EXIT = 0
} test_selection_t;

/* UART input buffer for menu selection */
#define INPUT_BUFFER_SIZE 10
static char input_buffer[INPUT_BUFFER_SIZE];
static volatile uint8_t input_index = 0;

/* Function to display test menu */
static void display_test_menu(void) {
    printf("\n");
    printf("=================================================\n");
    printf("   FreeRTOS Performance Test Suite - RISC-V     \n");
    printf("=================================================\n");
    printf("Please select a test to run:\n");
    printf("1. Task Creation/Deletion Performance\n");
    printf("2. Context Switch Performance\n");
    printf("3. Inter-Process Communication (Queue)\n");
    printf("4. Interrupt Latency\n");
    printf("5. Memory Allocation Performance\n");
    printf("6. Synchronization (Semaphore/Mutex)\n");
    printf("7. Run All Tests Sequentially\n");
    printf("0. Exit\n");
    printf("=================================================\n");
    printf("Enter your choice (0-7): ");
}

/* Function to get user input */
static int get_user_input(void) {
    char c;
    input_index = 0;
    
    /* Clear input buffer */
    memset(input_buffer, 0, INPUT_BUFFER_SIZE);
    
    /* Read characters until newline or buffer full */
    while (input_index < (INPUT_BUFFER_SIZE - 1)) {
        /* Simple blocking read from UART - this would need to be adapted 
           for your specific UART implementation */
        c = getchar(); /* This assumes getchar() is implemented for your UART */
        
        if (c == '\n' || c == '\r') {
            break;
        } else if (c >= '0' && c <= '9') {
            input_buffer[input_index++] = c;
            printf("%c", c); /* Echo character */
        }
    }
    
    printf("\n");
    
    /* Convert to integer */
    if (input_index > 0) {
        return (input_buffer[0] - '0');
    }
    
    return -1; /* Invalid input */
}

/* Function to run selected test */
static void run_selected_test(test_selection_t selection) {
    printf("\n");
    
    switch (selection) {
        case TEST_TASK_CREATION_DELETION:
            printf("Starting Task Creation/Deletion Test...\n");
            start_performance_test();
            break;
            
        case TEST_CONTEXT_SWITCH:
            printf("Starting Context Switch Test...\n");
            start_context_switch_test();
            break;
            
        case TEST_IPC_QUEUE:
            printf("Starting IPC Queue Test...\n");
            start_ipc_test();
            break;
            
        case TEST_INTERRUPT_LATENCY:
            printf("Starting Interrupt Latency Test...\n");
            start_interrupt_latency_test();
            break;
            
        case TEST_MEMORY_ALLOCATION:
            printf("Starting Memory Allocation Test...\n");
            start_memory_allocation_test();
            break;
            
        case TEST_SYNCHRONIZATION:
            printf("Starting Synchronization Test...\n");
            start_synchronization_test();
            break;
            
        case TEST_ALL_SEQUENTIAL:
            printf("Starting All Tests Sequentially...\n");
            run_all_tests_sequential();
            break;
            
        case TEST_EXIT:
            printf("Exiting test suite. Goodbye!\n");
            break;
            
        default:
            printf("Invalid selection. Please try again.\n");
            break;
    }
}

/* Function to run all tests sequentially */
void run_all_tests_sequential(void) {
    printf("\n=== RUNNING ALL TESTS SEQUENTIALLY ===\n");
    
    printf("\n[1/6] Task Creation/Deletion Test\n");
    start_performance_test();
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    printf("\n[2/6] Context Switch Test\n");
    start_context_switch_test();
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    printf("\n[3/6] IPC Queue Test\n");
    start_ipc_test();
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    printf("\n[4/6] Interrupt Latency Test\n");
    start_interrupt_latency_test();
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    printf("\n[5/6] Memory Allocation Test\n");
    start_memory_allocation_test();
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    printf("\n[6/6] Synchronization Test\n");
    start_synchronization_test();
    
    printf("\n=== ALL TESTS COMPLETED ===\n");
    printf("Returning to main menu...\n");
    vTaskDelay(pdMS_TO_TICKS(3000));
}

/* Main menu task */
static void test_menu_task(void *pvParameters) {
    test_selection_t selection;
    int input_value;
    
    printf("\n");
    printf("FreeRTOS Performance Test Suite for RISC-V\n");
    printf("Version 1.0 - Diplomski rad\n");
    printf("Author: Delaida Muminović\n");
    printf("University of Zenica, Polytechnic Faculty\n");
    printf("\n");
    
    /* Initial system information */
    printf("System Information:\n");
    printf("- FreeRTOS Version: %s\n", tskKERNEL_VERSION_NUMBER);
    printf("- CPU Architecture: RISC-V 32-bit\n");
    printf("- Free Heap Size: %d bytes\n", (int)xPortGetFreeHeapSize());
    printf("- Tick Rate: %d Hz\n", (int)configTICK_RATE_HZ);
    printf("- Max Priorities: %d\n", (int)configMAX_PRIORITIES);
    
    /* Main menu loop */
    while (1) {
        display_test_menu();
        
        input_value = get_user_input();
        
        if (input_value >= 0 && input_value <= 7) {
            selection = (test_selection_t)input_value;
            
            if (selection == TEST_EXIT) {
                run_selected_test(selection);
                break;
            } else {
                run_selected_test(selection);
                
                /* Wait a bit before showing menu again */
                vTaskDelay(pdMS_TO_TICKS(2000));
                printf("\nPress any key to continue...");
                getchar();
            }
        } else {
            printf("Invalid input. Please enter a number between 0-7.\n");
            vTaskDelay(pdMS_TO_TICKS(1000));
        }
    }
    
    printf("Test suite terminated.\n");
    vTaskDelete(NULL);
}

/* Alternative simple test runner (if UART input is not available) */
static void simple_test_runner_task(void *pvParameters) {
    printf("\n");
    printf("FreeRTOS Performance Test Suite for RISC-V\n");
    printf("Simple Auto-Runner Mode\n");
    printf("Author: Delaida Muminović\n");
    printf("\n");
    
    /* Wait for system to stabilize */
    vTaskDelay(pdMS_TO_TICKS(3000));
    
    /* Run a predefined test sequence */
    printf("Running predefined test sequence...\n");
    
    /* You can modify this to run specific tests */
    run_all_tests_sequential();
    
    printf("All tests completed. System will now idle.\n");
    vTaskDelete(NULL);
}

/* Main function to start the comprehensive test suite */
void start_comprehensive_test_suite(void) {
    printf("Initializing FreeRTOS Performance Test Suite...\n");
    
    /* Determine if we should use interactive menu or simple runner */
    /* This depends on whether UART input is properly implemented */
    #ifdef ENABLE_INTERACTIVE_MENU
        /* Create interactive menu task */
        xTaskCreate(
            test_menu_task,                   /* Function pointer */
            "TestMenu",                       /* Task name */
            configMINIMAL_STACK_SIZE * 4,     /* Stack size */
            NULL,                             /* Parameters */
            tskIDLE_PRIORITY + 1,             /* Priority */
            NULL                              /* Task handle */
        );
        printf("Interactive test menu created.\n");
    #else
        /* Create simple test runner */
        xTaskCreate(
            simple_test_runner_task,          /* Function pointer */
            "SimpleRunner",                   /* Task name */
            configMINIMAL_STACK_SIZE * 4,     /* Stack size */
            NULL,                             /* Parameters */
            tskIDLE_PRIORITY + 1,             /* Priority */
            NULL                              /* Task handle */
        );
        printf("Simple test runner created.\n");
    #endif
    
    printf("Starting FreeRTOS scheduler...\n");

    /* START THE SCHEDULER */
    vTaskStartScheduler();

    /* Should never reach here */
    for(;;);
}