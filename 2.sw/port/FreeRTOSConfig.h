/*
 * FreeRTOS configuration for PicoRV32 on Tang Nano 9K (TetriSaraj).
 *
 * Clock and tick match the validated hardware:
 *   - CPU / peripheral clock : 27 MHz (direct board clock)
 *   - tick                   : external timer IRQ5 at configTICK_RATE_HZ
 */
#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/*-----------------------------------------------------------
 * Hardware / scheduling.
 *---------------------------------------------------------*/
#define configCPU_CLOCK_HZ                      ( 27000000UL )
#define configTICK_RATE_HZ                      ( ( TickType_t ) 100 )

#define configUSE_PREEMPTION                    1
#define configUSE_TIME_SLICING                  1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 0
#define configMAX_PRIORITIES                    ( 5 )
#define configMINIMAL_STACK_SIZE                ( ( unsigned short ) 128 )
#define configMAX_TASK_NAME_LEN                 ( 12 )
#define configUSE_16_BIT_TICKS                  0
#define configIDLE_SHOULD_YIELD                 1

/*-----------------------------------------------------------
 * Memory.
 *---------------------------------------------------------*/
#define configSUPPORT_DYNAMIC_ALLOCATION        1
#define configSUPPORT_STATIC_ALLOCATION         0
#define configTOTAL_HEAP_SIZE                   ( ( size_t ) ( 8 * 1024 ) )
#define configAPPLICATION_ALLOCATED_HEAP        0

/*-----------------------------------------------------------
 * Hooks and checks (kept light for the small RAM budget).
 *---------------------------------------------------------*/
#define configUSE_IDLE_HOOK                     0
#define configUSE_TICK_HOOK                     0
#define configUSE_MALLOC_FAILED_HOOK            0
#define configCHECK_FOR_STACK_OVERFLOW          0
#define configUSE_TRACE_FACILITY                0
#define configGENERATE_RUN_TIME_STATS           0

/*-----------------------------------------------------------
 * Synchronisation primitives.
 *---------------------------------------------------------*/
#define configUSE_MUTEXES                       1
#define configUSE_RECURSIVE_MUTEXES             0
#define configUSE_COUNTING_SEMAPHORES           1
#define configQUEUE_REGISTRY_SIZE               0
#define configUSE_QUEUE_SETS                    0

/*-----------------------------------------------------------
 * Software timers (disabled to save code/RAM on this target).
 *---------------------------------------------------------*/
#define configUSE_TIMERS                        0

/*-----------------------------------------------------------
 * Co-routines (unused).
 *---------------------------------------------------------*/
#define configUSE_CO_ROUTINES                   0
#define configMAX_CO_ROUTINE_PRIORITIES         1

/*-----------------------------------------------------------
 * API inclusions.
 *---------------------------------------------------------*/
#define INCLUDE_vTaskPrioritySet                1
#define INCLUDE_uxTaskPriorityGet               1
#define INCLUDE_vTaskDelete                     1
#define INCLUDE_vTaskSuspend                    1
#define INCLUDE_vTaskDelayUntil                 1
#define INCLUDE_vTaskDelay                      1
#define INCLUDE_xTaskGetSchedulerState          1
#define INCLUDE_xTaskGetCurrentTaskHandle       1
#define INCLUDE_uxTaskGetStackHighWaterMark     0
#define INCLUDE_eTaskGetState                   0

/*-----------------------------------------------------------
 * Assert: trap with interrupts disabled so the failure is observable
 * (LED0 keeps blinking from the FPGA, but the CPU stops progressing).
 *---------------------------------------------------------*/
#define configASSERT( x )                                       \
    if( ( x ) == 0 )                                            \
    {                                                           \
        extern void vPortDisableInterrupts( void );             \
        vPortDisableInterrupts();                               \
        for( ;; ) {}                                            \
    }

#endif /* FREERTOS_CONFIG_H */
