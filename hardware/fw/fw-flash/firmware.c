#include <stdint.h>
#include <stdbool.h>
#include "rt_kernel.h"
// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

typedef struct {
    volatile uint32_t DATA;
    volatile uint32_t CLKDIV;
} PICOUART;

typedef struct {
    volatile uint32_t OUT;
    volatile uint32_t IN;
    volatile uint32_t OE;
} PICOGPIO;

typedef struct {
    union {
        volatile uint32_t REG;
        volatile uint16_t IOW;
        struct {
            volatile uint8_t IO;
            volatile uint8_t OE;
            volatile uint8_t CFG;
            volatile uint8_t EN; 
        };
    };
} PICOQSPI;

#define QSPI0 ((PICOQSPI*)0x81000000)
#define GPIO0 ((PICOGPIO*)0x82000000)
#define UART0 ((PICOUART*)0x83000000)

#define FLASHIO_ENTRY_ADDR ((void *)0x80000054)

void (*spi_flashio)(uint8_t *pdata, int length, int wren) = FLASHIO_ENTRY_ADDR;

int putchar(int c)
{	
    if (c == '\n')
        UART0->DATA = '\r';
    UART0->DATA = c;
    
    return c;
}

void print(const char *p)
{
    while (*p)
        putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
    for (int i = 7; i >= 0; i--) {
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
        if (c == '0' && i >= digits) continue;
        putchar(c);
        digits = i;
    }
}

void print_dec(uint32_t v)
{
    if (v >= 100) {
        print(">=100");
        return;
    }

    if      (v >= 90) { putchar('9'); v -= 90; }
    else if (v >= 80) { putchar('8'); v -= 80; }
    else if (v >= 70) { putchar('7'); v -= 70; }
    else if (v >= 60) { putchar('6'); v -= 60; }
    else if (v >= 50) { putchar('5'); v -= 50; }
    else if (v >= 40) { putchar('4'); v -= 40; }
    else if (v >= 30) { putchar('3'); v -= 30; }
    else if (v >= 20) { putchar('2'); v -= 20; }
    else if (v >= 10) { putchar('1'); v -= 10; }

    if      (v >= 9) { putchar('9'); v -= 9; }
    else if (v >= 8) { putchar('8'); v -= 8; }
    else if (v >= 7) { putchar('7'); v -= 7; }
    else if (v >= 6) { putchar('6'); v -= 6; }
    else if (v >= 5) { putchar('5'); v -= 5; }
    else if (v >= 4) { putchar('4'); v -= 4; }
    else if (v >= 3) { putchar('3'); v -= 3; }
    else if (v >= 2) { putchar('2'); v -= 2; }
    else if (v >= 1) { putchar('1'); v -= 1; }
    else putchar('0');
}

char getchar_prompt(char *prompt)
{
    int32_t c = -1;

    uint32_t cycles_begin, cycles_now, cycles;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

    if (prompt)
        print(prompt);

    // if (prompt)
        // GPIO0->OUT = ~0;
        // reg_leds = ~0;

    while (c == -1) {
        __asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
        cycles = cycles_now - cycles_begin;
        if (cycles > 12000000) {
            if (prompt)
                print(prompt);
            cycles_begin = cycles_now;
            // if (prompt)
                // GPIO0->OUT = ~GPIO0->OUT;
                // reg_leds = ~reg_leds;
        }
        c = UART0->DATA;
    }
    // if (prompt)
        // GPIO0->OUT = 0;
        // reg_leds = 0;
    return c;
}

char getchar()
{
    return getchar_prompt(0);
}

#define QSPI_REG_CRM  0x00100000
#define QSPI_REG_DSPI 0x00400000

void cmd_set_crm(int on)
{
    if (on) {
        QSPI0->REG |= QSPI_REG_CRM;
    } else {
        QSPI0->REG &= ~QSPI_REG_CRM;
    }
}

int cmd_get_crm() {
    return QSPI0->REG & QSPI_REG_CRM;
}

void cmd_set_dspi(int on)
{
    if (on) {
        QSPI0->REG |= QSPI_REG_DSPI;
    } else {
        QSPI0->REG &= ~QSPI_REG_DSPI;
    }
}

int cmd_get_dspi() {
    return QSPI0->REG & QSPI_REG_DSPI;
}

void cmd_read_flash_id()
{
    int pre_dspi = cmd_get_dspi();

    cmd_set_dspi(0);
    
    uint8_t buffer[4] = { 0x9F, /* zeros */ };
    spi_flashio(buffer, 4, 0);

    for (int i = 1; i <= 3; i++) {
        putchar(' ');
        print_hex(buffer[i], 2);
    }
    putchar('\n');

    cmd_set_dspi(pre_dspi);
}

// --------------------------------------------------------

uint32_t cmd_benchmark(bool verbose, uint32_t *instns_p)
{
    uint8_t data[256];
    uint32_t *words = (void*)data;

    uint32_t x32 = 314159265;

    uint32_t cycles_begin, cycles_end;
    uint32_t instns_begin, instns_end;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
    __asm__ volatile ("rdinstret %0" : "=r"(instns_begin));

    for (int i = 0; i < 20; i++)
    {
        for (int k = 0; k < 256; k++)
        {
            x32 ^= x32 << 13;
            x32 ^= x32 >> 17;
            x32 ^= x32 << 5;
            data[k] = x32;
        }

        for (int k = 0, p = 0; k < 256; k++)
        {
            if (data[k])
                data[p++] = k;
        }

        for (int k = 0, p = 0; k < 64; k++)
        {
            x32 = x32 ^ words[k];
        }
    }

    __asm__ volatile ("rdcycle %0" : "=r"(cycles_end));
    __asm__ volatile ("rdinstret %0" : "=r"(instns_end));

    if (verbose)
    {
        print("Cycles: 0x");
        print_hex(cycles_end - cycles_begin, 8);
        putchar('\n');

        print("Instns: 0x");
        print_hex(instns_end - instns_begin, 8);
        putchar('\n');

        print("Chksum: 0x");
        print_hex(x32, 8);
        putchar('\n');
    }

    if (instns_p)
        *instns_p = instns_end - instns_begin;

    return cycles_end - cycles_begin;
}

void cmd_benchmark_all()
{
    uint32_t instns = 0;

    print("default        ");

    cmd_set_dspi(0);
    cmd_set_crm(0);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
    putchar('\n');

    print("dspi-");
    print_dec(0);
    print("         ");

    cmd_set_dspi(1);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
    putchar('\n');

    print("dspi-crm-");
    print_dec(0);
    print("     ");

    cmd_set_crm(1);

    print(": ");
    print_hex(cmd_benchmark(false, &instns), 8);
    putchar('\n');

    print("instns         : ");
    print_hex(instns, 8);
    putchar('\n');
}

volatile int i;
// --------------------------------------------------------

#define CLK_FREQ        25175000
#define UART_BAUD       115200

void main()
{
    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;

    GPIO0->OE = 0x3F;
    GPIO0->OUT = 0x3F;

    cmd_set_crm(1);
    cmd_set_dspi(1);

    print("\n");
    print("  ____  _          ____         ____\n");
    print(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\n");
    print(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\n");
    print(" |  __/| | (_| (_) |__) | (_) | |___\n");
    print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
    print("\n");
    print("        On Lichee Tang Nano-9K\n");
    print("\n");

    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x01;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x02;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x04;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x08;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x10;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F ^ 0x20;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x00;
    for ( i = 0 ; i < 10000; i++);
    GPIO0->OUT = 0x3F;
    for ( i = 0 ; i < 10000; i++);

    // Zameni while(1) sa rt_main_loop()
    rt_main_loop();
}

void irqCallback() {

}