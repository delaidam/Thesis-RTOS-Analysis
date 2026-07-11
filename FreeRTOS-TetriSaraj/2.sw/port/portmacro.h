/*
 * FreeRTOS port for PicoRV32 (Tang Nano 9K, TetriSaraj project)
 *
 * PicoRV32 here is configured with ENABLE_IRQ(1) and ENABLE_IRQ_QREGS(0).
 * In that mode the core stores the IRQ return address in x3 and the pending
 * IRQ bitmap in x4 on interrupt entry, and the custom "retirq" instruction
 * returns to the address held in x3.  The context switch therefore works by
 * loading the next task's saved PC into x3 before executing retirq.
 *
 *   - Tick  : external memory-mapped timer wired to PicoRV32 irq_5.
 *   - Yield : software interrupt register (0x0300001C) wired to irq_6.
 *
 * No standard RISC-V CSRs (mstatus/mtvec/mcause/mepc) are used, because
 * PicoRV32 does not implement them in this configuration.
 */
#ifndef PORTMACRO_H
#define PORTMACRO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------
 * Type definitions.
 *---------------------------------------------------------*/
#define portCHAR        char
#define portFLOAT       float
#define portDOUBLE      double
#define portLONG        long
#define portSHORT       short
#define portSTACK_TYPE  uint32_t
#define portBASE_TYPE   long

typedef portSTACK_TYPE   StackType_t;
typedef long             BaseType_t;
typedef unsigned long    UBaseType_t;

#if ( configUSE_16_BIT_TICKS == 1 )
    typedef uint16_t TickType_t;
    #define portMAX_DELAY ( TickType_t ) 0xffff
#else
    typedef uint32_t TickType_t;
    #define portMAX_DELAY ( TickType_t ) 0xffffffffUL
    /* 32-bit reads on RV32 are atomic, so the tick count can be read without
     * masking interrupts. */
    #define portTICK_TYPE_IS_ATOMIC 1
#endif

/*-----------------------------------------------------------
 * Architecture specifics.
 *---------------------------------------------------------*/
#define portSTACK_GROWTH      ( -1 )
#define portTICK_PERIOD_MS    ( ( TickType_t ) 1000 / configTICK_RATE_HZ )
#define portBYTE_ALIGNMENT    16
#define portNOP()             __asm__ volatile ( "nop" )

/* Number of 32-bit words saved per context (see portASM.S). Kept here so the
 * stack-overflow-aware stack sizing in tasks.c stays consistent. */
#define portCONTEXT_WORDS     32

/*-----------------------------------------------------------
 * Scheduler / yield utilities.
 *---------------------------------------------------------*/
extern void vPortYield( void );
extern volatile uint32_t ulPortYieldPending;

#define portYIELD()                  vPortYield()
#define portEND_SWITCHING_ISR( x )   do { if( ( x ) != pdFALSE ) { ulPortYieldPending = 1; } } while( 0 )
#define portYIELD_FROM_ISR( x )      portEND_SWITCHING_ISR( x )

/*-----------------------------------------------------------
 * Critical section / interrupt management.
 *
 * Interrupts are enabled/disabled through the PicoRV32 "maskirq" instruction,
 * wrapped by vPortSetIrqMask() in portASM.S.
 *---------------------------------------------------------*/
extern void     vPortEnterCritical( void );
extern void     vPortExitCritical( void );
extern void     vPortDisableInterrupts( void );
extern void     vPortEnableInterrupts( void );
extern uint32_t vPortSetIrqMask( uint32_t ulNewMask );   /* sets mask, returns old mask */

#define portDISABLE_INTERRUPTS()                 vPortDisableInterrupts()
#define portENABLE_INTERRUPTS()                  vPortEnableInterrupts()
#define portENTER_CRITICAL()                     vPortEnterCritical()
#define portEXIT_CRITICAL()                      vPortExitCritical()

/* All interrupt bits set to 1 in the maskirq register means "masked". */
#define portALL_IRQS_MASKED                      ( 0xFFFFFFFFUL )
#define portSET_INTERRUPT_MASK_FROM_ISR()        vPortSetIrqMask( portALL_IRQS_MASKED )
#define portCLEAR_INTERRUPT_MASK_FROM_ISR( x )   ( void ) vPortSetIrqMask( x )

/*-----------------------------------------------------------
 * Task function macros.
 *---------------------------------------------------------*/
#define portTASK_FUNCTION_PROTO( vFunction, pvParameters ) void vFunction( void * pvParameters )
#define portTASK_FUNCTION( vFunction, pvParameters )       void vFunction( void * pvParameters )

#ifdef __cplusplus
}
#endif

#endif /* PORTMACRO_H */
