PROJ_NAME=fw-flash
DEBUG=no
BENCH=no
MULDIV=no
COMPRESSED=no

SRCS = firmware.c rt_kernel.c rt_demo.c crt_flash.S

LDSCRIPT = ./linker_flash.ld

RISCV_NAME ?= riscv64-unknown-elf
RISCV_PATH ?= C:/SysGCC/risc-v

MABI=ilp32
MARCH := rv32i
ifeq ($(MULDIV),yes)
	MARCH := $(MARCH)m
endif
ifeq ($(COMPRESSED),yes)
	MARCH := $(MARCH)ac
endif

CFLAGS += -march=$(MARCH)  -mabi=$(MABI)  -ffunction-sections -fdata-sections
LDFLAGS += -march=$(MARCH)  -mabi=$(MABI)  -Wl,--gc-sections

ifeq ($(DEBUG),yes)
	CFLAGS += -g3 -O0
endif

ifeq ($(DEBUG),no)
	CFLAGS += -g -O3
endif

ifeq ($(BENCH),yes)
	CFLAGS += -fno-inline
endif

RISCV_CLIB=$(RISCV_PATH)/$(RISCV_NAME)/lib/$(MARCH)/$(MABI)/

RISCV_OBJCOPY = $(RISCV_PATH)/bin/$(RISCV_NAME)-objcopy.exe
RISCV_OBJDUMP = $(RISCV_PATH)/bin/$(RISCV_NAME)-objdump.exe
RISCV_CC = $(RISCV_PATH)/bin/$(RISCV_NAME)-gcc.exe

CFLAGS +=  -MD -fstrict-volatile-bitfields
LDFLAGS +=  -nostdlib -lgcc -mcmodel=medany -nostartfiles -ffreestanding -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(OBJDIR)/$(PROJ_NAME).map,--print-memory-usage

OBJDIR = build
OBJS := $(SRCS)
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.cpp=.o)
OBJS := $(OBJS:.S=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))

SUBOBJ := $(addprefix $(OBJDIR)/,$(SUBDIRS))
SUBOBJ := $(addsuffix /*.o,$(SUBOBJ))

export RISCV_CC CFLAGS LDFLAGS OBJDIR

all: $(SUBDIRS) $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).v

$(SUBDIRS): ECHO
	make -C $@

ECHO:
	@echo $(SUBDIRS)

$(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^ $(SUBOBJ) $(LDFLAGS) $(LIBS)

%.hex: %.elf
	$(RISCV_OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $^ $@

%.v: %.elf
	$(RISCV_OBJCOPY) -O verilog $^ $@

%.asm: %.elf
	$(RISCV_OBJDUMP) -S -d $^ > $@

$(OBJDIR)/%.o: %.c
	@if not exist build md build
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

$(OBJDIR)/%.o: %.cpp
	@if not exist build md build
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

$(OBJDIR)/%.o: %.S
	@if not exist build md build
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^ -D__ASSEMBLY__=1

$(OBJDIR):
	@if not exist build md build

clean:
	@if exist $(OBJDIR) rmdir /s /q $(OBJDIR)

.SECONDARY: $(OBJS)