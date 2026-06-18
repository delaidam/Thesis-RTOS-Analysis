SHELL := /bin/bash

CROSS ?= riscv64-unknown-elf-
CC := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump
SIZE := $(CROSS)size

APP ?= hello
SW_DIR := 2.sw
HW_DIR := 1.hw
BUILD_DIR := 3.build

FIRMWARE_ELF := $(SW_DIR)/$(APP).elf
FIRMWARE_BIN := $(SW_DIR)/$(APP).bin
FIRMWARE_MAP := $(SW_DIR)/$(APP).map
FIRMWARE_LDS := $(SW_DIR)/main.lds
FIRMWARE_DISASM := $(SW_DIR)/$(APP).disassembly.txt
PROGMEM_V := $(HW_DIR)/src/progmem.v
APP_SOURCES := $(SW_DIR)/$(APP).c
ASM_SOURCES := $(SW_DIR)/start.s

ifeq ($(APP),main)
APP_SOURCES += $(SW_DIR)/uart.c
endif

GOWIN ?= gw_sh
GOWIN_ENV ?=
GOWIN_PROJECT := $(HW_DIR)/tang_nano_9k_uart_hello.gprj
GOWIN_SCRIPT := build.tcl
BITSTREAM ?= $(HW_DIR)/impl/pnr/uart_hello.fs
APP_BITSTREAM ?= $(HW_DIR)/impl/pnr/tetrisaraj_app.fs
HDMI_TEST_BITSTREAM ?= $(HW_DIR)/impl/pnr/hdmi_test.fs
HDMI_640_TEST_BITSTREAM ?= $(HW_DIR)/impl/pnr/hdmi_640_test.fs

OPENFPGALOADER ?= openFPGALoader
BOARD ?= tangnano9k
SERIAL_PORT ?= /dev/ttyUSB1
UART_BAUD ?= 115200
UART_CLKDIV ?= 234

MARCH ?= rv32im
MABI ?= ilp32

CFLAGS ?= -Os
CFLAGS += -march=$(MARCH) -mabi=$(MABI)
CFLAGS += -ffreestanding -nostdlib -nostartfiles -fno-builtin
CFLAGS += -Wall -Wextra -Wno-main -DUART_CLKDIV=$(UART_CLKDIV)

LDFLAGS := -march=$(MARCH) -mabi=$(MABI)
LDFLAGS += -Wl,--build-id=none,-Bstatic,-T,$(FIRMWARE_LDS),-Map,$(FIRMWARE_MAP),--strip-debug

# ---- FreeRTOS build (APP=freertos_demo) -------------------------------------
# Custom PicoRV32 port. -mno-relax is required because PicoRV32 (QREGS=0)
# clobbers x3/x4 (gp/tp) on interrupt entry, so the firmware must not rely on
# the global pointer.
FREERTOS_DIR := $(SW_DIR)/freertos
PORT_DIR     := $(SW_DIR)/port
ifeq ($(APP),freertos_demo)
APP_SOURCES := $(SW_DIR)/freertos_demo.c $(SW_DIR)/uart.c \
               $(PORT_DIR)/port.c $(PORT_DIR)/portmem.c \
               $(FREERTOS_DIR)/tasks.c $(FREERTOS_DIR)/queue.c \
               $(FREERTOS_DIR)/list.c $(FREERTOS_DIR)/portable/MemMang/heap_4.c
ASM_SOURCES := $(PORT_DIR)/freertos_start.S $(PORT_DIR)/portASM.S
CFLAGS += -mno-relax -I$(PORT_DIR) -I$(SW_DIR) -I$(FREERTOS_DIR)/include
endif
ifeq ($(APP),freertos_game)
APP_SOURCES := $(SW_DIR)/freertos_game.c $(SW_DIR)/tetrisaraj_game.c \
               $(SW_DIR)/tetrisaraj_platform.c $(SW_DIR)/uart.c \
               $(PORT_DIR)/port.c $(PORT_DIR)/portmem.c \
               $(FREERTOS_DIR)/tasks.c $(FREERTOS_DIR)/queue.c \
               $(FREERTOS_DIR)/list.c $(FREERTOS_DIR)/portable/MemMang/heap_4.c
ASM_SOURCES := $(PORT_DIR)/freertos_start.S $(PORT_DIR)/portASM.S
CFLAGS += -mno-relax -I$(PORT_DIR) -I$(SW_DIR) -I$(FREERTOS_DIR)/include
endif

.PHONY: all firmware firmware-freertos firmware-freertos-game bitstream bitstream-app bitstream-freertos bitstream-freertos-game bitstream-hdmi bitstream-hdmi-640 flash flash-sram flash-app flash-freertos flash-freertos-game flash-hdmi flash-hdmi-640 flash-flash serial clean clean_fw clean_hw help FORCE

all: bitstream

firmware: $(PROGMEM_V)

$(FIRMWARE_LDS): $(SW_DIR)/sections.lds
	$(CC) -E -P -x c -o $@ $<

$(FIRMWARE_ELF): $(FIRMWARE_LDS) $(ASM_SOURCES) $(APP_SOURCES) Makefile
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(ASM_SOURCES) $(APP_SOURCES)
	$(SIZE) $@
	$(OBJDUMP) -d $@ > $(FIRMWARE_DISASM)

$(FIRMWARE_BIN): $(FIRMWARE_ELF)
	$(OBJCOPY) -O binary $< $@

$(PROGMEM_V): $(FIRMWARE_BIN) progmem.py FORCE
	python3 progmem.py $< $@

FORCE:

bitstream: firmware
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) $(GOWIN_SCRIPT)

bitstream-app:
	$(MAKE) firmware APP=main CROSS=$(CROSS) UART_CLKDIV=$(UART_CLKDIV)
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) build_app.tcl

firmware-freertos:
	$(MAKE) firmware APP=freertos_demo CROSS=$(CROSS) UART_CLKDIV=$(UART_CLKDIV)

firmware-freertos-game:
	$(MAKE) firmware APP=freertos_game CROSS=$(CROSS) UART_CLKDIV=$(UART_CLKDIV)

bitstream-freertos:
	$(MAKE) firmware APP=freertos_demo CROSS=$(CROSS) UART_CLKDIV=$(UART_CLKDIV)
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) $(GOWIN_SCRIPT)

bitstream-freertos-game:
	$(MAKE) firmware APP=freertos_game CROSS=$(CROSS) UART_CLKDIV=$(UART_CLKDIV)
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) build_freertos_game.tcl

flash-freertos: bitstream-freertos
	$(OPENFPGALOADER) -b $(BOARD) $(BITSTREAM)

flash-freertos-game: bitstream-freertos-game
	$(OPENFPGALOADER) -b $(BOARD) $(HW_DIR)/impl/pnr/freertos_game.fs

bitstream-hdmi:
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) build_hdmi_test.tcl

bitstream-hdmi-640:
	cd $(HW_DIR) && $(GOWIN_ENV) $(GOWIN) build_hdmi_640_test.tcl

flash flash-sram: bitstream
	$(OPENFPGALOADER) -b $(BOARD) $(BITSTREAM)

flash-app: bitstream-app
	$(OPENFPGALOADER) -b $(BOARD) $(APP_BITSTREAM)

flash-hdmi: bitstream-hdmi
	$(OPENFPGALOADER) -b $(BOARD) $(HDMI_TEST_BITSTREAM)

flash-hdmi-640: bitstream-hdmi-640
	$(OPENFPGALOADER) -b $(BOARD) $(HDMI_640_TEST_BITSTREAM)

flash-flash: bitstream
	$(OPENFPGALOADER) -b $(BOARD) -f $(BITSTREAM)

serial:
	python3 -m serial.tools.miniterm $(SERIAL_PORT) $(UART_BAUD)

clean: clean_fw clean_hw

clean_fw:
	rm -f $(FIRMWARE_ELF) $(FIRMWARE_BIN) $(FIRMWARE_MAP) $(FIRMWARE_DISASM) $(FIRMWARE_LDS)

clean_hw:
	rm -rf $(HW_DIR)/impl $(HW_DIR)/obj $(HW_DIR)/temp

help:
	@echo "Tang Nano 9K bare-metal build"
	@echo ""
	@echo "Firmware only:"
	@echo "  make firmware"
	@echo "  make firmware APP=timer_hello"
	@echo "  make firmware APP=irq_hello"
	@echo "  make firmware APP=poll_benchmark"
	@echo "  make firmware APP=irq_benchmark"
	@echo "  make firmware APP=irq_benchmark MARCH=rv32imc"
	@echo "  make firmware APP=freertos_game"
	@echo ""
	@echo "Gowin bitstream:"
	@echo "  make bitstream"
	@echo "  make bitstream APP=timer_hello"
	@echo "  make bitstream APP=irq_hello"
	@echo "  make bitstream APP=poll_benchmark"
	@echo "  make bitstream APP=irq_benchmark"
	@echo "  make bitstream-app"
	@echo "  make bitstream-freertos-game"
	@echo "  make bitstream-hdmi"
	@echo "  make bitstream-hdmi-640"
	@echo ""
	@echo "Flash SRAM:"
	@echo "  make flash"
	@echo "  make flash APP=timer_hello"
	@echo "  make flash APP=irq_hello"
	@echo "  make flash-app"
	@echo "  make flash-freertos-game"
	@echo "  make flash-hdmi"
	@echo "  make flash-hdmi-640"
	@echo ""
	@echo "Open serial:"
	@echo "  make serial SERIAL_PORT=/dev/ttyUSB1"
	@echo ""
	@echo "Optional: build the old game firmware instead of hello:"
	@echo "  make firmware APP=main"
