# Milestone 6: FreeRTOS Game Port First Build

This milestone starts the actual TetriSaraj application migration from the
bare-metal `main.c` path to a FreeRTOS-hosted application.

## Status

- A new firmware app, `APP=freertos_game`, builds with the existing custom
  PicoRV32 FreeRTOS port.
- The old bare-metal `2.sw/main.c` path remains untouched as a reference.
- The game code is split into platform, game-state/update and RTOS entrypoint
  modules.
- The FreeRTOS game app creates separate input, game, render and debug tasks.
- Firmware size fits the current program and data memory assumptions.
- A first merged FreeRTOS plus HDMI hardware top was attempted, but Gowin
  synthesis exceeds the Tang Nano 9K logic limit.

## Firmware Build

Command:

```bash
make firmware APP=freertos_game CROSS=riscv-none-elf-
```

Observed output:

```text
text   data  bss   dec    hex   filename
22504  0     9724  32228  7de4  2.sw/freertos_game.elf
Bin file size: 22504 bytes
Wrote 1.hw/src/progmem.v with 5626 words
```

The firmware fits under the 32 KB `progmem` image and the 16 KB PicoSoC RAM
window used by the current FreeRTOS port.

## Hardware Attempt

Command:

```bash
make bitstream-freertos-game CROSS=riscv-none-elf- \
  GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh \
  GOWIN_ENV='env -i HOME=/home/delaida PATH=/usr/local/bin:/usr/bin:/bin LD_PRELOAD=/lib64/libfreetype.so.6 QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM=offscreen'
```

Result:

```text
ERROR (RP0006) : The number(16041(15559 LUTs, 482 ALUs, 0 ROM16s, 0 SSRAMs)) of logic in the design exceeds the resource limit(8640) of current device
```

A smaller PicoRV32 profile for the new video top was also attempted by disabling
compressed ISA, hardware division and the barrel shifter while keeping hardware
multiplication. This reduced the estimate from the first attempt, but not enough
for the Tang Nano 9K limit.

## Files

Firmware:

```text
2.sw/freertos_game.c
2.sw/tetrisaraj_game.c
2.sw/tetrisaraj_game.h
2.sw/tetrisaraj_platform.c
2.sw/tetrisaraj_platform.h
```

Hardware/build:

```text
1.hw/src/top_freertos_game.v
1.hw/build_freertos_game.tcl
1.hw/tang_nano_9k.gprj
Makefile
```

## Next Engineering Cut

The next step is not more C porting. The next step is reducing the hardware
footprint for the combined video plus FreeRTOS design. Practical options are:

1. Keep the FreeRTOS game headless on `top_uart_hello` for scheduler and game
   logic proof, then reconnect video after optimization.
2. Reduce video memory cost by shrinking character RAM, lowering the active
   character set or reusing a ROM/font representation.
3. Reduce CPU logic further only if the firmware can avoid the removed
   instructions or supplies the required software helpers.
4. Split the final claim: FreeRTOS game logic on hardware first, HDMI display
   integration second.
