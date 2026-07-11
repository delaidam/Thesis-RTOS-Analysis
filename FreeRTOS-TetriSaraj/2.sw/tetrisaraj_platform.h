#ifndef TETRISARAJ_PLATFORM_H
#define TETRISARAJ_PLATFORM_H

#include <stdint.h>

#define TETRISARAJ_FIELD_WIDTH   40u
#define TETRISARAJ_FIELD_HEIGHT  30u
#define TETRISARAJ_FIELD_CELLS   ( TETRISARAJ_FIELD_WIDTH * TETRISARAJ_FIELD_HEIGHT )

#define TETRISARAJ_BUTTON_UP      0x01u
#define TETRISARAJ_BUTTON_RIGHT   0x02u
#define TETRISARAJ_BUTTON_LEFT    0x04u
#define TETRISARAJ_BUTTON_DOWN    0x08u
#define TETRISARAJ_BUTTON_CENTER  0x10u

void tetrisaraj_platform_init( void );
uint8_t tetrisaraj_platform_read_buttons( void );
void tetrisaraj_platform_set_leds( uint8_t value );

void tetrisaraj_video_chars_init( void );
void tetrisaraj_video_set_cell( uint8_t x, uint8_t y, uint8_t color );
void tetrisaraj_video_clear( uint8_t color );
void tetrisaraj_video_show_project_name( void );

#endif /* TETRISARAJ_PLATFORM_H */
