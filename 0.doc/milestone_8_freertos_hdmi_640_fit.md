# Milestone 8: Combined FreeRTOS + HDMI Fits the Tang Nano 9K (640x480)

This milestone resolves the Milestone 6 blocker: the combined FreeRTOS + HDMI
top now fits the Tang Nano 9K and boots on hardware. Milestone 6 overflowed the
device (16041 logic vs 8640 limit) because the design ran out of BSRAM and the
synthesizer pushed the memories into LUT/registers.

## Root Cause (from synthesis reports)

The UART-only build already used **BSRAM 26/26 (100%)**:

- `pROM = 16` blocks for the 8192-word program ROM (`progmem.v`),
- `SP   = 8`  blocks for the 16 KB PicoSoC data RAM,
- `SDPB = 2`  blocks for the UART.

So there was **zero BSRAM left** for the video character/map RAM. Adding the
1280x720 video (character RAM = 12288 words) forced ~13 memory blocks into
LUT/register fabric, which is the resource explosion seen in Milestone 6.

One Gowin pROM/BSRAM block = 512 words x 32 bit (16 Kbit). Gowin only infers
BSRAM cleanly for **power-of-two** memory depths; non-power-of-two depths fall
back to flip-flops (an early experiment with a 6144-word ROM produced an
18910-DFF overflow). The fix therefore keeps every memory depth power-of-two.

## Two Levers That Made It Fit

1. **Shrink the program ROM via `--gc-sections`.** The firmware linked every
   FreeRTOS function whether used or not. Building with
   `-ffunction-sections -fdata-sections` + `-Wl,--gc-sections` drops the unused
   kernel functions: firmware text went from 22680 to 15216 bytes (5670 -> 3804
   words). `progmem.py` now sizes the ROM to the smallest power-of-two word
   depth, so a sub-16 KB firmware claims **8 pROM blocks instead of 16**.

2. **Use the 640x480 video path.** A new `hdmi_wrapper_640` + `vga_ram_640`
   shrink the character RAM from 12288 to 4096 words (16x16 instead of 24x32
   characters), using the existing `hdmi_backend_640`.

## Result

Build:

```bash
make bitstream-freertos-game-640 CROSS=riscv-none-elf- \
  GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh \
  GOWIN_ENV='env -i HOME=/home/delaida PATH=/usr/local/bin:/usr/bin:/bin LD_PRELOAD=/lib64/libfreetype.so.6 QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM=offscreen'
```

Resource usage (`0.doc/data/freertos_game_640_resource_20260619_100845.txt`):

```text
Logic     | 3348/8640 | 39%   (was 16041 -> overflow)
Register  | 1349/6693 | 21%
BSRAM     | 22/26     | 85%
  --SP    | 8         (data RAM)
  --SDPB  | 6         (video char + map RAM + UART)
  --pROM  | 8         (program ROM, was 16)
```

Hardware boot (`0.doc/data/freertos_game_640_boot_ttyUSB1_20260619_100845.log`):
SRAM load returned `CRC check: Success`, and UART shows the combined top booting
and the FreeRTOS scheduler running on the new fabric:

```text
TetriSaraj FreeRTOS game app
tick=100Hz, input queue, game/render/debug tasks
video chars init...
[freertos_game] heartbeat=0x00000000 tick=0x00000001
video init done
[freertos_game] heartbeat=0x00000001 tick=0x000001F5
```

So the combined FreeRTOS + HDMI design now fits the Tang Nano 9K with margin
(22/26 BSRAM, 39% logic) and boots on real hardware with the scheduler alive.

## Files

```text
1.hw/src/ip.vga/vga_ram_640.v                  (4096-word character RAM)
1.hw/src/ip.hdmi/hdmi_wrapper_640.sv           (640x480 video front-end)
1.hw/src/top_freertos_game_640.v               (combined top, power-of-two mems)
1.hw/tang_nano_9k_freertos_game_640.gprj
1.hw/build_freertos_game_640.tcl
progmem.py                                     (power-of-two ROM sizing)
Makefile                                        (APP=freertos_game_640, gc-sections)
0.doc/data/freertos_game_640_resource_20260619_100845.txt
0.doc/data/freertos_game_640_boot_ttyUSB1_20260619_100845.log
```

## Not Yet Done (next sub-step)

The bitstream fits and boots, but the **HDMI image is not yet correct**: the
firmware video init (`tetrisaraj_platform.c`) still writes 24x32 (1280x720)
character data, while the 640 top expects 16x16 characters and the 640 address
map. The next step is to adapt the video front-end firmware to the 640x480
character format (glyphs, project-name and score coordinates) and capture a
photo of the rendered game on the HDMI display.
