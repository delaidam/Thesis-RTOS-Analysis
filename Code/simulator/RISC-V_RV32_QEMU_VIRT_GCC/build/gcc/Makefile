# Simple FreeRTOS RISC-V Makefile for performance tests

OUTPUT_DIR := ./output
IMAGE := RTOSDemo.elf

# === TEST CONFIGURATION ===
TEST_TYPE ?= 3
ITERATIONS ?= 300
CPU_FREQ ?= 25

# Directories
FREERTOS_ROOT = ./../../../..
DEMO_PROJECT = $(FREERTOS_ROOT)/Demo/RISC-V_RV32_QEMU_VIRT_GCC

# Compiler setup
CC = riscv64-unknown-elf-gcc
LD = riscv64-unknown-elf-gcc
SIZE = riscv64-unknown-elf-size

# Compiler flags
MARCH = rv32imac
MABI = ilp32
MCMODEL = medlow

DEMO_ID ?= 0
CFLAGS = -march=$(MARCH) -mabi=$(MABI) -mcmodel=$(MCMODEL)
CFLAGS += -ffunction-sections -fdata-sections -fmessage-length=0
CFLAGS += -Wno-unused-parameter -nostartfiles -g3 -Os
CFLAGS += --specs=nano.specs -fno-builtin-printf
CFLAGS += -DSELECTED_TEST=$(TEST_TYPE) -DNUM_ITERATIONS=$(ITERATIONS) -DCPU_FREQ_MHZ=$(CPU_FREQ)
CFLAGS += -DDEMO_ID=$(DEMO_ID)

# Include directories
KERNEL_DIR = $(FREERTOS_ROOT)/Source
KERNEL_PORT_DIR = $(KERNEL_DIR)/portable/GCC/RISC-V

INCLUDES = -I$(DEMO_PROJECT)
INCLUDES += -I$(KERNEL_DIR)/include
INCLUDES += -I$(KERNEL_PORT_DIR)
INCLUDES += -I$(KERNEL_PORT_DIR)/chip_specific_extensions/RV32I_CLINT_no_extensions

CFLAGS += $(INCLUDES)

# Linker flags
LDFLAGS = -march=$(MARCH) -mabi=$(MABI) -mcmodel=$(MCMODEL)
LDFLAGS += -nostartfiles -Xlinker --gc-sections 
LDFLAGS += -Wl,-Map,$(OUTPUT_DIR)/RTOSDemo.map
LDFLAGS += -T./fake_rom.ld -Xlinker --defsym=__stack_size=352
LDFLAGS += -Wl,--start-group -Wl,--end-group

# Source files
# FreeRTOS kernel
KERNEL_SOURCES = $(KERNEL_DIR)/tasks.c
KERNEL_SOURCES += $(KERNEL_DIR)/list.c
KERNEL_SOURCES += $(KERNEL_DIR)/queue.c
KERNEL_SOURCES += $(KERNEL_DIR)/timers.c
KERNEL_SOURCES += $(KERNEL_DIR)/event_groups.c
KERNEL_SOURCES += $(KERNEL_DIR)/stream_buffer.c
KERNEL_SOURCES += $(KERNEL_DIR)/portable/MemMang/heap_4.c
KERNEL_SOURCES += $(KERNEL_DIR)/portable/GCC/RISC-V/port.c

# Application sources
APP_SOURCES = $(DEMO_PROJECT)/main.c
APP_SOURCES += $(DEMO_PROJECT)/test_manager.c
APP_SOURCES += $(DEMO_PROJECT)/riscv-virt.c
APP_SOURCES += $(DEMO_PROJECT)/ns16550.c
APP_SOURCES += $(DEMO_PROJECT)/scheduler_validation_demo.c
APP_SOURCES += $(DEMO_PROJECT)/queue_communication_demo.c
APP_SOURCES += $(DEMO_PROJECT)/interrupt_io_demo.c

# Test sources
TEST_SOURCES = $(DEMO_PROJECT)/test_context_switch.c
TEST_SOURCES += $(DEMO_PROJECT)/test_memory_allocation.c
TEST_SOURCES += $(DEMO_PROJECT)/semaphore_mutex_test.c
TEST_SOURCES += $(DEMO_PROJECT)/test_ipc_performance.c
TEST_SOURCES += $(DEMO_PROJECT)/test_interrupt_latency.c
TEST_SOURCES += $(DEMO_PROJECT)/test_suite.c
TEST_SOURCES += $(DEMO_PROJECT)/queue_test.c

# System sources
SYSTEM_SOURCES = ./printf-stdarg.c ./syscalls.c

# Assembly sources
ASM_SOURCES = ./start.S ./vector.S ./RegTest.S
ASM_SOURCES += $(KERNEL_DIR)/portable/GCC/RISC-V/portASM.S

# All sources
ALL_C_SOURCES = $(KERNEL_SOURCES) $(APP_SOURCES) $(TEST_SOURCES) $(SYSTEM_SOURCES)
ALL_ASM_SOURCES = $(ASM_SOURCES)

# Object files
C_OBJS = $(patsubst %.c,$(OUTPUT_DIR)/%.o,$(notdir $(ALL_C_SOURCES)))
ASM_OBJS = $(patsubst %.S,$(OUTPUT_DIR)/%.o,$(notdir $(ALL_ASM_SOURCES)))
ALL_OBJS = $(C_OBJS) $(ASM_OBJS)

# Create build directory
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Compilation rules
$(OUTPUT_DIR)/%.o: $(DEMO_PROJECT)/%.c | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: $(KERNEL_DIR)/%.c | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: $(KERNEL_DIR)/portable/GCC/RISC-V/%.c | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: $(KERNEL_DIR)/portable/MemMang/%.c | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: ./%.c | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: $(DEMO_PROJECT)/%.S | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: $(KERNEL_DIR)/portable/GCC/RISC-V/%.S | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTPUT_DIR)/%.o: ./%.S | $(OUTPUT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Main target
all: $(OUTPUT_DIR)/$(IMAGE)

$(OUTPUT_DIR)/$(IMAGE): $(ALL_OBJS)
	@echo ""
	@echo "--- Final linking ---"
	@echo ""
	$(LD) $(ALL_OBJS) $(LDFLAGS) -o $@
	$(SIZE) $@

# === TEST TARGETS ===

# Individual test targets
test-context: clean
	$(MAKE) all TEST_TYPE=1 ITERATIONS=500

test-memory: clean
	$(MAKE) all TEST_TYPE=2 ITERATIONS=200

test-sync: clean
	$(MAKE) all TEST_TYPE=3 ITERATIONS=300

test-ipc: clean
	$(MAKE) all TEST_TYPE=4 ITERATIONS=250

test-interrupt: clean
	$(MAKE) all TEST_TYPE=5 ITERATIONS=100

test-comprehensive: clean
	$(MAKE) all TEST_TYPE=6 ITERATIONS=100

# QEMU run targets
QEMU_CMD = qemu-system-riscv32 -machine virt -bios none -kernel $(OUTPUT_DIR)/$(IMAGE) -nographic -no-shutdown

run: $(OUTPUT_DIR)/$(IMAGE)
	$(QEMU_CMD)

run-with-log: $(OUTPUT_DIR)/$(IMAGE)
	@echo "Starting test with logging..."
	@mkdir -p results
	$(QEMU_CMD) > results/test_$(TEST_TYPE)_$(shell date +%Y%m%d_%H%M%S).log 2>&1 || true
	@echo "Test completed (or timed out after 30s)"

# Quick test targets (build and run)
quick-context:
	$(MAKE) test-context && $(MAKE) run-with-log TEST_TYPE=1

quick-memory:
	$(MAKE) test-memory && $(MAKE) run-with-log TEST_TYPE=2

quick-sync:
	$(MAKE) test-sync && $(MAKE) run-with-log TEST_TYPE=3

quick-ipc:
	$(MAKE) test-ipc && $(MAKE) run-with-log TEST_TYPE=4

quick-interrupt:
	$(MAKE) test-interrupt && $(MAKE) run-with-log TEST_TYPE=5

quick-comprehensive:
	$(MAKE) test-comprehensive && $(MAKE) run-with-log TEST_TYPE=6

# Batch testing
test-all:
	@echo "Running all performance tests..."
	@mkdir -p results
	$(MAKE) quick-context
	$(MAKE) quick-memory
	$(MAKE) quick-sync
	$(MAKE) quick-ipc
	$(MAKE) quick-interrupt

# Clean
clean:
	rm -f $(OUTPUT_DIR)/$(IMAGE) $(OUTPUT_DIR)/*.o $(OUTPUT_DIR)/*.d $(OUTPUT_DIR)/*.map

# Utility targets
size: $(OUTPUT_DIR)/$(IMAGE)
	$(SIZE) $(OUTPUT_DIR)/$(IMAGE)

print-%: ; @echo $* = $($*)

.PHONY: all clean run run-with-log size test-* quick-* test-all

# === COMPLETE DATA COLLECTION FOR ALL TESTS ===

# Collect synchronization data (semaphore_mutex_test.c)
collect-sync-data:
	@echo "Collecting synchronization data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "Sync run $$i/20"; \
	    $(MAKE) test-sync > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/sync_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	  done
	@echo "Sync data collection completed!"

# Collect memory allocation data (test_memory_allocation.c)
collect-memory-data:
	@echo "Collecting memory allocation data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "Memory run $$i/20"; \
	    $(MAKE) test-memory > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/memory_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	done
	@echo "Memory data collection completed!"

# Collect context switch data (test_context_switch.c)
collect-context-data:
	@echo "Collecting context switch data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "Context run $$i/20"; \
	    $(MAKE) test-context > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/context_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	done
	@echo "Context data collection completed!"

# Collect IPC data (test_ipc_performance.c)
collect-ipc-data:
	@echo "Collecting IPC data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "IPC run $$i/20"; \
	    $(MAKE) test-ipc > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/ipc_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	done
	@echo "IPC data collection completed!"

# Collect interrupt latency data (test_interrupt_latency.c)
collect-interrupt-data:
	@echo "Collecting interrupt latency data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "Interrupt run $$i/20"; \
	    $(MAKE) test-interrupt > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/interrupt_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	done
	@echo "Interrupt data collection completed!"

# Collect queue test data (queue_test.c)
collect-queue-data:
	@echo "Collecting queue performance data (20 runs)..."
	@mkdir -p analysis/data
	@for i in $$(seq 1 20); do \
	    echo "Queue run $$i/20"; \
	    $(MAKE) clean > /dev/null 2>&1; \
	    $(MAKE) all TEST_TYPE=4 > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/queue_run_$$i.log 2>&1 || true; \
	    sleep 2; \
	done
	@echo "Queue data collection completed!"

# Collect all data (complete dataset)
collect-all-data:
	@echo "=== COLLECTING ALL PERFORMANCE DATA ==="
	@echo "This will take approximately 1 hour..."
	@echo "Tests included: sync, memory, context, ipc, interrupt, queue"
	$(MAKE) collect-sync-data
	$(MAKE) collect-memory-data
	$(MAKE) collect-context-data
	$(MAKE) collect-ipc-data
	$(MAKE) collect-interrupt-data
	$(MAKE) collect-queue-data
	@echo "=== ALL DATA COLLECTION COMPLETED ==="
	@echo "Total runs: 120 (6 tests × 20 runs each)"
	@echo "Ready for Python analysis!"

# Quick data collection (5 runs each for testing)
collect-quick-data:
	@echo "Quick data collection (5 runs each)..."
	@mkdir -p analysis/data
	@echo "Collecting sync data..."
	@for i in 1 2 3 4 5; do \
	    $(MAKE) test-sync > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/sync_run_$$i.log 2>&1 || true; \
	done
	@echo "Collecting memory data..."
	@for i in 1 2 3 4 5; do \
	    $(MAKE) test-memory > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/memory_run_$$i.log 2>&1 || true; \
	done
	@echo "Collecting context data..."
	@for i in 1 2 3 4 5; do \
	    $(MAKE) test-context > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/context_run_$$i.log 2>&1 || true; \
	done
	@echo "Collecting IPC data..."
	@for i in 1 2 3 4 5; do \
	    $(MAKE) test-ipc > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/ipc_run_$$i.log 2>&1 || true; \
	done
	@echo "Collecting interrupt data..."
	@for i in 1 2 3 4 5; do \
	    $(MAKE) test-interrupt > /dev/null 2>&1; \
	    timeout 30 $(QEMU_CMD) > analysis/data/interrupt_run_$$i.log 2>&1 || true; \
	done
	@echo "Quick data collection completed!"
	@echo "Total runs: 25 (5 tests × 5 runs each)"

# Individual test verification
verify-context:
	@echo "Testing context switch test..."
	$(MAKE) test-context && timeout 10 $(QEMU_CMD)

verify-interrupt:
	@echo "Testing interrupt latency test..."
	$(MAKE) test-interrupt && timeout 10 $(QEMU_CMD)

verify-queue:
	@echo "Testing queue performance test..."
	$(MAKE) clean
	$(MAKE) all TEST_TYPE=4
	timeout 10 $(QEMU_CMD)

# Verification of all tests
verify-all-tests:
	@echo "=== VERIFYING ALL TESTS ==="
	@echo "Each test will run for 10 seconds..."
	$(MAKE) verify-context
	$(MAKE) verify-interrupt
	$(MAKE) verify-queue
	@echo "All tests verified!"

.PHONY: collect-sync-data collect-memory-data collect-context-data collect-ipc-data collect-interrupt-data collect-queue-data
.PHONY: collect-all-data collect-quick-data verify-context verify-interrupt verify-queue verify-all-tests

# === DEMO APPLICATION TARGETS ===

# Demo targets with proper dependency management
demo-scheduler: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=10"
	$(QEMU_CMD)

demo-queue: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=11"
	$(QEMU_CMD)

demo-interrupt: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=12"
	$(QEMU_CMD)

# Verification demos (shorter runs)
verify-demo-scheduler: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=10"
	timeout 15 $(QEMU_CMD) || true

verify-demo-queue: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=11"
	timeout 15 $(QEMU_CMD) || true

verify-demo-interrupt: clean
	$(MAKE) all CFLAGS+="-DDEMO_ID=12"
	timeout 15 $(QEMU_CMD) || true

.PHONY: demo-scheduler demo-queue demo-interrupt verify-demo-scheduler verify-demo-queue verify-demo-interrupt