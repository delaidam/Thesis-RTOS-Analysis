#ifndef TEST_CONFIG_H
#define TEST_CONFIG_H

// Test selection macros
#define TEST_CONTEXT_SWITCH     1
#define TEST_MEMORY_ALLOCATION  2  
#define TEST_SYNCHRONIZATION    3
#define TEST_IPC                4
#define TEST_INTERRUPT_LATENCY  5
#define TEST_COMPREHENSIVE      6

// Konfiguriši koji test da se pokrene (može se override iz Makefile-a)
#ifndef SELECTED_TEST
#define SELECTED_TEST TEST_SYNCHRONIZATION
#endif

// Test parametri (mogu se override iz Makefile-a)
#ifndef NUM_ITERATIONS
#define NUM_ITERATIONS 300
#endif

#ifndef CPU_FREQ_MHZ
#define CPU_FREQ_MHZ 25
#endif

#ifndef TEST_TASK_PRIORITY
#define TEST_TASK_PRIORITY (tskIDLE_PRIORITY + 1)
#endif

// Memory test parametri
#ifndef MIN_ALLOC_SIZE
#define MIN_ALLOC_SIZE 32
#endif

#ifndef MAX_ALLOC_SIZE
#define MAX_ALLOC_SIZE 1024
#endif

#ifndef ALLOC_STEP_SIZE
#define ALLOC_STEP_SIZE 64
#endif

// Context switch test parametri
#ifndef NUM_CONTEXT_SWITCHES
#define NUM_CONTEXT_SWITCHES 500
#endif

#ifndef CONTEXT_SWITCH_DELAY_MS
#define CONTEXT_SWITCH_DELAY_MS 1
#endif

#endif // TEST_CONFIG_H