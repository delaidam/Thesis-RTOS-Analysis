.section .text.start, "ax"
.global start
.global irq_vector
.global picorv32_set_irq_mask

start:
    j reset_entry
irq_vector:
    j irq_entry

reset_entry:
# zero-initialize register file
addi x1, zero, 0
# x2 (sp) is initialized by reset
addi x3, zero, 0
addi x4, zero, 0
addi x5, zero, 0
addi x6, zero, 0
addi x7, zero, 0
addi x8, zero, 0
addi x9, zero, 0
addi x10, zero, 0
addi x11, zero, 0
addi x12, zero, 0
addi x13, zero, 0
addi x14, zero, 0
addi x15, zero, 0
addi x16, zero, 0
addi x17, zero, 0
addi x18, zero, 0
addi x19, zero, 0
addi x20, zero, 0
addi x21, zero, 0
addi x22, zero, 0
addi x23, zero, 0
addi x24, zero, 0
addi x25, zero, 0
addi x26, zero, 0
addi x27, zero, 0
addi x28, zero, 0
addi x29, zero, 0
addi x30, zero, 0
addi x31, zero, 0

# zero initialize entire scratchpad memory
li a0, 0x00000000
li a1, 0x00000000
setmemloop:
sw a1, 0(a0)
addi a0, a0, 4
blt a0, sp, setmemloop

# copy data section
la a0, _sidata
la a1, _sdata
la a2, _edata
bge a1, a2, end_init_data
loop_init_data:
lw a3, 0(a0)
sw a3, 0(a1)
addi a0, a0, 4
addi a1, a1, 4
blt a1, a2, loop_init_data
end_init_data:

# # zero-init bss section
la a0, _sbss
la a1, _ebss
bge a0, a1, end_init_bss
loop_init_bss:
sw zero, 0(a0)
addi a0, a0, 4
blt a0, a1, loop_init_bss
end_init_bss:

# # call main
call main
loop:
j loop

picorv32_set_irq_mask:
# PicoRV32 custom0 maskirq, rd=x0, rs1=a0
.word 0x0605000b
ret

irq_entry:
addi sp, sp, -28
sw t0, 0(sp)
sw t1, 4(sp)
sw t2, 8(sp)
sw t3, 12(sp)
sw t4, 16(sp)
sw t5, 20(sp)
sw t6, 24(sp)

la t0, irq_count
lw t1, 0(t0)
addi t1, t1, 1
sw t1, 0(t0)

la t0, last_irq_pending
sw x4, 0(t0)

li t0, 0x03000000
lw t4, 0(t0)
lw t5, 24(t0)

la t1, irq_timestamp
sw t4, 0(t1)
la t1, irq_event_timestamp
sw t5, 0(t1)

sub t6, t4, t5
la t1, irq_latency_last
sw t6, 0(t1)
la t1, irq_latency_total
lw t2, 0(t1)
add t2, t2, t6
sw t2, 0(t1)
la t1, irq_latency_samples
lw t2, 0(t1)
addi t2, t2, 1
sw t2, 0(t1)
la t1, irq_latency_min
lw t2, 0(t1)
beqz t2, set_irq_latency_min
bltu t6, t2, set_irq_latency_min
j check_irq_latency_max
set_irq_latency_min:
sw t6, 0(t1)
check_irq_latency_max:
la t1, irq_latency_max
lw t2, 0(t1)
bltu t2, t6, set_irq_latency_max
j update_irq_interval
set_irq_latency_max:
sw t6, 0(t1)

update_irq_interval:
la t1, irq_last_timer
lw t2, 0(t1)
beqz t2, store_irq_last_timer
sub t6, t4, t2
la t1, irq_interval_last
sw t6, 0(t1)
la t1, irq_interval_total
lw t2, 0(t1)
add t2, t2, t6
sw t2, 0(t1)
la t1, irq_interval_samples
lw t2, 0(t1)
addi t2, t2, 1
sw t2, 0(t1)
la t1, irq_interval_min
lw t2, 0(t1)
beqz t2, set_irq_interval_min
bltu t6, t2, set_irq_interval_min
j check_irq_interval_max
set_irq_interval_min:
sw t6, 0(t1)
check_irq_interval_max:
la t1, irq_interval_max
lw t2, 0(t1)
bltu t2, t6, set_irq_interval_max
j store_irq_last_timer
set_irq_interval_max:
sw t6, 0(t1)

store_irq_last_timer:
la t1, irq_last_timer
sw t4, 0(t1)

li t0, 0x03000000
li t1, 1
sw t1, 12(t0)

lw t0, 0(sp)
lw t1, 4(sp)
lw t2, 8(sp)
lw t3, 12(sp)
lw t4, 16(sp)
lw t5, 20(sp)
lw t6, 24(sp)
addi sp, sp, 28

# PicoRV32 custom0 retirq
.word 0x0400000b

.section .bss
.weak irq_count
.align 2
irq_count:
.word 0

.weak last_irq_pending
.align 2
last_irq_pending:
.word 0

.weak irq_timestamp
.align 2
irq_timestamp:
.word 0

.weak irq_event_timestamp
.align 2
irq_event_timestamp:
.word 0

.weak irq_last_timer
.align 2
irq_last_timer:
.word 0

.weak irq_latency_last
.align 2
irq_latency_last:
.word 0

.weak irq_latency_min
.align 2
irq_latency_min:
.word 0

.weak irq_latency_max
.align 2
irq_latency_max:
.word 0

.weak irq_latency_total
.align 2
irq_latency_total:
.word 0

.weak irq_latency_samples
.align 2
irq_latency_samples:
.word 0

.weak irq_interval_last
.align 2
irq_interval_last:
.word 0

.weak irq_interval_min
.align 2
irq_interval_min:
.word 0

.weak irq_interval_max
.align 2
irq_interval_max:
.word 0

.weak irq_interval_total
.align 2
irq_interval_total:
.word 0

.weak irq_interval_samples
.align 2
irq_interval_samples:
.word 0
