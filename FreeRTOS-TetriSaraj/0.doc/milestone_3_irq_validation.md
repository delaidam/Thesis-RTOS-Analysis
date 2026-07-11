# Milestone 3: Interrupt/Trap Validation

Ovaj dokument opisuje najmanji test za provjeru interrupt/trap puta na Tang Nano 9K + PicoRV32 projektu.

Scope:

- Ne dodavati FreeRTOS.
- Ne portati benchmarke.
- Koristiti već potvrđeni UART iz Milestone 1.
- Koristiti već potvrđeni hardware timer iz Milestone 2.
- Dodati samo jedan timer interrupt i mali assembly handler.

## Status

Milestone 3 passed on hardware.

Build rezultat:

```text
text data bss dec hex filename
1220 0    8   1228 4cc 2.sw/irq_hello.elf

Bin file size: 1220 bytes
Wrote 1.hw/src/progmem.v with 305 words

Placement and routing completed
Bitstream generation completed
Generate file ".../1.hw/impl/pnr/uart_hello.fs" completed
```

Provjereni vektori iz disassembly-ja:

```text
00100000 <start>:
  j 100008 <reset_entry>

00100004 <irq_vector>:
  j 1000e4 <irq_entry>
```

To se poklapa sa PicoRV32 konfiguracijom:

```text
PROGADDR_RESET = 0x00100000
PROGADDR_IRQ   = 0x00100004
```

## Memory Map

UART ostaje isti:

```text
0x02000004 -> UART_CLKDIV
0x02000008 -> UART_DATA
```

Timer registri:

```text
0x03000000 -> TIMER_COUNT, 32-bit counter
0x03000004 -> TIMER_HZ, constant 27000000
0x03000008 -> TIMER_IRQ_ENABLE
0x0300000C -> TIMER_IRQ_PENDING, write 1 to clear
0x03000010 -> TIMER_IRQ_PERIOD
0x03000014 -> TIMER_IRQ_COUNTDOWN
```

Timer interrupt je spojen na PicoRV32 `irq_5`.

IRQ5 je konfigurisan kao nelatchovan u PicoRV32:

```text
LATCHED_IRQ = 0xffff_ffdf
```

Razlog: timer već ima vlastiti `TIMER_IRQ_PENDING` registar. Ako PicoRV32 dodatno latchuje level IRQ signal, jedan timer event se može vidjeti kao dva handler ulaska.

## Observed Hardware Output

Prvi hardware run je dokazao IRQ path:

```text
Tang Nano 9K PicoRV32 IRQ validation
Timer count       : 0x03000000
Timer IRQ enable  : 0x03000008
Timer IRQ pending : 0x0300000C
Timer IRQ period  : 0x03000010
timer_hz=0x019BFCC0
irq_period=0x002932E0
IRQ5 unmasked, waiting for timer interrupts...
irq_count=0x00000002 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x0033B809
irq_count=0x00000004 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x005CEB3F
irq_count=0x00000006 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x00861E83
```

This proves:

- PicoRV32 entered the IRQ vector.
- The pending bitmap was IRQ5: `0x00000020`.
- The handler cleared the hardware pending bit: `hw_pending=0x00000000`.

After this observation, IRQ5 was changed from latched to non-latched so one hardware timer event should produce one `irq_count` increment.

Finalni hardware run nakon `LATCHED_IRQ = 0xffff_ffdf` korekcije:

```text
Tang Nano 9K PicoRV32 IRQ validation
Timer count       : 0x03000000
Timer IRQ enable  : 0x03000008
Timer IRQ pending : 0x0300000C
Timer IRQ period  : 0x03000010
timer_hz=0x019BFCC0
irq_period=0x002932E0
IRQ5 unmasked, waiting for timer interrupts...
irq_count=0x00000001 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x0033B78A
irq_count=0x00000002 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x005CEABF
irq_count=0x00000003 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x00861E02
irq_count=0x00000004 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x00AF5137
irq_count=0x00000005 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x00D8847A
```

Final success criteria:

- `irq_count` increments by one per observed timer interrupt.
- `pending_seen=0x00000020`, so the CPU observed IRQ5.
- `hw_pending=0x00000000`, so the handler cleared the hardware timer interrupt.
- The firmware continues after each interrupt and keeps printing over UART.

## Files

Hardware:

```text
1.hw/src/top_uart_hello.v
1.hw/src/ip.cpu/picosoc_noflash.v
```

Firmware:

```text
2.sw/irq_hello.c
2.sw/start.s
2.sw/sections.lds
```

Build flow:

```text
Makefile
```

## Šta Test Radi

Firmware:

1. Inicijalizira UART na 115200 baud.
2. Ispiše adrese timer/IRQ registara.
3. Postavi timer IRQ period na `2700000` tickova, što je približno `100 ms` na `27 MHz`.
4. Očisti eventualni stari pending interrupt.
5. Unmaskira PicoRV32 IRQ5 pomoću `maskirq` custom instrukcije.
6. Uključi timer interrupt.
7. Čeka da assembly IRQ handler poveća `irq_count`.
8. Ispisuje `irq_count`, IRQ pending bitmap koji je handler vidio, hardware pending stanje i trenutni timer.

Assembly handler:

1. Sačuva privremene registre na stack.
2. Poveća globalni `irq_count`.
3. Snimi PicoRV32 pending IRQ bitmap iz registra `x4`.
4. Očisti hardware timer pending bit pisanjem `1` na `0x0300000C`.
5. Vrati registre.
6. Izvrši PicoRV32 `retirq` custom instrukciju.

## Build

```bash
cd ~/Desktop/TetriSaraj/FreeRTOS-TetriSaraj

export PATH=/home/delaida/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/15.2.0-1.1/.content/bin:$PATH
export GOWIN=/home/delaida/opt/gowin/IDE/bin/gw_sh
export GOWIN_ENV='XDG_CACHE_HOME=/tmp LD_PRELOAD=/usr/lib64/libfreetype.so.6 LD_LIBRARY_PATH=/home/delaida/opt/gowin/IDE/lib QT_QPA_PLATFORM=minimal QT_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt QT_QPA_PLATFORM_PLUGIN_PATH=/home/delaida/opt/gowin/IDE/plugins/qt/platforms QT_XCB_GL_INTEGRATION=none LIBGL_ALWAYS_SOFTWARE=1 QT_OPENGL=software QT_QUICK_BACKEND=software'

make bitstream APP=irq_hello CROSS=riscv-none-elf- GOWIN="$GOWIN" GOWIN_ENV="$GOWIN_ENV"
```

Expected:

```text
riscv-none-elf-size 2.sw/irq_hello.elf
text data bss dec hex filename
1220 0    8   1228 4cc 2.sw/irq_hello.elf

Placement and routing completed
Bitstream generation completed
```

## Flash

Prvo provjeri da Linux vidi pločicu:

```bash
openFPGALoader --scan-usb
ls /dev/ttyUSB* /dev/ttyACM*
```

Expected:

```text
FTDI2232 SIPEED FactoryAIOT Pro JTAG Debugger
/dev/ttyUSB0
/dev/ttyUSB1
```

Ako nema `/dev/ttyUSB0` i `/dev/ttyUSB1`, isključi i uključi USB kabl, pa ponovi provjeru.

Privremeno omogući serial pristup:

```bash
sudo chmod a+rw /dev/ttyUSB1 /dev/ttyUSB0
```

Ako se serial otvara samo preko `sudo`, trenutni shell vjerovatno još nije preuzeo `dialout` grupu. Dugoročno rješenje:

```bash
sudo usermod -aG dialout $USER
```

Zatim se potpuno odjaviti i prijaviti ponovo. Privremeno rješenje za trenutnu sesiju je `sudo chmod a+rw /dev/ttyUSB1 /dev/ttyUSB0`.

Flash u SRAM:

```bash
openFPGALoader -b tangnano9k 1.hw/impl/pnr/uart_hello.fs
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

Expected output:

```text
Tang Nano 9K PicoRV32 IRQ validation
Timer count       : 0x03000000
Timer IRQ enable  : 0x03000008
Timer IRQ pending : 0x0300000C
Timer IRQ period  : 0x03000010
timer_hz=0x019BFCC0
irq_period=0x002932E0
IRQ5 unmasked, waiting for timer interrupts...
irq_count=0x00000001 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x........
irq_count=0x00000002 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x........
irq_count=0x00000003 pending_seen=0x00000020 hw_pending=0x00000000 timer=0x........
```

Success criteria:

- UART output se pojavljuje.
- `irq_count` raste.
- `pending_seen=0x00000020`, jer je IRQ5 bit `1 << 5`.
- `hw_pending=0x00000000` nakon handlera, što znači da handler čisti interrupt.
- `timer=0x........` nastavlja rasti.

## If It Fails

Ako stane na:

```text
IRQ5 unmasked, waiting for timer interrupts...
```

onda UART i firmware rade, ali IRQ path ne radi. Provjeriti:

- da je u `1.hw/src/ip.cpu/picosoc_noflash.v` `PROGADDR_IRQ` postavljen na `32'h0010_0004`;
- da je u `1.hw/src/top_uart_hello.v` `.irq_5(timer_irq_pending)`;
- da `REG_TIMER_IRQ_ENABLE` i `REG_TIMER_IRQ_PENDING` adrese u `2.sw/irq_hello.c` odgovaraju hardware mapiranju;
- da `2.sw/sections.lds` ima `KEEP(*(.text.start))` prije ostalog `.text`;
- da `2.sw/irq_hello.disassembly.txt` pokazuje `irq_vector` na `0x00100004`.

Ako `pending_seen` nije `0x00000020`, onda PicoRV32 ne vidi očekivani IRQ bit.

Ako `hw_pending` ostaje `0x00000001`, handler ulazi u interrupt, ali clear write na `0x0300000C` ne radi.

Ako nema nikakvog serial outputa:

1. Pritisni i pusti `S1` / `btnL`.
2. Provjeri da LED0 blinka.
3. Provjeri da je flash prošao sa `CRC check: Success`.
4. Probaj `make serial SERIAL_PORT=/dev/ttyUSB0` samo ako `/dev/ttyUSB1` ostane prazan.

## Next Step

Tek kada Milestone 3 na UART-u pokaže rastući `irq_count`, ima smisla ići na Milestone 4: minimalni FreeRTOS boot.

Za sada je cilj samo dokazati:

- timer može generisati interrupt;
- PicoRV32 ulazi u IRQ vektor;
- handler se vrati nazad u glavni program;
- hardware pending bit se pouzdano čisti.
