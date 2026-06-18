#include "tetrisaraj_game.h"

static const uint8_t ucTetrominoes[ 7 ][ 16 ] =
{
    { 1u, 1u, 1u, 1u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 0u, 1u, 0u, 0u, 1u, 1u, 0u, 0u, 0u, 1u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 0u, 0u, 0u, 0u, 1u, 1u, 0u, 0u, 1u, 1u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 0u, 1u, 0u, 0u, 1u, 1u, 0u, 0u, 1u, 0u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 1u, 0u, 0u, 0u, 1u, 1u, 0u, 0u, 0u, 1u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 1u, 0u, 0u, 0u, 1u, 0u, 0u, 0u, 1u, 1u, 0u, 0u, 0u, 0u, 0u },
    { 0u, 0u, 1u, 0u, 0u, 0u, 1u, 0u, 0u, 1u, 1u, 0u, 0u, 0u, 0u, 0u }
};

static uint8_t ucRotate( uint8_t x, uint8_t y, uint8_t rotation )
{
    switch( rotation & 3u )
    {
        case 0u: return ( uint8_t ) ( ( y * 4u ) + x );
        case 1u: return ( uint8_t ) ( 12u + y - ( x * 4u ) );
        case 2u: return ( uint8_t ) ( 15u - ( y * 4u ) - x );
        default: return ( uint8_t ) ( 3u - y + ( x * 4u ) );
    }
}

static uint32_t ulNextRandom( TetriSarajGame * game )
{
    uint32_t x = game->rng_state;

    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    game->rng_state = x;

    return x;
}

static uint8_t ucRandomBinary( TetriSarajGame * game )
{
    return ( uint8_t ) ( ulNextRandom( game ) & 1u );
}

static uint8_t ucRandomPieceY( TetriSarajGame * game )
{
    uint8_t candidate;

    do
    {
        candidate = ( uint8_t ) ( ulNextRandom( game ) & 31u );
    } while( candidate >= 18u );

    return ( uint8_t ) ( candidate + 2u );
}

static void prvFieldInit( TetriSarajGame * game )
{
    for( uint8_t y = 0u; y < TETRISARAJ_FIELD_HEIGHT; y++ )
    {
        for( uint8_t x = 0u; x < TETRISARAJ_FIELD_WIDTH; x++ )
        {
            const bool border = ( y == 0u ) ||
                                ( y >= ( TETRISARAJ_FIELD_HEIGHT - 7u ) ) ||
                                ( ( x + 1u ) == ( TETRISARAJ_FIELD_WIDTH / 2u ) ) ||
                                ( x == ( TETRISARAJ_FIELD_WIDTH / 2u ) );
            game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] = border ? 9u : 0u;
        }
    }
}

static void prvDrawDigit( TetriSarajGame * game, uint8_t number, uint8_t start_x, uint8_t start_y )
{
    for( uint8_t y = start_y; y < ( uint8_t ) ( start_y + 5u ); y++ )
    {
        for( uint8_t x = start_x; x < ( uint8_t ) ( start_x + 3u ); x++ )
        {
            bool on = false;

            switch( number )
            {
                case 0u: on = ( x == start_x ) || ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 4u ) ); break;
                case 1u: on = ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == ( uint8_t ) ( start_y + 1u ) ); break;
                case 2u: on = ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ) || ( ( y == ( uint8_t ) ( start_y + 1u ) ) && ( x == ( uint8_t ) ( start_x + 2u ) ) ) || ( ( y == ( uint8_t ) ( start_y + 3u ) ) && ( x == start_x ) ); break;
                case 3u: on = ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ); break;
                case 4u: on = ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( ( y <= ( uint8_t ) ( start_y + 2u ) ) && ( x == start_x ) ); break;
                case 5u: on = ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ) || ( ( y == ( uint8_t ) ( start_y + 1u ) ) && ( x == start_x ) ) || ( ( y == ( uint8_t ) ( start_y + 3u ) ) && ( x == ( uint8_t ) ( start_x + 2u ) ) ); break;
                case 6u: on = ( x == start_x ) || ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ) || ( ( y == ( uint8_t ) ( start_y + 3u ) ) && ( x == ( uint8_t ) ( start_x + 2u ) ) ); break;
                case 7u: on = ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == start_y ); break;
                case 8u: on = ( x == start_x ) || ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ); break;
                case 9u: on = ( x == ( uint8_t ) ( start_x + 2u ) ) || ( y == start_y ) || ( y == ( uint8_t ) ( start_y + 2u ) ) || ( y == ( uint8_t ) ( start_y + 4u ) ) || ( ( y == ( uint8_t ) ( start_y + 1u ) ) && ( x == start_x ) ); break;
                default: break;
            }

            game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] = on ? 0u : 9u;
        }
    }
}

static uint8_t ucCountThousands( uint16_t * value, uint16_t place )
{
    uint8_t digit = 0u;

    while( *value >= place )
    {
        *value = ( uint16_t ) ( *value - place );
        digit++;
    }

    return digit;
}

static void prvWriteScore( TetriSarajGame * game )
{
    uint16_t value = game->score;
    const uint8_t digits[ 4 ] =
    {
        ucCountThousands( &value, 1000u ),
        ucCountThousands( &value, 100u ),
        ucCountThousands( &value, 10u ),
        ( uint8_t ) value
    };

    for( uint8_t y = 24u; y < 29u; y++ )
    {
        for( uint8_t x = 3u; x < 21u; x++ )
        {
            bool on = false;

            if( ( x == 3u ) || ( x == 4u ) )
            {
                on = ( y == 24u ) || ( y == 26u ) || ( y == 28u ) || ( ( x == 3u ) && ( y == 25u ) ) || ( ( x == 4u ) && ( y == 27u ) );
            }
            else if( ( x == 6u ) || ( x == 7u ) )
            {
                on = ( x == 6u ) || ( y == 24u ) || ( y == 28u );
            }
            else if( ( x == 9u ) || ( x == 10u ) || ( x == 11u ) )
            {
                on = ( x == 9u ) || ( x == 11u ) || ( y == 24u ) || ( y == 28u );
            }
            else if( ( x == 13u ) || ( x == 14u ) || ( x == 15u ) )
            {
                on = ( x == 13u ) || ( ( x == 14u ) && ( ( y == 24u ) || ( y == 26u ) ) ) || ( ( x == 15u ) && ( ( y == 25u ) || ( y > 26u ) ) );
            }
            else if( ( x == 17u ) || ( x == 18u ) )
            {
                on = ( x == 17u ) || ( ( x == 18u ) && ( ( y & 1u ) == 0u ) );
            }
            else if( x == 20u )
            {
                on = ( y == 25u ) || ( y == 27u );
            }

            game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] = on ? 0u : 9u;
        }
    }

    for( uint8_t i = 0u; i < 4u; i++ )
    {
        prvDrawDigit( game, digits[ i ], ( uint8_t ) ( 22u + ( i * 4u ) ), 24u );
    }
}

static bool xPieceFits( const TetriSarajGame * game, uint8_t piece_index, uint8_t rotation, int8_t pos_x, int8_t pos_y )
{
    for( uint8_t x = 0u; x < 4u; x++ )
    {
        for( uint8_t y = 0u; y < 4u; y++ )
        {
            const int8_t field_x = ( int8_t ) ( pos_x + ( int8_t ) x );
            const int8_t field_y = ( int8_t ) ( pos_y + ( int8_t ) y );
            const uint8_t piece_cell = ucTetrominoes[ piece_index ][ ucRotate( x, y, rotation ) ];

            if( ( field_x >= 0 ) && ( field_x < ( int8_t ) TETRISARAJ_FIELD_WIDTH ) &&
                ( field_y >= 0 ) && ( field_y < ( int8_t ) TETRISARAJ_FIELD_HEIGHT ) )
            {
                const uint16_t field_index = ( uint16_t ) ( ( ( uint16_t ) field_y * TETRISARAJ_FIELD_WIDTH ) + ( uint8_t ) field_x );
                if( ( piece_cell != 0u ) && ( game->field[ field_index ] != 0u ) )
                {
                    return false;
                }
            }
        }
    }

    return true;
}

static void prvSpawnPiece( TetriSarajGame * game )
{
    game->piece_y = ucRandomPieceY( game );
    game->random_side = ucRandomBinary( game );
    game->piece_rotation = 3u;
    game->piece_x = ( game->random_side == 0u ) ? 0u : ( TETRISARAJ_FIELD_WIDTH - 4u );
    game->piece_index++;
    if( game->piece_index >= 7u )
    {
        game->piece_index = 0u;
    }

    game->game_over = !xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) game->piece_x, ( int8_t ) game->piece_y );
}

static void prvLockPiece( TetriSarajGame * game )
{
    for( uint8_t x = 0u; x < 4u; x++ )
    {
        for( uint8_t y = 0u; y < 4u; y++ )
        {
            if( ucTetrominoes[ game->piece_index ][ ucRotate( x, y, game->piece_rotation ) ] != 0u )
            {
                const uint8_t field_x = ( uint8_t ) ( game->piece_x + x );
                const uint8_t field_y = ( uint8_t ) ( game->piece_y + y );
                if( ( field_x < TETRISARAJ_FIELD_WIDTH ) && ( field_y < TETRISARAJ_FIELD_HEIGHT ) )
                {
                    game->field[ ( field_y * TETRISARAJ_FIELD_WIDTH ) + field_x ] = ( uint8_t ) ( game->piece_index + 1u );
                }
            }
        }
    }

    game->lines_count = 0u;
    for( uint8_t x = 0u; x < 4u; x++ )
    {
        const uint8_t line_x = ( uint8_t ) ( game->piece_x + x );
        bool line = true;

        if( line_x >= TETRISARAJ_FIELD_WIDTH )
        {
            line = false;
        }

        for( uint8_t y = 1u; ( y < ( TETRISARAJ_FIELD_HEIGHT - 7u ) ) && line; y++ )
        {
            const uint8_t cell = game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + line_x ];
            if( ( cell == 0u ) || ( cell == 9u ) )
            {
                line = false;
            }
        }

        if( line && ( game->lines_count < 4u ) )
        {
            for( uint8_t y = 1u; y < ( TETRISARAJ_FIELD_HEIGHT - 7u ); y++ )
            {
                game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + line_x ] = 0u;
            }
            game->lines_x[ game->lines_count ] = line_x;
            game->lines_count++;
        }
    }

    game->previous_side = game->random_side;
    game->score++;
    if( game->lines_count != 0u )
    {
        game->score = ( uint16_t ) ( game->score + ( ( uint16_t ) ( 1u << game->lines_count ) * 20u ) );
    }

    if( game->pieces_until_speedup > 0u )
    {
        game->pieces_until_speedup--;
    }
    if( game->pieces_until_speedup == 0u )
    {
        if( game->speed_ticks >= 10u )
        {
            game->speed_ticks--;
        }
        game->pieces_until_speedup = 50u;
    }

    if( game->lines_count != 0u )
    {
        if( game->previous_side == 0u )
        {
            for( uint8_t i = 0u; i < game->lines_count; i++ )
            {
                for( uint8_t x = game->lines_x[ i ]; x > 0u; x-- )
                {
                    for( uint8_t y = 1u; y < ( TETRISARAJ_FIELD_HEIGHT - 7u ); y++ )
                    {
                        game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] =
                            game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + ( x - 1u ) ];
                    }
                }
            }
        }
        else
        {
            for( uint8_t i = game->lines_count; i > 0u; i-- )
            {
                const uint8_t line_x = game->lines_x[ i - 1u ];
                for( uint8_t x = line_x; x < ( TETRISARAJ_FIELD_WIDTH - 1u ); x++ )
                {
                    for( uint8_t y = 1u; y < ( TETRISARAJ_FIELD_HEIGHT - 7u ); y++ )
                    {
                        game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] =
                            game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + ( x + 1u ) ];
                    }
                }
            }
        }
    }

    game->lines_count = 0u;
    prvWriteScore( game );
    prvSpawnPiece( game );
}

void tetrisaraj_game_init( TetriSarajGame * game )
{
    game->piece_index = 0u;
    game->piece_rotation = 3u;
    game->piece_x = 0u;
    game->piece_y = TETRISARAJ_FIELD_HEIGHT / 2u;
    game->speed_ticks = 15u;
    game->game_ticks = 0u;
    game->lives = 3u;
    game->lines_count = 0u;
    game->previous_side = 0u;
    game->random_side = 0u;
    game->pieces_until_speedup = 50u;
    game->score = 0u;
    game->rng_state = 123456789u;
    game->rotation_released = true;
    game->game_over = false;
    game->the_end = false;
    game->dirty = true;

    for( uint8_t i = 0u; i < 4u; i++ )
    {
        game->lines_x[ i ] = 0u;
    }

    prvFieldInit( game );
    prvWriteScore( game );
}

void tetrisaraj_game_step( TetriSarajGame * game, const TetriSarajInput * input )
{
    const uint8_t buttons = input->buttons;
    const bool up = ( buttons & TETRISARAJ_BUTTON_UP ) != 0u;
    const bool down = ( buttons & TETRISARAJ_BUTTON_DOWN ) != 0u;
    const bool right = ( buttons & TETRISARAJ_BUTTON_RIGHT ) != 0u;
    const bool left = ( buttons & TETRISARAJ_BUTTON_LEFT ) != 0u;
    const bool center = ( buttons & TETRISARAJ_BUTTON_CENTER ) != 0u;
    bool move_piece = false;

    if( game->the_end )
    {
        if( center )
        {
            tetrisaraj_game_init( game );
        }
        return;
    }

    if( game->game_over )
    {
        if( game->lives <= 1u )
        {
            game->the_end = true;
        }
        else
        {
            game->lives--;
            game->game_over = false;
            prvFieldInit( game );
            prvWriteScore( game );
            prvSpawnPiece( game );
        }
        game->dirty = true;
        return;
    }

    game->game_ticks++;
    if( game->game_ticks >= game->speed_ticks )
    {
        game->game_ticks = 0u;
        move_piece = true;
    }

    if( game->random_side == 0u )
    {
        if( down && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) game->piece_x, ( int8_t ) ( game->piece_y + 1u ) ) )
        {
            game->piece_y++;
        }
        if( up && ( game->piece_y > 0u ) && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) game->piece_x, ( int8_t ) ( game->piece_y - 1u ) ) )
        {
            game->piece_y--;
        }
        if( right && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) ( game->piece_x + 1u ), ( int8_t ) game->piece_y ) )
        {
            game->piece_x++;
        }
    }
    else
    {
        if( up && ( game->piece_y > 0u ) && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) game->piece_x, ( int8_t ) ( game->piece_y - 1u ) ) )
        {
            game->piece_y--;
        }
        if( down && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) game->piece_x, ( int8_t ) ( game->piece_y + 1u ) ) )
        {
            game->piece_y++;
        }
        if( left && ( game->piece_x > 0u ) && xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) ( game->piece_x - 1u ), ( int8_t ) game->piece_y ) )
        {
            game->piece_x--;
        }
    }

    if( center )
    {
        if( game->rotation_released && xPieceFits( game, game->piece_index, ( uint8_t ) ( game->piece_rotation + 1u ), ( int8_t ) game->piece_x, ( int8_t ) game->piece_y ) )
        {
            game->piece_rotation++;
        }
        game->rotation_released = false;
    }
    else
    {
        game->rotation_released = true;
    }

    if( move_piece )
    {
        if( ( game->random_side == 0u ) &&
            xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) ( game->piece_x + 1u ), ( int8_t ) game->piece_y ) )
        {
            game->piece_x++;
        }
        else if( ( game->random_side != 0u ) && ( game->piece_x > 0u ) &&
                 xPieceFits( game, game->piece_index, game->piece_rotation, ( int8_t ) ( game->piece_x - 1u ), ( int8_t ) game->piece_y ) )
        {
            game->piece_x--;
        }
        else
        {
            prvLockPiece( game );
        }
    }

    game->dirty = true;
}

void tetrisaraj_game_render( const TetriSarajGame * game )
{
    if( game->the_end )
    {
        tetrisaraj_video_clear( 0u );
        for( uint8_t y = 8u; y < 13u; y++ )
        {
            for( uint8_t x = 8u; x < 32u; x++ )
            {
                if( ( y == 8u ) || ( y == 12u ) || ( x == 8u ) || ( x == 31u ) )
                {
                    tetrisaraj_video_set_cell( x, y, 3u );
                }
            }
        }
        return;
    }

    for( uint8_t y = 0u; y < TETRISARAJ_FIELD_HEIGHT; y++ )
    {
        for( uint8_t x = 0u; x < TETRISARAJ_FIELD_WIDTH; x++ )
        {
            tetrisaraj_video_set_cell( x, y, game->field[ ( y * TETRISARAJ_FIELD_WIDTH ) + x ] );
        }
    }

    for( uint8_t x = 0u; x < 4u; x++ )
    {
        for( uint8_t y = 0u; y < 4u; y++ )
        {
            if( ucTetrominoes[ game->piece_index ][ ucRotate( x, y, game->piece_rotation ) ] != 0u )
            {
                tetrisaraj_video_set_cell( ( uint8_t ) ( game->piece_x + x ),
                                           ( uint8_t ) ( game->piece_y + y ),
                                           ( uint8_t ) ( game->piece_index + 1u ) );
            }
        }
    }
}
