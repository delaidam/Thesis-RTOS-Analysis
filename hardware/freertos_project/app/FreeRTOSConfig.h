/*
 * FreeRTOS Kernel configuration for RISC-V on Tang Nano 9K (Picorv32)
 * Based on FreeRTOS version 202212.01 and rv32 ISS documentation.
 */

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/*-----------------------------------------------------------
 * Application specific definitions.
 *
 * These definitions should be adjusted for your particular hardware and
 * application requirements.
 *----------------------------------------------------------*/

/* Configuration for memory. */
#define configISR_STACK_SIZE_WORDS          ( 128 ) // Size of the interrupt service routine stack in words (32-bit words = 4 bytes)
#define configMINIMAL_STACK_SIZE            ( ( unsigned short ) 128 ) // Smallest task stack size in words
#define configTOTAL_HEAP_SIZE               ( ( size_t ) ( 6 * 1024 ) ) // Total size of the FreeRTOS heap in bytes (6KB as per source)
#define configSUPPORT_DYNAMIC_ALLOCATION    1 // Enable dynamic memory allocation (pvPortMalloc and vPortFree)

/* Configuration for tasks. */
#define configUSE_PREEMPTION                1 // Enable pre-emptive scheduling (tasks can be interrupted)
#define configMAX_PRIORITIES                ( 5 ) // Maximum number of task priorities (0 is idle task)
#define configTASK_NOTIFICATION_ARRAY_ENTRIES ( 4 ) // Number of notification channels for tasks
#define config_IDLE_SHOULD_YIELD            0 // Not recommended to set to 1 unless specific needs
#define configUSE_IDLE_HOOK                 0 // Disable application-defined idle hook function
#define configUSE_TICK_HOOK                 0 // Disable application-defined tick hook function
#define configMAX_TASK_NAME_LEN             ( 16 ) // Maximum length of a task's descriptive name
#define configUSE_APPLICATION_TASK_TAG      0 // Disable application-specific task tagging
#define configUSE_CO_ROUTINES               0 // Disable co-routines (not typically used with tasks)
#define configMAX_CO_ROUTINE_PRIORITIES     ( 2 ) // Max priorities for co-routines if enabled

/* Configuration for timers. */
// IMPORTANT: These addresses must match the actual hardware implementation of Picorv32's CLINT/Timer
// on your Tang Nano 9K board. The values below are from the ISS source,
// and might need to be adjusted based on your Picorv32 HDL.
#define configMTIME_BASE_ADDRESS            ( 0xAFFFFFE0UL ) // Base address of the RISC-V mtime register
#define configMTIMECMP_BASE_ADDRESS         ( 0xAFFFFFE8UL ) // Base address of the RISC-V mtimecmp register

#define configCPU_CLOCK_HZ                  ( 100000000UL ) // 100 MHz
                                                          // This is the rate at which the timer is advancing.
#define configTICK_RATE_HZ                  ( 100 ) // FreeRTOS tick rate in Hz (100 Hz = 10ms tick period)
                                                    // For ISS, 100 Hz is common. For real hardware, 1000 Hz (1ms) is typical.
                                                    // We can adjust this later if needed for Tetris fluidity.
#define configUSE_TIMERS                    0 // Disable software timers (for now, can be enabled later)
#define configTIMER_TASK_PRIORITY           ( configMAX_PRIORITIES - 1 ) // Priority of the FreeRTOS timer service task
#define configTIMER_TASK_STACK_DEPTH        configMINIMAL_STACK_SIZE // Stack size for the timer service task
#define configTIMER_QUEUE_LENGTH            4 // Depth of the command queue for the timer service task

/* Configuration for semaphores and mutexes. */
#define configUSE_COUNTING_SEMAPHORES       1 // Enable counting semaphores
#define configUSE_MUTEXES                   0 // Disable mutexes (can be enabled later if needed)
#define configUSE_RECURSIVE_MUTEXES         0 // Disable recursive mutexes

/* Configuration for error checking. */
#define configCHECK_FOR_STACK_OVERFLOW      0 // Disable stack overflow checking (for now, can be enabled later for debugging)
#define configUSE_MALLOC_FAILED_HOOK        0 // Disable malloc failed hook (for now)

/* Configuration for API function inclusion. */
// Enable only essential API functions to save code space.
#define INCLUDE_vTaskPrioritySet            0
#define INCLUDE_uxTaskPriorityGet           0
#define INCLUDE_vTaskDelete                 0
#define INCLUDE_vTaskCleanUpResources       0
#define INCLUDE_vTaskSuspend                0
#define INCLUDE_vTaskDelayUntil             1 // Needed for precise delays
#define INCLUDE_vTaskDelay                  1 // Needed for general delays
#define INCLUDE_eTaskGetState               0
#define INCLUDE_xTimerPendFunctionCall      0
#define INCLUDE_xTaskAbortDelay             0
#define INCLUDE_xTaskGetHandle              0
#define INCLUDE_xSemaphoreGetMutexHolder    0

/* Remaining configuration. */
#define configUSE_TRACE_FACILITY            0 // Disable trace facility
#define configUSE_STATS_FORMATTING          0 // Disable stats formatting
#define configUSE_16_BIT_TICKS              0 // Use 32-bit ticks (for RV32)
#define configQUEUE_REGISTERY_SIZE          0 // Queue registry size (for kernel-aware debugger)
#define configUSE_PORT_OPTIMIZED_TASK_SELECTION 1 // Use assembly optimized task selection (RISC-V port has it)
// Macro for assertion failure: disable interrupts and execute ebreak instruction
#define configASSERT( x ) if( ( x ) == 0 ) { taskDISABLE_INTERRUPTS(); __asm volatile( "ebreak" ); }

#endif /* FREERTOS_CONFIG_H */