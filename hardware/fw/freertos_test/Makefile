# Makefile za FreeRTOS + PicoRV32 + Tang Nano 9K BRAM
# Generiše .mem fajl za BRAM inicijalizaciju

# Tools
GCC_PREFIX = riscv64-unknown-elf-
CC = $(GCC_PREFIX)gcc
OBJCOPY = $(GCC_PREFIX)objcopy
OBJDUMP = $(GCC_PREFIX)objdump
SIZE = $(GCC_PREFIX)size

# FreeRTOS paths
FREERTOS_DIR = FreeRTOS/Source
FREERTOS_PORT_DIR = $(FREERTOS_DIR)/portable/GCC/RISC-V

# Build directory
BUILD_DIR = build_bram

# Compiler flags optimized for BRAM execution
CFLAGS = -march=rv32i -mabi=ilp32 \
         -ffunction-sections -fdata-sections \
         -g -Os -Wall \
         -fno-builtin-printf \
         -ffreestanding -nostdlib

# Include paths
INCLUDES = -I. \
           -I$(FREERTOS_DIR)/include \
           -I$(FREERTOS_PORT_DIR)

# Linker flags for BRAM memory layout
LDFLAGS = -march=rv32i -mabi=ilp32 \
          -Wl,--gc-sections \
          -Wl,-Map,$(BUILD_DIR)/firmware.map \
          -nostdlib -lgcc \
          -T linker_bram.ld

# Source files
FREERTOS_SRC = \
    $(FREERTOS_DIR)/tasks.c \
    $(FREERTOS_DIR)/queue.c \
    $(FREERTOS_DIR)/list.c \
    $(FREERTOS_DIR)/timers.c \
    $(FREERTOS_DIR)/event_groups.c \
    $(FREERTOS_DIR)/stream_buffer.c \
    $(FREERTOS_DIR)/portable/MemMang/heap_4.c \
    $(FREERTOS_PORT_DIR)/port.c

SOURCES = main.c startup.S memory.c $(FREERTOS_SRC)

# Object files
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(SOURCES))) \
          $(patsubst %.S,$(BUILD_DIR)/%.o,$(filter %.S,$(SOURCES)))

# Target names
TARGET = freertos_tang_nano
ELF_FILE = $(BUILD_DIR)/$(TARGET).elf
HEX_FILE = $(BUILD_DIR)/$(TARGET).hex
MEM_FILE = $(BUILD_DIR)/$(TARGET).mem
BIN_FILE = $(BUILD_DIR)/$(TARGET).bin
MAP_FILE = $(BUILD_DIR)/$(TARGET).map
ASM_FILE = $(BUILD_DIR)/$(TARGET).asm

# Default target
all: $(MEM_FILE) $(HEX_FILE) $(ASM_FILE) size

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(FREERTOS_DIR)
	mkdir -p $(BUILD_DIR)/$(FREERTOS_PORT_DIR)
	mkdir -p $(BUILD_DIR)/$(FREERTOS_DIR)/portable/MemMang

# Compile C files
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Compile assembly files
$(BUILD_DIR)/%.o: %.S | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Link
$(ELF_FILE): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

# Generate binary
$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@

# Generate Intel HEX
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Generate memory file for BRAM initialization
$(MEM_FILE): $(BIN_FILE)
	xxd -p -c 4 -g 4 $< | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@
	@echo "Generated $(MEM_FILE) for BRAM initialization"
	@echo "Copy this file to your FPGA project and use it to initialize BRAM"

# Generate assembly listing
$(ASM_FILE): $(ELF_FILE)
	$(OBJDUMP) -S $< > $@

# Show size information
size: $(ELF_FILE)
	@echo "\n=== Memory Usage Report ==="
	$(SIZE) $<
	@echo "==========================="
	@echo "BRAM Usage:"
	@stat -c%s $(BIN_FILE) | awk '{print "Firmware size: " $$1 " bytes (" $$1/1024 " KB)"}'
	@stat -c%s $(BIN_FILE) | awk '{print "BRAM usage: " $$1/1024/30*100 "% of 30KB available"}'

# Clean
clean:
	rm -rf $(BUILD_DIR)

# Help
help:
	@echo "Usage:"
	@echo "  make all     - Build everything"
	@echo "  make clean   - Clean build files"
	@echo "  make size    - Show memory usage"
	@echo ""
	@echo "Generated files:"
	@echo "  $(MEM_FILE) - Memory file for BRAM (use this in FPGA project)"
	@echo "  $(HEX_FILE) - Intel HEX format"
	@echo "  $(ASM_FILE) - Assembly listing for debug"

.PHONY: all clean size help