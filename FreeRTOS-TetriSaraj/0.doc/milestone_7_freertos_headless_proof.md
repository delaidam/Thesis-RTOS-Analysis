# Milestone 7: FreeRTOS Headless Game Proof on Hardware

This milestone closes the open item from Milestone 6: prove that the real
TetriSaraj game logic runs as FreeRTOS tasks on the Tang Nano 9K / PicoRV32
target. It deliberately avoids HDMI/video so it fits on the already-validated
UART-only top (`build.tcl` / `uart_hello.fs`), and renders the playfield as
ASCII over the 115200 8N1 UART instead.

## Status

- A new firmware app, `APP=freertos_game_headless`, builds with the existing
  custom PicoRV32 FreeRTOS port.
- It reuses the same game state machine (`2.sw/tetrisaraj_game.c`) as the video
  app, with no video/GPIO MMIO, so it is fabric-compatible with `freertos_demo`.
- Four FreeRTOS tasks run: `input` (synthesised buttons through a queue),
  `game` (advances the state machine), `render` (ASCII playfield over UART),
  and `debug` (score/lives/flags/tick status line).
- Built, flashed to SRAM, and captured on real hardware. UART shows the boot
  banner, the playfield rendering, a falling piece, a piece lock with a score
  increment, and a fresh piece spawn — all driven by the scheduler tick.
- The `freertos_game` (HDMI) app and bare-metal `main.c` paths are untouched.

## Firmware Build

Command:

```bash
make firmware APP=freertos_game_headless CROSS=riscv-none-elf-
```

Observed output:

```text
text   data  bss   dec    hex   filename
23520  0     9728  33248  81e0  2.sw/freertos_game_headless.elf
Bin file size: 23520 bytes
Wrote 1.hw/src/progmem.v with 5880 words
```

Memory budget (same SoC limits as the FreeRTOS port):

- Program image: 5880 / 8192 words used in the 32 KB `progmem` window
  (`MEM_SIZE_BITS = 13`), ~2312 words of headroom.
- RAM: `.bss` 9728 B (8 KB FreeRTOS heap + ~1.2 KB game state + misc) fits the
  16 KB PicoSoC RAM window with room for the system/interrupt stack.

## Hardware Proof

Bitstream uses the proven UART-only top (no HDMI), so the firmware is baked into
`progmem.v` and flashed to SRAM (volatile):

```bash
make bitstream-freertos-game-headless CROSS=riscv-none-elf- \
  GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh \
  GOWIN_ENV='env -i HOME=/home/delaida PATH=/usr/local/bin:/usr/bin:/bin LD_PRELOAD=/lib64/libfreetype.so.6 QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM=offscreen'

openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs   # CRC check: Success
```

Synthesis/PnR completed within the Tang Nano 9K resource limit (UART-only top),
unlike the combined FreeRTOS+HDMI top from Milestone 6.

Captured UART evidence (full log):

```text
0.doc/data/freertos_game_headless_capture_ttyUSB1_20260619_093325.log
```

Key excerpt:

```text
TetriSaraj FreeRTOS headless proof on PicoRV32 / Tang Nano 9K
game logic runs as FreeRTOS tasks, rendered as ASCII over UART
tick = 100 Hz from timer IRQ5, yield via irq_6

--- frame 0x0002  score=0x0000  lives=0x03
... (I piece falling) ...
[hb] beat=0x0002 tick=0x0000019C score=0x0000 lives=0x03 piece=0x00 state=0x00

--- frame 0x0003  score=0x0001  lives=0x03
... (piece locked, new O piece spawned, score area updated) ...
```

This demonstrates, on hardware:

- the FreeRTOS scheduler tick advancing (`tick` counter in the `[hb]` lines);
- multiple tasks cooperating through a queue and two mutexes without garbled UART;
- the actual TetriSaraj state machine progressing: piece spawn, gravity fall,
  lock, score increment (`score=0x0000 -> 0x0001`), and respawn.

The leading `[A]/[B]/[heartbeat]` lines in the capture are the previous
`freertos_demo` bitstream still running until the SRAM reload took effect; they
are expected and confirm the board was live before the new firmware booted.

## Files

Firmware:

```text
2.sw/freertos_game_headless.c   (new RTOS entrypoint, ASCII renderer)
2.sw/tetrisaraj_game.c          (added tetrisaraj_game_cell_at for headless render)
2.sw/tetrisaraj_game.h
Makefile                        (APP=freertos_game_headless build + targets)
```

Evidence:

```text
0.doc/data/freertos_game_headless_capture_ttyUSB1_20260619_093325.log
```

## Next Engineering Cut

With scheduler + game logic now proven on hardware, the remaining work is the
display path:

1. Reduce the combined FreeRTOS+HDMI footprint below the Tang Nano 9K limit
   (shrink character RAM / font representation, trim the CPU profile).
2. Reconnect `tetrisaraj_video_*` rendering to the proven task structure once the
   video top fits.
3. Optionally capture tick / context-switch latency now that a stable RTOS
   workload runs on the board, to compare against the QEMU/thesis numbers.
```

