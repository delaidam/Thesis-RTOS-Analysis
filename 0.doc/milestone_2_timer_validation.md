# Milestone 2: Timer/Tick Validation

This document records the minimal timer validation step after the working UART hello-world proof.

Scope:

- Add a small memory-mapped hardware timer.
- Read the timer from bare-metal firmware.
- Print timer values over the already validated UART path.
- Do not add FreeRTOS yet.

## Status

Milestone 2 passed on hardware.

Observed serial output:

```text
Tang Nano 9K PicoRV32 timer validation
Timer count: 0x03000000
Timer Hz   : 0x03000004
timer_hz=0x019BFCC0
wait_ticks=0x002932E0
start=0x00052181 end=0x002E5482 delta=0x00293301
start=0x00301700 end=0x00594A01 delta=0x00293301
start=0x005B0C7F end=0x00843F80 delta=0x00293301
start=0x008601FE end=0x00AF34FF delta=0x00293301
start=0x00B0F77D end=0x00DA2A7E delta=0x00293301
```

`0x002932E0` is the requested wait interval.

`0x00293301` is 33 ticks larger, which is expected software overhead around leaving the wait loop and reading the timer again.

## Hardware Timer

The timer was added to the UART-only top-level:

```text
1.hw/src/top_uart_hello.v
```

The design still uses the stable direct `27 MHz` board clock.

Memory map:

```text
0x03000000 -> TIMER_COUNT, 32-bit incrementing counter
0x03000004 -> TIMER_HZ, constant 27000000
```

The counter increments once per `clk_27` cycle.

The UART remains mapped internally in `picosoc_noflash`:

```text
0x02000004 -> UART_CLKDIV
0x02000008 -> UART_DATA
```

## Firmware

Timer validation firmware:

```text
2.sw/timer_hello.c
```

It prints:

- timer register addresses;
- `timer_hz`;
- target wait ticks;
- repeated `start`, `end`, and `delta` values.

Expected values:

```text
timer_hz=0x019BFCC0
wait_ticks=0x002932E0
```

`0x019BFCC0` is `27000000`.

`0x002932E0` is `2700000`, approximately 100 ms at 27 MHz.

The printed `delta` should be close to `0x002932E0`. It may be slightly larger because software needs a few cycles to leave the wait loop and read the timer again.

## Build

Use the same Gowin environment as Milestone 0/1:

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'
```

Build timer firmware and bitstream:

```bash
make bitstream APP=timer_hello CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Observed firmware size:

```text
text data bss dec hex filename
868  0    0   868 364 2.sw/timer_hello.elf
Bin file size: 868 bytes
Wrote 1.hw/src/progmem.v with 217 words
```

Expected bitstream success:

```text
Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/uart_hello.fs" completed
```

## Flash

If `/dev/ttyUSB0` and `/dev/ttyUSB1` are missing, unplug and replug the Tang Nano 9K, then run:

```bash
openFPGALoader --scan-usb
ls /dev/ttyUSB* /dev/ttyACM*
```

Expected USB detection:

```text
FTDI2232 SIPEED FactoryAIOT Pro JTAG Debugger
/dev/ttyUSB0
/dev/ttyUSB1
```

Set temporary permissions:

```bash
sudo chmod a+rw /dev/ttyUSB1 /dev/ttyUSB0
```

Flash the already-built bitstream:

```bash
openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs
```

Expected flash success:

```text
Load SRAM: 100.00%
CRC check: Success
```

## Serial Verification

Open serial:

```bash
make serial SERIAL_PORT=/dev/ttyUSB1
```

Expected output shape:

```text
Tang Nano 9K PicoRV32 timer validation
Timer count: 0x03000000
Timer Hz   : 0x03000004
timer_hz=0x019BFCC0
wait_ticks=0x002932E0
start=0x........ end=0x........ delta=0x002932..
start=0x........ end=0x........ delta=0x002932..
```

Success criteria:

- UART output still works.
- LED0 still blinks.
- `timer_hz` reads as `0x019BFCC0`.
- `delta` is close to `0x002932E0`.
- `start` and `end` values keep increasing.

## If It Fails

If no serial output appears:

1. Press and release `S1` / `btnL`.
2. Confirm LED0 blinks.
3. Confirm `/dev/ttyUSB1` exists and has permission.
4. Try `make serial SERIAL_PORT=/dev/ttyUSB0` only if `/dev/ttyUSB1` stays blank.

If `openFPGALoader` fails with:

```text
open_device: failed to initialize ftdi
```

or:

```text
libusb_init_failed
```

then close any open serial terminal, unplug and replug the board, and run USB detection again.

## Next Step

After this timer read test works, Milestone 3 validates interrupt/trap handling.

Do not add FreeRTOS before:

- timer register read works;
- a timer interrupt can be generated;
- the PicoRV32 trap/IRQ path is proven with a tiny bare-metal handler.

The Milestone 3 implementation notes are in:

```text
0.doc/milestone_3_irq_validation.md
```
