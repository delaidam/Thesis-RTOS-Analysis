#ifndef TETRISARAJ_GAME_H
#define TETRISARAJ_GAME_H

#include <stdbool.h>
#include <stdint.h>

#include "tetrisaraj_platform.h"

typedef struct
{
    uint8_t buttons;
} TetriSarajInput;

typedef struct
{
    uint8_t field[ TETRISARAJ_FIELD_CELLS ];
    uint8_t piece_index;
    uint8_t piece_rotation;
    uint8_t piece_x;
    uint8_t piece_y;
    uint8_t speed_ticks;
    uint8_t game_ticks;
    uint8_t lives;
    uint8_t lines_x[ 4 ];
    uint8_t lines_count;
    uint8_t previous_side;
    uint8_t random_side;
    uint8_t pieces_until_speedup;
    uint16_t score;
    uint32_t rng_state;
    bool rotation_released;
    bool game_over;
    bool the_end;
    bool dirty;
} TetriSarajGame;

void tetrisaraj_game_init( TetriSarajGame * game );
void tetrisaraj_game_step( TetriSarajGame * game, const TetriSarajInput * input );
void tetrisaraj_game_render( const TetriSarajGame * game );

/* Display value for a single cell, with the active falling piece overlaid on
 * top of the locked field. Used by the headless UART renderer so the tetromino
 * tables can stay private to tetrisaraj_game.c. */
uint8_t tetrisaraj_game_cell_at( const TetriSarajGame * game, uint8_t x, uint8_t y );

#endif /* TETRISARAJ_GAME_H */
