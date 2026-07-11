# Milestone 3.6: HDMI Test Pattern

Ovaj korak testira HDMI izlaz bez CPU-a, firmware-a, UART-a, framebuffer-a i postojeće aplikacije.

Scope:

- Ne dodavati FreeRTOS.
- Ne koristiti `main.c`.
- Ne koristiti PicoRV32.
- Direktno generisati HDMI color-bar/checker sliku iz FPGA logike.

## Why

Milestone 3.5 je dokazao da postojeća aplikacija uđe u `main()`, izvrši `CharactersInit()` i `DisplayProjectName()`, te da CPU write-ovi prema video memory map-u ne blokiraju procesor.

Ali to ne dokazuje da monitor stvarno dobija ispravan HDMI signal.

Ovaj test razdvaja problem:

- ako se color-bar slika pojavi, HDMI output path radi;
- ako se slika ne pojavi, problem je u HDMI backendu, PLL-u, pinovima, kablu, adapteru ili monitor compatibility-ju.

## Files

```text
1.hw/src/top_hdmi_test.sv
1.hw/constraints/pinout_hdmi_test.cst
1.hw/tang_nano_9k_hdmi_test.gprj
1.hw/build_hdmi_test.tcl
Makefile
```

## What It Displays

Expected video output:

```text
1280x720p60 HDMI signal
vertical red / green / blue / white / yellow/cyan-style bars
32-pixel checker dimming overlay
```

LED behavior:

```text
LED0 -> board clock blink
LED1 -> HDMI PLL/reset status
LED2 -> frame/multi-frame activity blink
```

## Build

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'

make bitstream-hdmi GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Observed build result:

```text
Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/hdmi_test.fs" completed
```

## Flash

```bash
openFPGALoader -b tangnano9k 1.hw/impl/pnr/hdmi_test.fs
```

Expected:

```text
Load SRAM: 100.00%
CRC check: Success
```

## Success Criteria

Success:

- monitor detects a signal;
- visible color bars/checker pattern appears;
- LED0 blinks;
- LED1 indicates HDMI reset/PLL released;
- LED2 toggles based on HDMI frame activity.

Partial success:

- LEDs behave correctly, but monitor is blank.
- This suggests the FPGA logic is running, but HDMI electrical/timing/monitor compatibility still needs debugging.

Fail:

- no LEDs change and no image appears.
- This suggests the bitstream is not running, reset is held, or clocking is broken.

## If No Image Appears

Check:

1. HDMI cable is connected directly to the Tang Nano 9K HDMI connector.
2. Monitor input is set manually to HDMI.
3. Try another monitor or TV; some monitors are picky about FPGA HDMI/DVI signals.
4. Confirm LED0 blinks after flashing.
5. Confirm LED1/LED2 behavior.
6. Check whether the board needs reset via `S1` / `btnL`.

If HDMI test pattern does not work, do not debug the C app yet. First fix HDMI output.

If HDMI test pattern works, the next step is to reconnect the framebuffer/app display path.

## 640x480 Fallback Test

After the first 1280x720 HDMI test built and flashed successfully but produced no visible image, a second smaller diagnostic was added.

Reason:

- 1280x720p60 needs a much faster serial pixel clock.
- 640x480p60 is easier for the FPGA timing path and more likely to be accepted by older monitors.
- This keeps the test independent from CPU, firmware, UART and the TetriSaraj app.

Added files:

```text
1.hw/src/ip.hdmi/fpgatech_lib/GOWIN/fpga_pll_640.sv
1.hw/src/ip.hdmi/hdmi_backend_640.sv
1.hw/src/top_hdmi_640_test.sv
1.hw/tang_nano_9k_hdmi_640_test.gprj
1.hw/build_hdmi_640_test.tcl
Makefile
```

Build:

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'

make bitstream-hdmi-640 GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Observed build result:

```text
Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/hdmi_640_test.fs" completed
```

Flash:

```bash
openFPGALoader -b tangnano9k 1.hw/impl/pnr/hdmi_640_test.fs
```

Expected result:

- monitor detects a 640x480 style signal;
- visible color bars/checker pattern appears;
- LED0 blinks from the board clock;
- LED1 indicates HDMI PLL/reset released;
- LED2 toggles from frame activity.

If 640x480 works but 1280x720 does not, continue with the 640x480 backend first and treat 720p as future cleanup.

If 640x480 also does not work, the next debugging target is HDMI electrical/output compatibility, not the C application.
