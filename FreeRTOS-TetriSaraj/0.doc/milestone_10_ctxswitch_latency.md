# Milestone 10: FreeRTOS Context-Switch Latency on Hardware

This milestone captures the first FreeRTOS context-switch latency measurement on
the Tang Nano 9K / PicoRV32 target, and compares it against the QEMU result from
the thesis. This closes the last open measurement item from the plan.

## Method

`2.sw/freertos_ctxbench.c` (`APP=freertos_ctxbench`) runs on the proven
UART-only top. It mirrors the thesis round-trip context-switch test
(`Thesis-RTOS-Analysis/.../test_context_switch.c`): one iteration is two
context switches (A -> B -> A), timed with the free-running 27 MHz hardware
counter `REG_TIMER_COUNT`.

Difference from the thesis: the thesis uses two equal-priority tasks sharing one
binary semaphore (yield-on-give is time-slicing dependent). This benchmark uses
two binary semaphores with the responder task B at higher priority, so every
give deterministically forces the measured switch. The measured quantity is the
same: round-trip context-switch cycles. Single-switch is the round-trip / 2.

```bash
make bitstream-freertos-ctxbench CROSS=riscv-none-elf- GOWIN=... GOWIN_ENV='...'
make flash-freertos-ctxbench
make serial   # or capture /dev/ttyUSB1 @ 115200
```

## Result (Hardware, PicoRV32 @ 27 MHz, 500 iterations)

From `0.doc/data/freertos_ctxbench_ttyUSB1_20260619_214202.log` (reproduced
identically across two flashes):

```text
metric,cycles,ns
ctxsw_roundtrip_min,7061,261518
ctxsw_roundtrip_avg,7079,262185
ctxsw_roundtrip_max,7982,295629
ctxsw_single_min,3530,130740
ctxsw_single_avg,3539,131074
```

- Round-trip context switch: **7061 / 7079 / 7982 cycles** (min/avg/max)
  = ~262 µs average at 27 MHz.
- Single context switch: **~3530 cycles (~131 µs)**.
- min, avg and max are within ~13 %, i.e. no scheduler-tick landed inside a
  measurement window (a 100 Hz tick is ~270000 cycles apart, far larger than one
  round trip), so the numbers are clean.

The per-switch cost is high in absolute cycles because PicoRV32 is a small
multi-cycle core (several clocks per instruction) clocked at only 27 MHz; the
context switch saves/restores the full integer register set plus the semaphore
give/take API overhead.

## Comparison with QEMU (thesis)

Thesis QEMU run (`context_run_4.log`, rv32 on QEMU virt, mcycle CSR, 25 MHz
assumed, 1000 iterations):

```text
Round-trip: Min 9188, Avg 23747, Max 3895040 cycles
Single (avg): 11873 cycles  -> 474.9 µs @ 25 MHz
```

| Metric | Hardware (PicoRV32 @27 MHz) | QEMU (thesis @25 MHz) |
|--------|-----------------------------|------------------------|
| Round-trip min | 7061 cycles | 9188 cycles |
| Round-trip avg | 7079 cycles | 23747 cycles |
| Round-trip max | 7982 cycles | 3895040 cycles |

Honest reading of the comparison:

- The two cycle counts are **not the same kind of cycle**: hardware uses a real
  27 MHz wall-clock counter, QEMU uses the emulated `mcycle` CSR, which is not
  cycle-accurate to silicon. So this compares the QEMU *model* against real
  hardware, not two identical clocks.
- The fairest point is the **minimum** (no tick/`vTaskDelay` interference):
  round-trip 7061 (HW) vs 9188 (QEMU) cycles -- the same order of magnitude, so
  QEMU is a reasonable first-order estimator of context-switch cost.
- The QEMU **average and max are dominated by scheduling noise** (the thesis
  test inserts `vTaskDelay(2 ms)` per iteration and its max is 3.9M cycles, a
  full scheduling stall). The hardware benchmark avoids this, which is why its
  avg is stable and close to its min.
- No claim of a clean "N times faster/slower" is made: the clock sources and
  averaging conditions differ. The defensible conclusion is that the measured
  hardware round-trip context switch (~7.1k cycles / ~262 µs) is consistent in
  magnitude with the QEMU model's clean-case estimate.

## Files

```text
2.sw/freertos_ctxbench.c
Makefile  (APP=freertos_ctxbench, bitstream/flash-freertos-ctxbench)
0.doc/data/freertos_ctxbench_ttyUSB1_20260619_214202.log
```
