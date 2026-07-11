/*
 * FreeRTOS port layer for PicoRV32 (Tang Nano 9K).
 * See portmacro.h for the description of the mechanism.
 */
#include "FreeRTOS.h"
#include "task.h"

/*-----------------------------------------------------------
 * Hardware register map (matches 1.hw/src/top_uart_hello.v).
 *---------------------------------------------------------*/
#define REG_TIMER_COUNT          ( *( volatile uint32_t * ) 0x03000000u )
#define REG_TIMER_HZ             ( *( volatile uint32_t * ) 0x03000004u )
#define REG_TIMER_IRQ_ENABLE     ( *( volatile uint32_t * ) 0x03000008u )
#define REG_TIMER_IRQ_PENDING    ( *( volatile uint32_t * ) 0x0300000Cu )
#define REG_TIMER_IRQ_PERIOD     ( *( volatile uint32_t * ) 0x03000010u )
#define REG_SOFT_IRQ_TRIGGER     ( *( volatile uint32_t * ) 0x0300001Cu )

/* PicoRV32 IRQ bit positions (see picosoc_noflash.v). */
#define portIRQ_TIMER_BIT        ( 1u << 5 )   /* tick  */
#define portIRQ_YIELD_BIT        ( 1u << 6 )   /* yield */

/* maskirq value that ENABLES exactly the tick + yield interrupts
 * (a 0 bit means "enabled / unmasked" in PicoRV32). */
#define portIRQ_ENABLE_MASK      ( ~( portIRQ_TIMER_BIT | portIRQ_YIELD_BIT ) )

/*-----------------------------------------------------------
 * Routines implemented in portASM.S.
 *---------------------------------------------------------*/
extern void vPortStartFirstTask( void );

/*-----------------------------------------------------------
 * Port state.
 *---------------------------------------------------------*/
/* Nesting depth of critical sections.  A context switch can only happen from
 * the interrupt handler, and interrupts are masked inside a critical section,
 * so this single global never needs to be saved per task. */
static UBaseType_t uxCriticalNesting = 0;

/* Set by portYIELD_FROM_ISR(); consulted by the interrupt dispatcher. */
volatile uint32_t ulPortYieldPending = 0;

/*-----------------------------------------------------------
 * Stack frame layout (word indices). Must match portASM.S.
 *---------------------------------------------------------*/
#define portFRAME_WORDS   32   /* 128 bytes, keeps sp 16-byte aligned */
#define portOFFSET_PC      0
#define portOFFSET_RA      1    /* x1  */
#define portOFFSET_A0      7    /* x10 */

/* Called if a task function returns (tasks must not return). */
static void prvTaskExitError( void )
{
    taskDISABLE_INTERRUPTS();
    for( ;; )
    {
        /* Trap. */
    }
}

/*-----------------------------------------------------------
 * Build an initial stack frame that vPortStartFirstTask /
 * the restore path in portASM.S can pop to launch the task.
 *---------------------------------------------------------*/
StackType_t * pxPortInitialiseStack( StackType_t * pxTopOfStack,
                                     TaskFunction_t pxCode,
                                     void * pvParameters )
{
    /* Align the top of stack down to 16 bytes, then carve out one frame. */
    pxTopOfStack = ( StackType_t * ) ( ( ( uintptr_t ) pxTopOfStack ) & ~( ( uintptr_t ) 0xF ) );
    pxTopOfStack -= portFRAME_WORDS;

    for( int i = 0; i < portFRAME_WORDS; i++ )
    {
        pxTopOfStack[ i ] = 0;
    }

    pxTopOfStack[ portOFFSET_PC ] = ( StackType_t ) pxCode;          /* resume PC      */
    pxTopOfStack[ portOFFSET_RA ] = ( StackType_t ) prvTaskExitError; /* x1 / ra        */
    pxTopOfStack[ portOFFSET_A0 ] = ( StackType_t ) pvParameters;     /* x10 / a0       */

    /* The kernel stores this as pxCurrentTCB->pxTopOfStack. */
    return pxTopOfStack;
}

/*-----------------------------------------------------------
 * Scheduler start/stop.
 *---------------------------------------------------------*/
BaseType_t xPortStartScheduler( void )
{
    /* Program the tick period from the CPU clock. */
    REG_TIMER_IRQ_PERIOD = ( uint32_t ) ( configCPU_CLOCK_HZ / configTICK_RATE_HZ );

    /* Clear any stale pending tick. */
    REG_TIMER_IRQ_PENDING = 1u;

    uxCriticalNesting = 0;
    ulPortYieldPending = 0;

    /* Unmask the tick + yield interrupts in the CPU. */
    ( void ) vPortSetIrqMask( portIRQ_ENABLE_MASK );

    /* Start the periodic tick. */
    REG_TIMER_IRQ_ENABLE = 1u;

    /* Launch the first task (does not return). */
    vPortStartFirstTask();

    /* Should never get here. */
    return pdFALSE;
}

void vPortEndScheduler( void )
{
    /* Not supported on this bare-metal target. */
    for( ;; )
    {
    }
}

/*-----------------------------------------------------------
 * Critical sections.
 *---------------------------------------------------------*/
void vPortDisableInterrupts( void )
{
    ( void ) vPortSetIrqMask( portALL_IRQS_MASKED );
}

void vPortEnableInterrupts( void )
{
    ( void ) vPortSetIrqMask( portIRQ_ENABLE_MASK );
}

void vPortEnterCritical( void )
{
    vPortDisableInterrupts();
    uxCriticalNesting++;
}

void vPortExitCritical( void )
{
    configASSERT( uxCriticalNesting > 0 );
    uxCriticalNesting--;
    if( uxCriticalNesting == 0 )
    {
        vPortEnableInterrupts();
    }
}

/*-----------------------------------------------------------
 * Yield: pulse the software-interrupt line (irq_6).
 *---------------------------------------------------------*/
void vPortYield( void )
{
    REG_SOFT_IRQ_TRIGGER = 1u;
    /* Give the core a couple of instruction boundaries to take the latched
     * interrupt before returning to the caller. */
    __asm__ volatile ( "nop\n nop\n nop\n nop\n" );
}

/*-----------------------------------------------------------
 * C side of the interrupt handler, called from portASM.S with the PicoRV32
 * pending-IRQ bitmap (the value the core placed in x4) as the argument.
 *
 * Runs with the current task's context already saved and with further
 * interrupts inhibited by PicoRV32 (irq_active) until retirq.
 *---------------------------------------------------------*/
void vPortHandleInterrupt( uint32_t ulIrqBitmap )
{
    BaseType_t xSwitchRequired = pdFALSE;

    if( ( ulIrqBitmap & portIRQ_TIMER_BIT ) != 0u )
    {
        /* Acknowledge the hardware timer interrupt. */
        REG_TIMER_IRQ_PENDING = 1u;

        if( xTaskIncrementTick() != pdFALSE )
        {
            xSwitchRequired = pdTRUE;
        }
    }

    /* irq_6 (yield) is latched and auto-cleared by the core on entry. */
    if( ( ulIrqBitmap & portIRQ_YIELD_BIT ) != 0u )
    {
        xSwitchRequired = pdTRUE;
    }

    if( ulPortYieldPending != 0u )
    {
        ulPortYieldPending = 0u;
        xSwitchRequired = pdTRUE;
    }

    if( xSwitchRequired != pdFALSE )
    {
        vTaskSwitchContext();
    }
}
