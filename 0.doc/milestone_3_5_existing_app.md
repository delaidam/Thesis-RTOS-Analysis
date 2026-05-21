# Milestone 3.5: Existing Bare-Metal App Boot

Ovaj korak vraća se na postojeću TetriSaraj aplikaciju prije dodavanja FreeRTOS-a.

Scope:

- Ne dodavati FreeRTOS.
- Ne mijenjati game/application logiku.
- Pokrenuti postojeći `2.sw/main.c` preko starog HDMI/video top-levela.
- Dodati samo rani UART progress log da znamo gdje firmware staje ako nešto ne radi.

## Zašto Poseban Korak

Milestone 0-3 su koristili minimalni `top_uart_hello.v` sa UART/timer/IRQ dokazima.

Postojeća aplikacija ne može korektno raditi na tom minimalnom top-u jer očekuje drugi memory map:

```text
0x03000000 -> GPIO/buttons
0x05100000 -> video character RAM
0x05200000 -> video map RAM
```

Minimalni IRQ top koristi `0x03000000` za timer, pa direktno pokretanje `APP=main` na tom top-u pravi konflikt.

Zato se za postojeću aplikaciju koristi stari top:

```text
1.hw/src/top.v
```

## Files

Firmware:

```text
2.sw/main.c
2.sw/uart.c
2.sw/uart.h
```

Hardware:

```text
1.hw/src/top.v
1.hw/tang_nano_9k.gprj
1.hw/build_app.tcl
```

Build:

```text
Makefile
```

## Changes

`2.sw/main.c` sada na samom početku ispisuje:

```text
TetriSaraj bare-metal app boot
UART clkdiv=0x00000232
CharactersInit...
CharactersInit done
DisplayProjectName...
DisplayProjectName done
```

`UART clkdiv=0x000000EA` je `234`, što odgovara 115200 baud na dokazani `27 MHz` CPU/peripheral clock.

Prvi pokušaj sa starim PLL/app clockom od `64.8 MHz` nije dao UART output. Gowin synthesis report je pokazao da je taj clock prebrz za PicoRV32 dio dizajna:

```text
Required frequency: 64.800 MHz
Max frequency     : 43.448 MHz
```

Zato `top.v` sada za CPU/peripheral bus koristi direktni `clk_27`, isti clock koji je već prošao Milestone 1-3.

`1.hw/build_app.tcl` gradi puni app top:

```text
top module       -> top
Gowin project    -> tang_nano_9k.gprj
output bitstream -> tetrisaraj_app.fs
```

## Build

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'

make bitstream-app CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Observed firmware build:

```text
riscv-none-elf-size 2.sw/main.elf
text data bss dec hex filename
1916 0    12  1928 788 2.sw/main.elf

Bin file size: 1916 bytes
Wrote 1.hw/src/progmem.v with 479 words
```

Observed bitstream build:

```text
Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/tetrisaraj_app.fs" completed
```

## Flash

```bash
openFPGALoader -b tangnano9k 1.hw/impl/pnr/tetrisaraj_app.fs
```

Expected:

```text
Load SRAM: 100.00%
CRC check: Success
```

## Serial

If needed:

```bash
sudo chmod a+rw /dev/ttyUSB0 /dev/ttyUSB2
```

Open serial:

```bash
make serial SERIAL_PORT=/dev/ttyUSB2
```

Expected:

```text
TetriSaraj bare-metal app boot
UART clkdiv=0x000000EA
CharactersInit...
CharactersInit done
DisplayProjectName...
DisplayProjectName done
```

Observed hardware output:

```text
TetriSaraj bare-metal app boot
UART clkdiv=0x000000EA
CharactersInit...
CharactersInit done
DisplayProjectName...
DisplayProjectName done
```

In this run the UART appeared as `/dev/ttyUSB2`. Earlier runs used `/dev/ttyUSB1`; after reconnecting the board, Linux can renumber FTDI serial devices.

## HDMI

If HDMI is connected, the screen should show the current project-name screen drawn by `DisplayProjectName()`.

The full game loop in `main.c` is currently still commented out, so this milestone only proves:

- existing app firmware boots;
- UART works through the old app top;
- GPIO/video memory map does not immediately hang the CPU;
- character/video initialization and project-name drawing complete.

## If It Fails

If there is no UART output:

1. Confirm the app bitstream was flashed, not `uart_hello.fs`.
2. Press/release `S1` / `btnL`.
3. Check available ports with `ls -l /dev/ttyUSB* /dev/ttyACM*`; try `/dev/ttyUSB2`, then `/dev/ttyUSB1`, then `/dev/ttyUSB0`.
4. Confirm serial baud is `115200`.
5. Rebuild with `make bitstream-app ...` so `progmem.v` contains `APP=main`, not `irq_hello`.

If it prints `CharactersInit...` but not `CharactersInit done`, then the CPU likely stalls on video character RAM writes.

If it prints `DisplayProjectName...` but not `DisplayProjectName done`, then the CPU likely stalls on video map RAM writes.

If UART output is correct but HDMI is blank, the firmware boot is still proven. HDMI/debugging can be handled separately.

## Next Step

After this existing bare-metal app boot is verified on hardware, the next FreeRTOS step should be:

1. keep this app bitstream path;
2. add FreeRTOS as a separate firmware app first;
3. only then wrap a small part of the existing app in a FreeRTOS task.
