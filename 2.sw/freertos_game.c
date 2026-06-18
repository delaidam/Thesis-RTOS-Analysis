#include <stdint.h>

#include "FreeRTOS.h"
#include "queue.h"
#include "semphr.h"
#include "task.h"

#include "tetrisaraj_game.h"
#include "tetrisaraj_platform.h"
#include "uart.h"

static QueueHandle_t xInputQueue;
static SemaphoreHandle_t xGameMutex;
static TetriSarajGame xGame;

static void prvInputTask( void * pvParameters )
{
    TetriSarajInput input;

    ( void ) pvParameters;

    for( ;; )
    {
        input.buttons = tetrisaraj_platform_read_buttons();
        tetrisaraj_platform_set_leds( input.buttons );
        ( void ) xQueueOverwrite( xInputQueue, &input );
        vTaskDelay( pdMS_TO_TICKS( 20 ) );
    }
}

static void prvGameTask( void * pvParameters )
{
    TetriSarajInput input = { 0u };

    ( void ) pvParameters;

    for( ;; )
    {
        while( xQueueReceive( xInputQueue, &input, 0 ) == pdTRUE )
        {
        }

        ( void ) xSemaphoreTake( xGameMutex, portMAX_DELAY );
        tetrisaraj_game_step( &xGame, &input );
        ( void ) xSemaphoreGive( xGameMutex );

        vTaskDelay( pdMS_TO_TICKS( 50 ) );
    }
}

static void prvRenderTask( void * pvParameters )
{
    ( void ) pvParameters;

    print( "video chars init...\n" );
    tetrisaraj_video_chars_init();
    tetrisaraj_video_show_project_name();
    print( "video init done\n" );
    vTaskDelay( pdMS_TO_TICKS( 1000 ) );

    for( ;; )
    {
        ( void ) xSemaphoreTake( xGameMutex, portMAX_DELAY );
        if( xGame.dirty )
        {
            xGame.dirty = false;
            tetrisaraj_game_render( &xGame );
        }
        ( void ) xSemaphoreGive( xGameMutex );

        vTaskDelay( pdMS_TO_TICKS( 50 ) );
    }
}

static void prvDebugTask( void * pvParameters )
{
    uint32_t heartbeat = 0u;

    ( void ) pvParameters;

    for( ;; )
    {
        print( "[freertos_game] heartbeat=0x" );
        print_hex( heartbeat, 8 );
        print( " tick=0x" );
        print_hex( ( unsigned int ) xTaskGetTickCount(), 8 );
        putchar( '\n' );
        heartbeat++;
        vTaskDelay( pdMS_TO_TICKS( 5000 ) );
    }
}

void main( void )
{
    tetrisaraj_platform_init();

    print( "\nTetriSaraj FreeRTOS game app\n" );
    print( "tick=100Hz, input queue, game/render/debug tasks\n" );

    xInputQueue = xQueueCreate( 1, sizeof( TetriSarajInput ) );
    xGameMutex = xSemaphoreCreateMutex();

    if( ( xInputQueue == NULL ) || ( xGameMutex == NULL ) )
    {
        print( "ERROR: queue/mutex allocation failed\n" );
        for( ;; )
        {
        }
    }

    tetrisaraj_game_init( &xGame );

    ( void ) xTaskCreate( prvInputTask, "input", 128, NULL, 3, NULL );
    ( void ) xTaskCreate( prvGameTask, "game", 192, NULL, 2, NULL );
    ( void ) xTaskCreate( prvRenderTask, "render", 192, NULL, 1, NULL );
    ( void ) xTaskCreate( prvDebugTask, "debug", 128, NULL, 1, NULL );

    vTaskStartScheduler();

    print( "ERROR: scheduler did not start\n" );
    for( ;; )
    {
    }
}
