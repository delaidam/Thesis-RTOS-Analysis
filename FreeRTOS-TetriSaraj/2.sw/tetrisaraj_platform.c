#include "tetrisaraj_platform.h"

#define REG_UART_CLKDIV ( *( volatile uint32_t * ) 0x02000004u )
#define REG_GPIO        ( *( volatile uint32_t * ) 0x04000000u )
#define REG_VIDEO_CHAR  ( ( volatile uint32_t * ) 0x05100000u )
#define REG_VIDEO_MAP   ( ( volatile uint32_t * ) 0x05200000u )

#ifndef UART_CLKDIV
#define UART_CLKDIV 234u
#endif

/* Character (tile) geometry. The on-screen map is always 40x30 mega-characters,
 * but each tile's pixel resolution depends on the video back-end:
 *   - default 1280x720 -> 32x24 tiles (768 words/char, char RAM = 12288 words)
 *   - TETRISARAJ_VIDEO_640 -> 16x16 tiles (256 words/char, char RAM = 4096)
 * Only tetrisaraj_video_chars_init() depends on this; the map writes are the
 * same for both resolutions. */
#ifdef TETRISARAJ_VIDEO_640
#define VID_CHAR_W   16u
#define VID_CHAR_H   16u
#else
#define VID_CHAR_W   32u
#define VID_CHAR_H   24u
#endif
#define VID_CHAR_CELLS ( VID_CHAR_W * VID_CHAR_H )
#define VID_RIGHT0     ( VID_CHAR_W - 2u )
#define VID_RIGHT1     ( VID_CHAR_W - 1u )

void tetrisaraj_platform_init( void )
{
    REG_UART_CLKDIV = UART_CLKDIV;
    REG_GPIO = 0u;
}

uint8_t tetrisaraj_platform_read_buttons( void )
{
    return ( uint8_t ) ( ( REG_GPIO >> 16 ) & 0xffu );
}

void tetrisaraj_platform_set_leds( uint8_t value )
{
    REG_GPIO = 0x00000100u | value;
}

void tetrisaraj_video_set_cell( uint8_t x, uint8_t y, uint8_t color )
{
    if( ( x < TETRISARAJ_FIELD_WIDTH ) && ( y < TETRISARAJ_FIELD_HEIGHT ) )
    {
        REG_VIDEO_MAP[ ( ( uint32_t ) y * TETRISARAJ_FIELD_WIDTH ) + x ] = color;
    }
}

void tetrisaraj_video_clear( uint8_t color )
{
    for( uint8_t y = 0u; y < TETRISARAJ_FIELD_HEIGHT; y++ )
    {
        for( uint8_t x = 0u; x < TETRISARAJ_FIELD_WIDTH; x++ )
        {
            tetrisaraj_video_set_cell( x, y, color );
        }
    }
}

void tetrisaraj_video_show_project_name( void )
{
    const uint8_t name_y = 3u;

    for( uint8_t y = 0u; y < TETRISARAJ_FIELD_HEIGHT; y++ )
    {
        for( uint8_t x = 0u; x < TETRISARAJ_FIELD_WIDTH; x++ )
        {
            uint8_t color = 9u;

            if( ( ( ( y == name_y ) || ( y == ( name_y + 4u ) ) ) && ( x >= 6u ) && ( x <= 8u ) ) ||
                ( ( ( x == 6u ) || ( x == 8u ) ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) ) )
            {
                color = 1u;
            }
            if( ( ( ( y == name_y ) || ( y == ( name_y + 2u ) ) ) && ( x >= 10u ) && ( x <= 12u ) ) ||
                ( ( x == 10u ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) ) ||
                ( ( x == 12u ) && ( y >= name_y ) && ( y <= ( name_y + 2u ) ) ) )
            {
                color = 1u;
            }
            if( ( ( ( y == name_y ) || ( y == ( name_y + 2u ) ) || ( y == ( name_y + 4u ) ) ) && ( x >= 14u ) && ( x <= 16u ) ) ||
                ( ( x == 14u ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) ) )
            {
                color = 1u;
            }
            if( ( ( y == name_y ) && ( x >= 18u ) && ( x <= 20u ) ) ||
                ( ( ( x == 18u ) || ( x == 20u ) ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) ) )
            {
                color = 1u;
            }
            if( ( ( ( x == 22u ) || ( x == 24u ) ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) && ( y != ( name_y + 2u ) ) ) ||
                ( ( x == 23u ) && ( y == ( name_y + 2u ) ) ) )
            {
                color = 2u;
            }
            if( ( ( ( y == name_y ) || ( y == ( name_y + 4u ) ) ) && ( x >= 26u ) && ( x <= 28u ) ) ||
                ( ( x == 26u ) && ( y >= name_y ) && ( y <= ( name_y + 4u ) ) ) )
            {
                color = 2u;
            }
            if( ( ( y == name_y ) && ( x >= 30u ) && ( x <= 32u ) ) ||
                ( ( x == 31u ) && ( y >= ( name_y + 2u ) ) && ( y <= ( name_y + 4u ) ) ) ||
                ( ( x == 32u ) && ( y == ( name_y + 1u ) ) ) )
            {
                color = 2u;
            }

            tetrisaraj_video_set_cell( x, y, color );
        }
    }
}

void tetrisaraj_video_chars_init( void )
{
    uint32_t pixel = 0x00000FFFu;

    for( uint8_t z = 0u; z < 16u; z++ )
    {
        for( uint8_t y = 0u; y < VID_CHAR_H; y++ )
        {
            for( uint8_t x = 0u; x < VID_CHAR_W; x++ )
            {
                if( z == 0u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000222u; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000111u; }
                    else { pixel = 0x00000000u; }
                }
                else if( z == 1u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000080u; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000080u; }
                    else { pixel = 0x000008B4u; }
                }
                else if( z == 2u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x0000000Bu; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x0000000Bu; }
                    else { pixel = 0x00000009u; }
                }
                else if( z == 3u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000A00u; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000B00u; }
                    else { pixel = 0x00000F00u; }
                }
                else if( z == 4u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000FD8u; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000FD4u; }
                    else { pixel = 0x00000FF0u; }
                }
                else if( z == 5u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x0000075Du; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x0000074Du; }
                    else { pixel = 0x0000070Du; }
                }
                else if( z == 6u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000FAFu; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000F6Fu; }
                    else { pixel = 0x00000F0Fu; }
                }
                else if( z == 7u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000FB0u; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000F90u; }
                    else { pixel = 0x00000FA0u; }
                }
                else if( z == 8u )
                {
                    pixel = 0x000000A0u;
                }
                else if( z == 9u )
                {
                    if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x00000CCCu; }
                    else if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x00000111u; }
                    else { pixel = 0x00000AAAu; }
                }
                else if( z == 10u )
                {
                    if( ( y == 0u ) || ( y == 1u ) ) { pixel = 0x0000000Bu; }
                    else if( ( x == VID_RIGHT0 ) || ( x == VID_RIGHT1 ) ) { pixel = 0x0000000Bu; }
                    else { pixel = 0x00000007u; }
                }
                else if( z == 11u )
                {
                    pixel = 0x00000AA0u;
                }
                else if( z == 12u )
                {
                    pixel = 0x000000AAu;
                }
                else if( z == 13u )
                {
                    pixel = 0x00000A0Au;
                }
                else if( z == 14u )
                {
                    pixel = 0x00000FFFu;
                }
                else
                {
                    pixel = 0x00000000u;
                }

                REG_VIDEO_CHAR[ ( ( uint32_t ) z * VID_CHAR_CELLS ) + ( ( uint32_t ) y * VID_CHAR_W ) + x ] = pixel;
            }
        }
    }
}
