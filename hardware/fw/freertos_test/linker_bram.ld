/*
 * linker_bram.ld - Linker script za Tang Nano 9K BRAM execution
 * Optimizovan za PicoRV32 + FreeRTOS u BRAM memoriji
 */

OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

/* Tang Nano 9K BRAM Memory Layout */
MEMORY
{
    /* BRAM - 30KB total, reserve some for stack/heap */
    BRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 24K  /* 24KB for code+data */
    RAM  (rw)  : ORIGIN = 0x00006000, LENGTH = 6K   /* 6KB for stack+heap */
}

/* Stack and heap sizes */
_stack_size = DEFINED(_stack_size) ? _stack_size : 2K;
_heap_size = DEFINED(_heap_size) ? _heap_size : 4K;

SECTIONS
{
    /* Reset vector and startup code */
    .init : ALIGN(4)
    {
        _stext = .;
        KEEP(*(.init))
        KEEP(*(.init.*))
    } > BRAM

    /* Program code */
    .text : ALIGN(4)
    {
        *(.text)
        *(.text.*)
        *(.gnu.linkonce.t.*)
        
        /* FreeRTOS specific sections */
        *(.freertos_vectors)
        *(.freertos_system_calls)
        
        . = ALIGN(4);
        _etext = .;
    } > BRAM

    /* Read-only data */
    .rodata : ALIGN(4)
    {
        *(.rodata)
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
        *(.srodata)
        *(.srodata.*)
        . = ALIGN(4);
        _erodata = .;
    } > BRAM

    /* Exception/interrupt vectors */
    .vectors : ALIGN(4)
    {
        PROVIDE(__vectors_start = .);
        *(.vectors)
        *(.vectors.*)
        PROVIDE(__vectors_end = .);
        . = ALIGN(4);
    } > BRAM

    /* Global constructors */
    .ctors : ALIGN(4)
    {
        PROVIDE(__ctors_start = .);
        KEEP(*(.init_array*))
        KEEP(*(SORT(.ctors.*)))
        KEEP(*(.ctors))
        PROVIDE(__ctors_end = .);
        . = ALIGN(4);
    } > BRAM

    /* Data section initialization info */
    _sidata = LOADADDR(.data);

    /* Initialized data - copied to RAM at startup */
    .data : ALIGN(4)
    {
        _sdata = .;
        _ram_start = .;
        
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
        
        . = ALIGN(8);
        PROVIDE(__global_pointer$ = . + 0x800);
        
        *(.sdata)
        *(.sdata.*)
        *(.gnu.linkonce.s.*)
        
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > BRAM

    /* Uninitialized data */
    .bss : ALIGN(4)
    {
        _sbss = .;
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(.gnu.linkonce.sb.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* End of used RAM */
    _end = .;
    PROVIDE(end = .);

    /* FreeRTOS heap - defined in RAM after BSS */
    .heap : ALIGN(8)
    {
        PROVIDE(__heap_start = .);
        . = . + _heap_size;
        . = ALIGN(8);
        PROVIDE(__heap_end = .);
        PROVIDE(__heap_size = _heap_size);
    } > RAM

    /* Stack - grows downward from end of RAM */
    .stack : ALIGN(16)
    {
        PROVIDE(_stack_end = .);
        . = . + _stack_size;
        . = ALIGN(16);
        PROVIDE(_stack_start = .);
        PROVIDE(__stack_top = .);
    } > RAM

    /* IRQ Stack - for FreeRTOS interrupts */
    .stack_irq : ALIGN(16)
    {
        __stack_start = .;
        . += 1024;  /* IRQ stack size */
        __freertos_irq_stack_top = .;
        . += 1024;  /* Main stack size */
        __stack_top = .;
    } > RAM

    /* Memory region end markers */
    PROVIDE(__bram_start = ORIGIN(BRAM));
    PROVIDE(__bram_end = ORIGIN(BRAM) + LENGTH(BRAM));
    PROVIDE(__ram_start = ORIGIN(RAM));
    PROVIDE(__ram_end = ORIGIN(RAM) + LENGTH(RAM));

    /* FreeRTOS memory regions */
    PROVIDE(__freertos_heap_start = __heap_start);
    PROVIDE(__freertos_heap_end = __heap_end);
    
    /* Debug sections (not loaded) */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_ranges   0 : { *(.debug_ranges) }

    /* Discard unwanted sections */
    /DISCARD/ :
    {
        *(.note.GNU-stack)
        *(.gnu_debuglink)
        *(.gnu.lto_*)
    }
}