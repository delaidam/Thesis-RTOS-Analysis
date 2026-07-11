/*
 * Headless FreeRTOS TetriSaraj proof for PicoRV32 on Tang Nano 9K.
 *
 * Goal: prove the real TetriSaraj game logic runs as FreeRTOS tasks on the
 * hardware, using only the already-validated UART path and the proven
 * UART-only top (build.tcl / uart_hello.fs). No HDMI/video and no GPIO MMIO
 * are touched, so this firmware fits on the same fabric as freertos_demo.
 *
 * Task layout:
 *   - input  (prio 3): synthesises button presses (no physical buttons on the
 *                      UART-only top) and pushes them through a queue;
 *   - game   (prio 2): consumes input and advances the game state machine;
 *   - render (prio 1): periodically prints the playfield as ASCII over UART;
 *   - debug  (prio 1): periodically prints score/lives/flags/tick status.
 *
 * The game auto-plays via gravity even with no input, so a passive UART capture
 * shows pieces spawning, falling, locking, scoring, losing lives, and the end
 * screen -- all driven by the FreeRTOS scheduler.
 */
#include <stdint.h>

#include "FreeRTOS.h"
#include "queue.h"
#include "semphr.h"
#include "task.h"

#include "tetrisaraj_game.h"
#include "tetrisaraj_platform.h"
#include "uart.h"

#define REG_UART_CLKDIV ( *( volatile uint32_t * ) 0x02000004u )

#ifndef UART_CLKDIV
#define UART_CLKDIV 234   /* 27 MHz / 115200 baud */
#endif

#define RENDER_PERIOD_MS 1500u
#define DEBUG_PERIOD_MS  2000u
#define INPUT_PERIOD_MS  50u
#define GAME_PERIOD_MS   50u

/* cell value (0..9) -> glyph; 9 is the wall, 1..7 are the seven tetrominoes. */
static const char cCellGlyph[ 10 ] =
{
    ' ', 'I', 'O', 'T', 'S', 'Z', 'L', 'J', '*', '#'
};

static QueueHandle_t xInputQueue;
static SemaphoreHandle_t xGameMutex;   /* guards xGame                       */
static SemaphoreHandle_t xPrintMutex;  /* serialises UART so output is clean */
static TetriSarajGame xGame;

static void prvLockPrint( void )
{
    ( void ) xSemaphoreTake( xPrintMutex, portMAX_DELAY );
}

static void prvUnlockPrint( void )
{
    ( void ) xSemaphoreGive( xPrintMutex );
}

/* Deterministic synthetic input so the input->queue->game path is exercised
 * even though the UART-only top has no physical buttons. */
static uint8_t ucSynthInput( uint32_t ulStep )
{
    switch( ulStep % 8u )
    {
        case 1u:  return TETRISARAJ_BUTTON_CENTER; /* rotate            */
        case 3u:  return TETRISARAJ_BUTTON_DOWN;   /* drop faster       */
        case 5u:  return TETRISARAJ_BUTTON_RIGHT;  /* nudge right       */
        case 6u:  return TETRISARAJ_BUTTON_LEFT;   /* nudge left        */
        default:  return 0u;                       /* let gravity play  */
    }
}

static void prvInputTask( void * pvParameters )
{
    TetriSarajInput input;
    uint32_t ulStep = 0u;

    ( void ) pvParameters;

    for( ;; )
    {
        input.buttons = ucSynthInput( ulStep++ );
        ( void ) xQueueOverwrite( xInputQueue, &input );
        vTaskDelay( pdMS_TO_TICKS( INPUT_PERIOD_MS ) );
    }
}

static void prvGameTask( void * pvParameters )
{
    TetriSarajInput input = { 0u };

    ( void ) pvParameters;

    for( ;; )
    {
        /* Take the most recent input; collapse any backlog. */
        while( xQueueReceive( xInputQueue, &input, 0 ) == pdTRUE )
        {
        }

        ( void ) xSemaphoreTake( xGameMutex, portMAX_DELAY );
        tetrisaraj_game_step( &xGame, &input );
        ( void ) xSemaphoreGive( xGameMutex );

        vTaskDelay( pdMS_TO_TICKS( GAME_PERIOD_MS ) );
    }
}

/* Renders the playfield as ASCII. Holds the game mutex during the print so the
 * frame is a consistent snapshot; render priority is below the game task. */
static void prvRenderFieldLocked( uint32_t ulFrame )
{
    print( "\n--- frame 0x" );
    print_hex( ulFrame, 4 );
    print( "  score=0x" );
    print_hex( ( unsigned int ) xGame.score, 4 );
    print( "  lives=0x" );
    print_hex( ( unsigned int ) xGame.lives, 2 );
    if( xGame.the_end )
    {
        print( "  [THE END]" );
    }
    else if( xGame.game_over )
    {
        print( "  [GAME OVER]" );
    }
    putchar( '\n' );

    for( uint8_t y = 0u; y < TETRISARAJ_FIELD_HEIGHT; y++ )
    {
        for( uint8_t x = 0u; x < TETRISARAJ_FIELD_WIDTH; x++ )
        {
            const uint8_t value = tetrisaraj_game_cell_at( &xGame, x, y );
            putchar( cCellGlyph[ ( value < 10u ) ? value : 0u ] );
        }
        putchar( '\n' );
    }
}

static void prvRenderTask( void * pvParameters )
{
    uint32_t ulFrame = 0u;

    ( void ) pvParameters;

    for( ;; )
    {
        ( void ) xSemaphoreTake( xGameMutex, portMAX_DELAY );
        prvLockPrint();
        prvRenderFieldLocked( ulFrame );
        prvUnlockPrint();
        ( void ) xSemaphoreGive( xGameMutex );

        ulFrame++;
        vTaskDelay( pdMS_TO_TICKS( RENDER_PERIOD_MS ) );
    }
}

static void prvDebugTask( void * pvParameters )
{
    uint32_t ulBeat = 0u;

    ( void ) pvParameters;

    for( ;; )
    {
        uint16_t score;
        uint8_t lives;
        uint8_t piece;
        uint8_t over;

        ( void ) xSemaphoreTake( xGameMutex, portMAX_DELAY );
        score = xGame.score;
        lives = xGame.lives;
        piece = xGame.piece_index;
        over = ( uint8_t ) ( ( xGame.the_end ? 2u : 0u ) | ( xGame.game_over ? 1u : 0u ) );
        ( void ) xSemaphoreGive( xGameMutex );

        prvLockPrint();
        print( "[hb] beat=0x" );
        print_hex( ulBeat, 4 );
        print( " tick=0x" );
        print_hex( ( unsigned int ) xTaskGetTickCount(), 8 );
        print( " score=0x" );
        print_hex( ( unsigned int ) score, 4 );
        print( " lives=0x" );
        print_hex( ( unsigned int ) lives, 2 );
        print( " piece=0x" );
        print_hex( ( unsigned int ) piece, 2 );
        print( " state=0x" );
        print_hex( ( unsigned int ) over, 2 );
        putchar( '\n' );
        prvUnlockPrint();

        ulBeat++;
        vTaskDelay( pdMS_TO_TICKS( DEBUG_PERIOD_MS ) );
    }
}

void main( void )
{
    REG_UART_CLKDIV = UART_CLKDIV;

    print( "\nTetriSaraj FreeRTOS headless proof on PicoRV32 / Tang Nano 9K\n" );
    print( "game logic runs as FreeRTOS tasks, rendered as ASCII over UART\n" );
    print( "tick = 100 Hz from timer IRQ5, yield via irq_6\n" );

    xInputQueue = xQueueCreate( 1, sizeof( TetriSarajInput ) );
    xGameMutex = xSemaphoreCreateMutex();
    xPrintMutex = xSemaphoreCreateMutex();

    if( ( xInputQueue == NULL ) || ( xGameMutex == NULL ) || ( xPrintMutex == NULL ) )
    {
        print( "ERROR: queue/mutex allocation failed (heap?)\n" );
        for( ;; )
        {
        }
    }

    tetrisaraj_game_init( &xGame );

    ( void ) xTaskCreate( prvInputTask,  "input",  128, NULL, 3, NULL );
    ( void ) xTaskCreate( prvGameTask,   "game",   192, NULL, 2, NULL );
    ( void ) xTaskCreate( prvRenderTask, "render", 256, NULL, 1, NULL );
    ( void ) xTaskCreate( prvDebugTask,  "debug",  160, NULL, 1, NULL );

    vTaskStartScheduler();

    print( "ERROR: scheduler did not start (heap?)\n" );
    for( ;; )
    {
    }
}
