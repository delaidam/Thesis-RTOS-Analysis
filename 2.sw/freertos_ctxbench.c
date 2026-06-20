/*
 * FreeRTOS context-switch latency benchmark for PicoRV32 on Tang Nano 9K.
 *
 * Replicates the round-trip context-switch test from the QEMU thesis
 * (Thesis-RTOS-Analysis .../test_context_switch.c) so the FPGA hardware numbers
 * can be compared against the QEMU model:
 *
 *   - one iteration = two context switches (A -> B, then B -> A);
 *   - task A brackets the round trip with the free-running 27 MHz hardware
 *     counter (REG_TIMER_COUNT) and reports min / avg / max in cycles and ns.
 *
 * Unlike the thesis (two equal-priority tasks sharing one binary semaphore,
 * whose yield behaviour is time-slicing dependent), this uses two binary
 * semaphores with the responder task B at a higher priority, so each give
 * deterministically forces the context switch being measured. The measured
 * quantity is the same: round-trip context-switch cycles.
 *
 * Runs on the proven UART-only top (build.tcl / uart_hello.fs); flash like
 * freertos_demo.
 */
#include <stdint.h>

#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

#include "uart.h"

#define REG_UART_CLKDIV ( *( volatile uint32_t * ) 0x02000004u )
#define REG_TIMER_COUNT ( *( volatile uint32_t * ) 0x03000000u )

#ifndef UART_CLKDIV
#define UART_CLKDIV 234   /* 27 MHz / 115200 baud */
#endif

#ifndef CTXBENCH_ITERS
#define CTXBENCH_ITERS 500u
#endif

#define CPU_HZ_MHZ 27u

static SemaphoreHandle_t xSemA; /* A -> B */
static SemaphoreHandle_t xSemB; /* B -> A */

static volatile uint32_t ulRtMin = 0xFFFFFFFFu;
static volatile uint32_t ulRtMax = 0u;
static volatile uint32_t ulRtSum = 0u;
static volatile uint32_t ulRtCount = 0u;

static void prvPrintDec( uint32_t value )
{
    char buf[ 10 ];
    int pos = 0;

    if( value == 0u )
    {
        putchar( '0' );
        return;
    }

    while( ( value != 0u ) && ( pos < ( int ) sizeof( buf ) ) )
    {
        buf[ pos++ ] = ( char ) ( '0' + ( value % 10u ) );
        value /= 10u;
    }

    while( pos > 0 )
    {
        putchar( buf[ --pos ] );
    }
}

/* Prints "name,cycles,ns" (ns at 27 MHz = cycles * 1000 / 27). */
static void prvPrintMetric( const char * name, uint32_t cycles )
{
    print( name );
    putchar( ',' );
    prvPrintDec( cycles );
    putchar( ',' );
    prvPrintDec( ( cycles * 1000u ) / CPU_HZ_MHZ );
    putchar( '\n' );
}

/* Responder task (higher priority): bounce the token back to A. */
static void prvTaskB( void * pvParameters )
{
    ( void ) pvParameters;

    for( ;; )
    {
        ( void ) xSemaphoreTake( xSemA, portMAX_DELAY );
        ( void ) xSemaphoreGive( xSemB );
    }
}

/* Driver task (lower priority): time the A -> B -> A round trip. */
static void prvTaskA( void * pvParameters )
{
    ( void ) pvParameters;

    /* Let the system settle before measuring. */
    vTaskDelay( pdMS_TO_TICKS( 200 ) );

    for( uint32_t i = 0u; i < CTXBENCH_ITERS; i++ )
    {
        const uint32_t t0 = REG_TIMER_COUNT;

        ( void ) xSemaphoreGive( xSemA );              /* switch A -> B */
        ( void ) xSemaphoreTake( xSemB, portMAX_DELAY ); /* B already gave */

        const uint32_t rt = REG_TIMER_COUNT - t0;

        if( rt < ulRtMin )
        {
            ulRtMin = rt;
        }
        if( rt > ulRtMax )
        {
            ulRtMax = rt;
        }
        ulRtSum += rt;
        ulRtCount++;
    }

    print( "\nFreeRTOS round-trip context switch on PicoRV32 / Tang Nano 9K\n" );
    print( "cpu=27MHz, tick=100Hz, two binary semaphores, B>A priority\n" );
    print( "iterations," );
    prvPrintDec( ulRtCount );
    print( "\nmetric,cycles,ns\n" );

    prvPrintMetric( "ctxsw_roundtrip_min", ulRtMin );
    prvPrintMetric( "ctxsw_roundtrip_avg", ulRtSum / ulRtCount );
    prvPrintMetric( "ctxsw_roundtrip_max", ulRtMax );
    prvPrintMetric( "ctxsw_single_min", ulRtMin / 2u );
    prvPrintMetric( "ctxsw_single_avg", ( ulRtSum / ulRtCount ) / 2u );

    print( "done\n" );

    for( ;; )
    {
        vTaskDelay( portMAX_DELAY );
    }
}

void main( void )
{
    REG_UART_CLKDIV = UART_CLKDIV;

    print( "\nFreeRTOS context-switch benchmark starting...\n" );

    xSemA = xSemaphoreCreateBinary();
    xSemB = xSemaphoreCreateBinary();

    if( ( xSemA == NULL ) || ( xSemB == NULL ) )
    {
        print( "ERROR: semaphore allocation failed (heap?)\n" );
        for( ;; )
        {
        }
    }

    ( void ) xTaskCreate( prvTaskB, "B", 256, NULL, 3, NULL );
    ( void ) xTaskCreate( prvTaskA, "A", 256, NULL, 2, NULL );

    vTaskStartScheduler();

    print( "ERROR: scheduler did not start (heap?)\n" );
    for( ;; )
    {
    }
}
