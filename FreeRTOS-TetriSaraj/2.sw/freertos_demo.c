/*
 * FreeRTOS boot demo for PicoRV32 on Tang Nano 9K.
 *
 * Proves that the FreeRTOS kernel actually runs on the FPGA target:
 *   - the external timer IRQ5 drives the scheduler tick;
 *   - three tasks at two priority levels are time-sliced / preempted;
 *   - vTaskDelay() blocks tasks and yields through the irq_6 software interrupt;
 *   - a mutex serialises UART access so the output never interleaves.
 *
 * All evidence is printed over the already-validated 115200 8N1 UART.
 */
#include <stdint.h>

#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

#include "uart.h"

#define REG_UART_CLKDIV ( *( volatile uint32_t * ) 0x02000004u )

#ifndef UART_CLKDIV
#define UART_CLKDIV 234   /* 27 MHz / 115200 baud */
#endif

static SemaphoreHandle_t xPrintMutex;

static void prvLock( void )
{
    if( xPrintMutex != NULL )
    {
        ( void ) xSemaphoreTake( xPrintMutex, portMAX_DELAY );
    }
}

static void prvUnlock( void )
{
    if( xPrintMutex != NULL )
    {
        ( void ) xSemaphoreGive( xPrintMutex );
    }
}

/* Two worker tasks at the same priority -> show preemptive time slicing. */
static void prvWorkerTask( void * pvParameters )
{
    const char * pcName = ( const char * ) pvParameters;
    uint32_t ulCount = 0;

    for( ;; )
    {
        prvLock();
        print( "[" );
        print( pcName );
        print( "] run=0x" );
        print_hex( ulCount, 4 );
        print( " tick=0x" );
        print_hex( ( unsigned int ) xTaskGetTickCount(), 8 );
        putchar( '\n' );
        prvUnlock();

        ulCount++;

        /* A delays 500 ms, B delays 750 ms. */
        if( pcName[ 0 ] == 'A' )
        {
            vTaskDelay( pdMS_TO_TICKS( 500 ) );
        }
        else
        {
            vTaskDelay( pdMS_TO_TICKS( 750 ) );
        }
    }
}

/* Lower priority heartbeat task -> only runs when A and B are blocked. */
static void prvHeartbeatTask( void * pvParameters )
{
    ( void ) pvParameters;
    uint32_t ulBeat = 0;

    for( ;; )
    {
        prvLock();
        print( "[heartbeat] beat=0x" );
        print_hex( ulBeat, 4 );
        print( " tick=0x" );
        print_hex( ( unsigned int ) xTaskGetTickCount(), 8 );
        putchar( '\n' );
        prvUnlock();

        ulBeat++;
        vTaskDelay( pdMS_TO_TICKS( 1000 ) );
    }
}

void main( void )
{
    REG_UART_CLKDIV = UART_CLKDIV;

    print( "\nFreeRTOS V10.5.1 on PicoRV32 / Tang Nano 9K\n" );
    print( "tick = 100 Hz from timer IRQ5, yield via irq_6\n" );
    print( "creating tasks and starting scheduler...\n" );

    xPrintMutex = xSemaphoreCreateMutex();

    xTaskCreate( prvWorkerTask,   "A", 256, ( void * ) "A", 2, NULL );
    xTaskCreate( prvWorkerTask,   "B", 256, ( void * ) "B", 2, NULL );
    xTaskCreate( prvHeartbeatTask, "hb", 256, NULL,         1, NULL );

    vTaskStartScheduler();

    /* Only reached if the kernel could not start (e.g. out of heap). */
    print( "ERROR: scheduler did not start (heap?)\n" );
    for( ;; )
    {
    }
}
