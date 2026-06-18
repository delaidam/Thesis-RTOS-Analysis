# Milestone 5: FreeRTOS Boot on Tang Nano 9K

This is the milestone that all of Milestones 0–4 were building toward: the
**FreeRTOS kernel actually running on the PicoRV32 soft-core on the Tang Nano 9K**,
with a real scheduler tick, multiple tasks, preemption, blocking delays and a
mutex. Output is over the already-validated 115200 8N1 UART (HDMI is not
involved, so the unsolved HDMI display problem does not block this milestone).

Scope:

- Bring up the real FreeRTOS kernel (V10.5.1 = distribution V202212.00, the same
  version used in the QEMU thesis work).
- Custom PicoRV32 port (no standard RISC-V CSRs are available in this core).
- Three tasks: two equal-priority workers (preemptive time slicing) and one
  lower-priority heartbeat (runs only when the workers are blocked).
- Tick from the existing memory-mapped timer (irq_5), yield via a new software
  interrupt (irq_6).

## Status

- Firmware **builds and links** with `riscv-none-elf-gcc` (rv32im).
- Bitstream **synthesises, places, routes and generates** with Gowin EDA.
- Timing is met: synthesis reports `clk_27` Actual Fmax = **41.69 MHz**, well
  above the 27 MHz system clock.
- Hardware serial capture **passes** on Tang Nano 9K over `/dev/ttyUSB1` at
  115200 baud. The capture shows the FreeRTOS banner, two worker tasks, the
  heartbeat task and monotonically increasing scheduler ticks.
- Two bring-up bugs were fixed before the final proof:
  - `progmem.v` can become stale when switching `APP` values, so the Makefile
    now forces regeneration of the active program memory image.
  - `top_uart_hello` now includes a short internal power-on reset pulse, so the
    PicoRV32 core starts after SRAM configuration without relying on S1 timing.

Build sizes (2026-06-18, rv32im, `-Os`):

```text
text   data  bss   dec    hex   filename
17260  0     8492  25752  6498  2.sw/freertos_demo.elf
Bin file size: 17260 bytes
Wrote 1.hw/src/progmem.v with 4315 words
```

FPGA resource usage (GW1NR-9, Tang Nano 9K):

```text
Logic    4166/8640  49%
Register 1478/6693  23%
BSRAM    26/26      100%   (progmem 32 KB + data RAM 16 KB = 48 KB)
```

BSRAM is fully used: the 32 KB program ROM plus the 16 KB data RAM consume all
26 block-RAM tiles. It fits, but there is no spare block RAM for further growth
without rebalancing `progmem` (`MEM_SIZE_BITS`) or `MEM_WORDS`.

Hardware evidence captured on 2026-06-18:

```text
0.doc/data/freertos_por_sram_flash_20260618_181358.log
0.doc/data/freertos_por_capture_ttyUSB1_20260618_181358.log
0.doc/data/freertos_clean_sram_flash_20260618_181534.log
0.doc/data/freertos_clean_capture_ttyUSB1_20260618_181534.log
0.doc/data/freertos_clean_spi_flash_20260618_181842.log
```

The final clean capture contains:

```text
FreeRTOS V10.5.1 on PicoRV32 / Tang Nano 9K
tick = 100 Hz from timer IRQ5, yield via irq_6
creating tasks and starting scheduler...
[B] run=0x0000 tick=0x00000000
[A] run=0x0000 tick=0x00000000
[heartbeat] beat=0x0000 tick=0x00000000
```

## Why a Custom Port Was Needed

The standard FreeRTOS RISC-V port assumes the privileged CSR/trap model
(`mstatus`, `mtvec`, `mcause`, `mepc`, `mret`, `ecall`). This PicoRV32 instance
is configured with:

```text
ENABLE_IRQ(1)
ENABLE_IRQ_QREGS(0)
LATCHED_IRQ(0xffff_ffdf)   // irq_5 (timer) non-latched, others latched
PROGADDR_RESET = 0x00100000
PROGADDR_IRQ   = 0x00100004
```

In this mode PicoRV32 uses its own interrupt ABI instead of CSRs:

- on interrupt entry the core writes the **return PC into x3** and the **pending
  IRQ bitmap into x4**, then jumps to `PROGADDR_IRQ`;
- the custom `retirq` instruction returns to the address currently in **x3** and
  re-enables interrupts.

The context switch therefore works by writing the next task's saved PC into x3
before executing `retirq` — no CSRs and **no change to the CPU core** are needed.
Because the core overwrites x3 (gp) and x4 (tp) on every interrupt, the firmware
is built with `-mno-relax` and no TLS, so compiled C never relies on gp/tp.

## Tick and Yield

- **Tick**: the memory-mapped timer (proven in Milestones 2–3) is wired to
  `irq_5`. `xPortStartScheduler()` programs the period to
  `configCPU_CLOCK_HZ / configTICK_RATE_HZ = 27_000_000 / 100 = 270000` and the
  interrupt handler calls `xTaskIncrementTick()`.
- **Yield**: a new one-cycle software-interrupt register raises `irq_6`. Writing
  `1` to it makes `portYIELD()` (and `vTaskDelay`) switch immediately.

## Memory Map (additions)

```text
0x02000004 -> UART_CLKDIV
0x02000008 -> UART_DATA
0x03000000 -> TIMER_COUNT
0x03000004 -> TIMER_HZ (27000000)
0x03000008 -> TIMER_IRQ_ENABLE
0x0300000C -> TIMER_IRQ_PENDING (write 1 to clear)
0x03000010 -> TIMER_IRQ_PERIOD
0x0300001C -> SOFT_IRQ_TRIGGER   (NEW: write 1 -> pulse irq_6 = FreeRTOS yield)
```

## Files

Hardware (CPU core unchanged):

```text
1.hw/src/top_uart_hello.v          # added soft_irq irq_6 and internal POR reset
1.hw/src/ip.cpu/picosoc_noflash.v  # MEM_WORDS 1024 -> 4096 (16 KB data RAM)
```

Linker:

```text
2.sw/sections.lds                  # RAM LENGTH 0x1000 -> 0x4000
```

FreeRTOS kernel (downloaded, unmodified, V10.5.1):

```text
2.sw/freertos/tasks.c queue.c list.c
2.sw/freertos/include/*
2.sw/freertos/portable/MemMang/heap_4.c
```

Custom port + demo (new):

```text
2.sw/port/portmacro.h        # types, yield/critical macros
2.sw/port/port.c             # init stack, scheduler start, critical sections, C ISR
2.sw/port/portASM.S          # context save/restore, retirq, maskirq
2.sw/port/freertos_start.S   # reset + IRQ vectors, C-runtime init
2.sw/port/portmem.c          # freestanding memcpy/memset/memmove
2.sw/port/FreeRTOSConfig.h   # 27 MHz, 100 Hz tick, 8 KB heap
2.sw/freertos_demo.c         # 3-task demo
```

Build:

```text
Makefile                     # APP=freertos_demo branch + *-freertos targets,
                             # forced progmem.v regeneration for active APP
```

## Build

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='env -i HOME=/home/delaida PATH=/usr/local/bin:/usr/bin:/bin LD_PRELOAD=/lib64/libfreetype.so.6 QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM=offscreen'

# firmware only:
make firmware APP=freertos_demo CROSS=riscv-none-elf-

# firmware + bitstream:
make bitstream APP=freertos_demo CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

The bitstream is `1.hw/impl/pnr/uart_hello.fs` (it uses the `top_uart_hello`
top-level and `build.tcl`, same as Milestones 1–4).

## Flash

```bash
openFPGALoader --scan-usb
ls /dev/ttyUSB* /dev/ttyACM*
sudo chmod a+rw /dev/ttyUSB0 /dev/ttyUSB1     # if needed
openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs
```

Or in one step:

```bash
make flash-freertos CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Expected:

```text
Load SRAM: 100.00%
CRC check: Success
```

## Serial Verification

```bash
make serial SERIAL_PORT=/dev/ttyUSB1
```

(The FTDI port may renumber after reconnect — try `/dev/ttyUSB1`, then
`/dev/ttyUSB0`, then `/dev/ttyUSB2`.)

Expected output shape:

```text
FreeRTOS V10.5.1 on PicoRV32 / Tang Nano 9K
tick = 100 Hz from timer IRQ5, yield via irq_6
creating tasks and starting scheduler...
[A] run=0x0000 tick=0x........
[B] run=0x0000 tick=0x........
[A] run=0x0001 tick=0x........
[heartbeat] beat=0x0000 tick=0x........
[B] run=0x0001 tick=0x........
[A] run=0x0002 tick=0x........
...
```

For a one-shot proof capture around SRAM flashing:

```bash
timestamp=$(date +%Y%m%d_%H%M%S)
cap="0.doc/data/freertos_capture_ttyUSB1_${timestamp}.log"
flashlog="0.doc/data/freertos_sram_flash_${timestamp}.log"
(stty -F /dev/ttyUSB1 115200 raw -echo -crtscts && timeout 25s cat /dev/ttyUSB1 > "$cap") &
sleep 1
openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs > "$flashlog" 2>&1
wait
```

## Success Criteria

- The banner prints, then the scheduler starts (so `vTaskStartScheduler()` did
  not return — the kernel is running).
- `[A]` lines appear about every 500 ms, `[B]` lines about every 750 ms,
  `[heartbeat]` lines about every 1000 ms.
- `tick=` increases by ~50 between consecutive `[A]` lines (500 ms × 100 Hz),
  proving the timer IRQ drives the scheduler tick.
- Lines never interleave mid-string, proving the mutex and context switching work.
- LED0 keeps blinking (FPGA fabric alive).

## If It Fails

- **Banner prints, then nothing**: the scheduler started but the tick/yield IRQ
  is not switching. Check `top_uart_hello.v` has `.irq_6(soft_irq)` and that
  `0x0300001C` is decoded; check `vPortSetIrqMask` unmasks bits 5 and 6
  (`mask = 0xffffff9f`).
- **Banner does not print at all**: wrong bitstream flashed, or UART divider not
  set. Confirm `uart_hello.fs` was built from `APP=freertos_demo`
  (`progmem.v` should be ~4315 words). Confirm the Makefile regenerated
  `progmem.v` after switching `APP`. The top-level now includes an internal
  power-on reset pulse; pressing `S1`/`btnL` should no longer be required for
  normal SRAM load.
- **`ERROR: scheduler did not start (heap?)`**: out of heap — lower the task
  stack sizes in `freertos_demo.c` or `configTOTAL_HEAP_SIZE`.
- **Garbled / interleaved text**: UART divider mismatch (must be 234 for 27 MHz
  / 115200) or a context-switch corruption — re-check the save/restore offsets in
  `portASM.S` against `port.c`.

## Next Steps

With FreeRTOS proven on hardware, the natural follow-ups are:

1. Add the captured UART proof excerpt to the final presentation.
2. Measure context-switch / tick latency on hardware and compare to the QEMU
   numbers from the thesis.
3. Wrap a slice of the TetriSaraj game logic in a FreeRTOS task (UART/headless
   first), keeping the HDMI display as separate future work.
