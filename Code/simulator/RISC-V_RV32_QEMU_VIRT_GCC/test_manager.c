#include "test_config.h"
#include "FreeRTOS.h"
#include "task.h"
#include <stdio.h>

// Function pointers za sve testove
extern void start_context_switch_test(void);
extern void start_memory_allocation_test(void);
extern void start_synchronization_test(void);
extern void start_ipc_test(void);
extern void start_interrupt_latency_test(void);
extern void start_comprehensive_test_suite(void);

typedef struct {
    int test_id;
    const char* test_name;
    void (*test_function)(void);
} test_entry_t;

static const test_entry_t test_registry[] = {
    {TEST_CONTEXT_SWITCH, "Context Switch Test", start_context_switch_test},
    {TEST_MEMORY_ALLOCATION, "Memory Allocation Test", start_memory_allocation_test},
    {TEST_SYNCHRONIZATION, "Synchronization Test", start_synchronization_test},
    {TEST_IPC, "IPC Performance Test", start_ipc_test},
    {TEST_INTERRUPT_LATENCY, "Interrupt Latency Test", start_interrupt_latency_test},
    {TEST_COMPREHENSIVE, "Comprehensive Test Suite", start_comprehensive_test_suite}
};

void run_selected_test(void) {
    printf("\n");
    printf("==========================================\n");
    printf("=== FreeRTOS Performance Test Suite ===\n");
    printf("==========================================\n");
    printf("Selected test: %d\n", SELECTED_TEST);
    printf("CPU frequency: %d MHz\n", CPU_FREQ_MHZ);
    printf("Number of iterations: %d\n", NUM_ITERATIONS);
    printf("Build timestamp: %s %s\n", __DATE__, __TIME__);
    printf("FreeRTOS version: %s\n", tskKERNEL_VERSION_NUMBER);
    
    // Print system info
    printf("Free heap at start: %d bytes\n", (int)xPortGetFreeHeapSize());
    printf("==========================================\n");
    
    for(int i = 0; i < sizeof(test_registry)/sizeof(test_entry_t); i++) {
        if(test_registry[i].test_id == SELECTED_TEST) {
            printf("Running: %s\n", test_registry[i].test_name);
            printf("==========================================\n");
            test_registry[i].test_function();
            return;
        }
    }
    
    printf("ERROR: Unknown test ID %d\n", SELECTED_TEST);
    printf("Available tests:\n");
    for(int i = 0; i < sizeof(test_registry)/sizeof(test_entry_t); i++) {
        printf("  %d: %s\n", test_registry[i].test_id, test_registry[i].test_name);
    }
}