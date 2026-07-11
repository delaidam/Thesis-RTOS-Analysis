# Milestone 9: 640x480 Video Front-End Firmware

This milestone completes the firmware side of the combined FreeRTOS + HDMI port:
the video initialization now matches the 640x480 hardware from Milestone 8, so
the on-screen character tiles are written in the format the 640 back-end reads.

## What Changed

The on-screen map is always 40x30 mega-characters, so the game-state -> map
writes (`tetrisaraj_video_set_cell`, `tetrisaraj_video_clear`,
`tetrisaraj_video_show_project_name`) are identical for both resolutions. Only
the per-tile pixel resolution differs:

- 1280x720 back-end: 32x24 tiles (768 words/char, char RAM 12288 words)
- 640x480 back-end: 16x16 tiles (256 words/char, char RAM 4096 words)

`tetrisaraj_video_chars_init()` in `2.sw/tetrisaraj_platform.c` is now
parameterized by `VID_CHAR_W` / `VID_CHAR_H` and the right-edge bevel columns,
selected by the `TETRISARAJ_VIDEO_640` build define. The 640 app
(`APP=freertos_game_640`) passes `-DTETRISARAJ_VIDEO_640`; the default 1280 app
is unchanged.

Tile write index for 640: `REG_VIDEO_CHAR[z*256 + y*16 + x]`, which matches the
`hdmi_wrapper_640` read address `{map_rdata, y[3:0], x[3:0]}`.

## Build / Flash

```bash
make bitstream-freertos-game-640 CROSS=riscv-none-elf- \
  GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh \
  GOWIN_ENV='env -i HOME=/home/delaida PATH=/usr/local/bin:/usr/bin:/bin LD_PRELOAD=/lib64/libfreetype.so.6 QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM=offscreen'
make flash-freertos-game-640
```

Firmware stays within budget: text 15184 bytes (3796 words -> 8 pROM blocks),
bss 9724 bytes in 16 KB RAM. Resource usage unchanged from Milestone 8
(Logic 3348/8640 = 39%, BSRAM 22/26 = 85%).

## Hardware Result

SRAM load `CRC check: Success`. UART boot
(`0.doc/data/freertos_game_640_video16_boot_ttyUSB1_20260619_134949.log`):

```text
TetriSaraj FreeRTOS game app
tick=100Hz, input queue, game/render/debug tasks
video chars init...
[freertos_game] heartbeat=0x00000000 tick=0x00000001
video init done
[freertos_game] heartbeat=0x00000001 tick=0x000001F5
```

`video chars init...` followed by `video init done` confirms the adapted 16x16
character initialization ran to completion on hardware, and the heartbeat/tick
confirm the scheduler keeps running afterwards.

## Pending: On-Screen Visual Confirmation

The firmware now writes the correct 640x480 tile format, but the rendered HDMI
image itself can only be confirmed by looking at the connected display (there is
no UART read-back of video RAM). Outstanding visual checks on the monitor:

1. The project-name splash screen appears on power-up.
2. The play field, borders and centre wall render.
3. A falling tetromino, score area, and lives are visible and update.

If a tile color/scale looks off, the likely tuning points are the per-`z` color
values in `tetrisaraj_video_chars_init()` and the 16x16 bevel (top 2 rows /
right 2 columns). Capturing a photo of the screen would close this milestone.
