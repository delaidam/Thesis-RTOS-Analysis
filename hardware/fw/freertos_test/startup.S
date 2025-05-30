/*
 * startup.S - PicoRV32 startup kod za BRAM execution
 * Tang Nano 9K + FreeRTOS optimizovan
 */

.section .init, "ax"
.global _start
.type _start, @function

_start:
    /* Disable interrupts during initialization */
    csrw mstatus, zero

    /* Initialize global pointer for small data access */
.option push
.option norelax
    la gp, __global_pointer$
.option pop

    /* Initialize stack pointer */
    la sp, __stack_top

    /* Clear BSS section */
    la t0, _sbss
    la t1, _ebss
    beq t0, t1, 2f
1:
    sw zero, 0(t0)
    addi t0, t0, 4
    blt t0, t1, 1b
2:

    /* Copy initialized data from BRAM to RAM */
    la t0, _sidata      /* Source in BRAM */
    la t1, _sdata       /* Destination in RAM */
    la t2, _edata       /* End of data section */
    beq t1, t2, 4f      /* Skip if no data to copy */
3:
    lw t3, 0(t0)        /* Load from BRAM */
    sw t3, 0(t1)        /* Store to RAM */
    addi t0, t0, 4
    addi t1, t1, 4
    blt t1, t2, 3b
4:

    /* Call global constructors */
    la t0, __ctors_start
    la t1, __ctors_end
    beq t0, t1, 6f
5:
    lw t2, 0(t0)
    jalr t2
    addi t0, t0, 4
    blt t0, t1, 5b
6:

    /* Jump to main function */
    call main

    /* If main returns, loop forever */
7:
    wfi
    j 7b

.size _start, . - _start

/*
 * Default interrupt/exception handler
 */
.section .text
.global _default_handler
.type _default_handler, @function
_default_handler:
    /* Save context (minimal for demo) */
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)

    /* Check if this is a timer interrupt for FreeRTOS */
    csrr t0, mcause
    li t1, 0x80000007   /* Timer interrupt */
    beq t0, t1, timer_interrupt
    
    /* Other interrupts - just return for now */
    j restore_context

timer_interrupt:
    /* FreeRTOS timer interrupt handler would go here */
    /* For now, just acknowledge and return */
    
restore_context:
    /* Restore context */
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    addi sp, sp, 64
    
    mret

.size _default_handler, . - _default_handler

/*
 * Vector table (minimal for PicoRV32)
 */
.section .vectors, "ax"
.global __vectors_start
__vectors_start:
    j _start              /* Reset */
    j _default_handler    /* Exception */
    j _default_handler    /* Interrupt */
    j _default_handler    /* Reserved */

.size __vectors_start, . - __vectors_start

/*
 * Memory allocation functions for static FreeRTOS
 */
.section .text

/* Idle task static memory */
.global idle_task_tcb
.global idle_task_stack
.section .bss
.align 4
idle_task_tcb:
    .space 192  /* StaticTask_t size approximation */
idle_task_stack:
    .space 512  /* 128 words * 4 bytes */

/* Timer task static memory (if enabled) */
.global timer_task_tcb  
.global timer_task_stack
timer_task_tcb:
    .space 192
timer_task_stack:
    .space 1024 /* 256 words * 4 bytes */