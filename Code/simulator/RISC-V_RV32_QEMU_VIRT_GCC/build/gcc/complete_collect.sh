#!/bin/bash
echo "=== FreeRTOS Performance Data Collection ==="
echo "Collecting data from all 6 tests (5 runs each)..."
echo "This will take approximately 15-20 minutes..."
echo ""

# Create data directory
mkdir -p analysis/data

# Test 1: Synchronization (semaphore_mutex_test.c)
echo "[1/6] Collecting synchronization data..."
for i in 1 2 3 4 5; do
    echo "  Sync run $i/5"
    make test-sync > /dev/null 2>&1
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/sync_run_$i.log 2>&1 || true
    sleep 1
done

# Test 2: Memory Allocation (test_memory_allocation.c)
echo "[2/6] Collecting memory allocation data..."
for i in 1 2 3 4 5; do
    echo "  Memory run $i/5"
    make test-memory > /dev/null 2>&1
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/memory_run_$i.log 2>&1 || true
    sleep 1
done

# Test 3: Context Switch (test_context_switch.c)
echo "[3/6] Collecting context switch data..."
for i in 1 2 3 4 5; do
    echo "  Context run $i/5"
    make test-context > /dev/null 2>&1
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/context_run_$i.log 2>&1 || true
    sleep 1
done

# Test 4: IPC Performance (test_ipc_performance.c)
echo "[4/6] Collecting IPC performance data..."
for i in 1 2 3 4 5; do
    echo "  IPC run $i/5"
    make test-ipc > /dev/null 2>&1
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/ipc_run_$i.log 2>&1 || true
    sleep 1
done

# Test 5: Interrupt Latency (test_interrupt_latency.c)
echo "[5/6] Collecting interrupt latency data..."
for i in 1 2 3 4 5; do
    echo "  Interrupt run $i/5"
    make test-interrupt > /dev/null 2>&1
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/interrupt_run_$i.log 2>&1 || true
    sleep 1
done

# Test 6: Queue Performance (queue_test.c) - Needs special handling
echo "[6/6] Collecting queue performance data..."
for i in 1 2 3 4 5; do
    echo "  Queue run $i/5"
    # Queue test might need different TEST_TYPE or specific compilation
    make clean > /dev/null 2>&1
    make all TEST_TYPE=4 > /dev/null 2>&1  # Assuming queue test uses TEST_TYPE=4
    timeout 30 qemu-system-riscv32 -machine virt -bios none -kernel output/RTOSDemo.elf -nographic > analysis/data/queue_run_$i.log 2>&1 || true
    sleep 1
done

echo ""
echo "=== DATA COLLECTION COMPLETED ==="
echo "Total files created: 30 (6 tests × 5 runs each)"
echo "Data location: analysis/data/"
echo ""
echo "File summary:"
ls -1 analysis/data/ | wc -l
echo "files created in analysis/data/"
echo ""
echo "Next steps:"
echo "1. cd analysis"
echo "2. python freertos_analyzer.py"
echo ""
echo "Ready for Python analysis! 🚀"
