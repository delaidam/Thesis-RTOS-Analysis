# Milestone 0 and 1: Tang Nano 9K PicoRV32 UART Hello

This document records the first working hardware baseline for the Tang Nano 9K / PicoRV32 project.

Scope:

- Milestone 0: build and flash an existing/minimal bare-metal project.
- Milestone 1: print a UART hello-world message from the Tang Nano 9K.
- FreeRTOS is intentionally not included yet.

## Result

The UART hello-world proof works on hardware.

Observed serial output at `115200 8N1` on `/dev/ttyUSB1`:

```text
Tang Nano 9K PicoRV32 UART hello
UART base: 0x02000000
TX data : 0x02000008
hello counter=0x00000000
hello counter=0x00000001
hello counter=0x00000002
hello counter=0x00000003
hello counter=0x00000004
hello counter=0x00000005
hello counter=0x00000006
hello counter=0x00000007
```

This proves:

- the Tang Nano 9K can be detected over USB/JTAG;
- the FPGA bitstream can be generated with Gowin EDA on Fedora Linux;
- the bitstream can be flashed with `openFPGALoader`;
- the PicoRV32 system starts from generated `progmem.v`;
- the memory-mapped UART works;
- software addresses match the hardware memory map:
  - UART divider: `0x02000004`
  - UART data: `0x02000008`

## Host Setup

System used:

- Fedora Linux
- Gowin EDA Education Linux
- xPack RISC-V bare-metal GCC
- `openFPGALoader`
- Python `serial.tools.miniterm`

RISC-V compiler path:

```bash
export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
```

The compiler was verified with:

```bash
which riscv-none-elf-gcc
riscv-none-elf-gcc --version
```

Gowin command-line tool:

```bash
/home/delaida/opt/gowin/IDE/bin/gw_sh
```

Gowin needs this Fedora-specific environment:

```bash
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'
```

Do not put `LD_PRELOAD` globally in `~/.bashrc`; keep it scoped to Gowin through `GOWIN_ENV`.

## Hardware Detection

With the Tang Nano 9K connected over USB:

```bash
openFPGALoader --scan-usb
ls /dev/ttyUSB* /dev/ttyACM*
```

Working detection output:

```text
Bus device vid:pid       probe_type manufacturer serial          product
003 005    0x0403:0x6010 FTDI2232   SIPEED       FactoryAIOT Pro JTAG Debugger
/dev/ttyUSB0
/dev/ttyUSB1
```

For this board/setup:

- `/dev/ttyUSB0` is the JTAG side;
- `/dev/ttyUSB1` is the UART serial side.

Temporary serial permission fix:

```bash
sudo chmod a+rw /dev/ttyUSB1 /dev/ttyUSB0
```

Permanent fix:

```bash
sudo usermod -aG dialout $USER
```

Then log out and log back in. A new terminal alone is not enough if the login session has not refreshed groups.

## Files Added or Changed

Main build flow:

- `Makefile`
- `progmem.py`

Minimal firmware:

- `2.sw/hello.c`
- `2.sw/sections.lds`

UART-only hardware baseline:

- `1.hw/src/top_uart_hello.v`
- `1.hw/constraints/pinout_uart_hello.cst`
- `1.hw/tang_nano_9k_uart_hello.gprj`
- `1.hw/build.tcl`

UART hardware:

- `1.hw/src/ip.cpu/simpleuart.v`
- `1.hw/src/ip.cpu/picosoc_noflash.v`

Earlier full top-level wiring was also touched:

- `1.hw/src/top.v`
- `1.hw/constraints/pinout.cst`
- `1.hw/tang_nano_9k.gprj`

The final working hardware proof uses `top_uart_hello`, not the older HDMI/game top.

## Why UART-Only Top Was Needed

The first attempt used the larger existing HDMI/game top with the PicoRV32 clocked through the Gowin rPLL at about `64.8 MHz`.

The design built and flashed, but UART output was blank.

The synthesis report showed a timing risk for the `64.8 MHz` CPU clock. To reduce risk and prove the hardware path first, a smaller top-level was introduced:

- direct `27 MHz` board clock;
- no HDMI pipeline;
- no rPLL dependency;
- only PicoRV32, progmem, simple UART, reset, and LED blink.

For `27 MHz` and `115200` baud, the UART divider is:

```text
27000000 / 115200 ~= 234
```

The Makefile default is therefore:

```make
UART_CLKDIV ?= 234
```

## Build Commands

From the repository root:

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj
```

Firmware only:

```bash
make firmware CROSS=riscv-none-elf-
```

Expected firmware output:

```text
text data bss dec hex filename
644  0    0   644 284 2.sw/hello.elf
Bin file size: 644 bytes
Wrote 1.hw/src/progmem.v with 161 words
```

Bitstream:

```bash
make bitstream CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Expected bitstream success:

```text
Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/uart_hello.fs" completed
```

Check the bitstream:

```bash
ls -lh 1.hw/impl/pnr/uart_hello.fs
```

Expected:

```text
1.hw/impl/pnr/uart_hello.fs
```

## Flash Commands

Flash to SRAM:

```bash
make flash CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Expected flash output:

```text
openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs
Jtag frequency : requested 6.00MHz -> real 6.00MHz
Load SRAM: 100.00%
CRC check: Success
```

Optional persistent flash:

```bash
make flash-flash CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

For normal development, SRAM flashing is enough.

## Serial Command

Open serial:

```bash
make serial SERIAL_PORT=/dev/ttyUSB1
```

Exit miniterm:

```text
Ctrl+]
```

If serial is blank:

1. Press and release `S1` / `btnL`; it is used as reset.
2. Confirm LED0 blinks.
3. Confirm `/dev/ttyUSB1` permission.
4. Try `/dev/ttyUSB0` only if `/dev/ttyUSB1` is definitely blank.

## Hardware Indicators

In `top_uart_hello`:

- `btnL` is reset, active low through `resetn = btnL`;
- `led_n[0]` blinks from a counter, proving the FPGA clocked design is alive;
- `led_n[1]` mirrors `uart_tx`;
- `uart_tx` is constrained to pin `17`;
- `uart_rx` is constrained to pin `18`.

Working pin report confirmed:

```text
uart_tx -> 17/2 -> LVCMOS33
uart_rx -> 18/2 -> LVCMOS33
clk_27  -> 52/1 -> LVCMOS33
```

## Current Known-Good Flow

Use this after opening a new terminal:

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'

make bitstream CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
sudo chmod a+rw /dev/ttyUSB1 /dev/ttyUSB0
make flash CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
make serial SERIAL_PORT=/dev/ttyUSB1
```

## Next Step

The next step should be Milestone 2: timer/tick validation.

Do not add FreeRTOS yet.

Recommended next milestone:

1. Keep `top_uart_hello` as the stable baseline.
2. Add the smallest possible memory-mapped timer/counter peripheral.
3. Add a tiny bare-metal `timer_hello.c` or extend `hello.c` to read the timer.
4. Print timer values over UART.
5. Verify that the counter increments at the expected rate from the `27 MHz` clock.

Success criteria for Milestone 2:

```text
UART still prints reliably
LED still blinks
software can read a hardware timer register
printed timer deltas are plausible for the 27 MHz clock
```

Only after Milestone 2 and Milestone 3 interrupt/trap validation should FreeRTOS be attempted.

## Symposium Framing

This is a strong and honest improvement over the thesis baseline:

```text
A reproducible QEMU-based FreeRTOS analysis on RISC-V, extended with initial Tang Nano 9K hardware validation using a minimal PicoRV32 bare-metal UART proof.
```

Do not claim that FreeRTOS is running on FPGA yet.

Current validated claim:

```text
The Tang Nano 9K hardware toolchain and UART path were recovered and validated with a minimal bare-metal PicoRV32 program.
```

Next validated claim, after Milestone 2:

```text
The platform also exposes a working hardware timer suitable for future RTOS tick validation.
```
