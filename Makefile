.DEFAULT_GOAL = all

BOARD    ?= edufpga
PROGRAM  ?= fulldemo
OPTLEVEL ?= -Os
QUIET    = -q
SEED     ?=
PLL      = BUILD/pll.sv
SRC      = $(sort $(wildcard hardware/*.sv) $(PLL))
TOP      = top
SV       = hardware/$(TOP).sv
YS       = arch/$(ARCH).ys
YS_ICE40 = `yosys-config --datdir/$(ARCH)/cells_sim.v`
BLIF     = BUILD/$(TOP).blif
JSON     = BUILD/$(TOP).json
ASC_SYN  = BUILD/$(TOP)_syn.asc
ASC      = BUILD/$(TOP).asc
BIN      = BUILD/$(TOP).bin
#SVF      = $(TOP).svf
TIME_RPT = $(TOP).rpt
STAT     = $(TOP).stat
C_SRC    = $(filter-out programs/uip/fsdata.c, $(wildcard programs/$(PROGRAM)/*.c))
OBJ      = $(sort $(addsuffix .o, $(basename $(C_SRC))) start.o)
TARGET  ?= riscv64-unknown-elf
AS       = $(TARGET)-as
ASFLAGS  = -march=rv32i -mabi=ilp32
LD       = $(TARGET)-gcc
LDFLAGS  = $(CFLAGS) -Wl,-TBUILD/progmem.lds
CC       = $(TARGET)-gcc
CFLAGS   = -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=$(FREQ_PLL)000000 $(OPTLEVEL) -ffreestanding -nostartfiles -g -Iprograms/$(PROGRAM)
OBJCOPY  = $(TARGET)-objcopy

include boards/$(BOARD).mk
include arch/$(ARCH).mk

.PHONY: all software hardware system clean syntax time stat flash

all: software hardware system

clean: clean_sw clean_hw clean_sys

clean_sw:
	$(RM) start.* BUILD/progmem BUILD/progmem.bin BUILD/progmem.lds BUILD/progmem.hex

clean_hw:
	$(RM) BUILD/defines.sv  BUILD/pll.sv BUILD/top.* BUILD/progmem_syn.hex BUILD/$(TOP).blif BUILD/$(TOP).json BUILD/$(TOP)_syn.asc BUILD/$(TOP).asc

clean_sys:
	$(RM) BUILD/$(TOP).bin

### SOFTWARE ###

software: BUILD/progmem.hex

BUILD/progmem.bin: BUILD/progmem
	$(OBJCOPY) -O binary $< $@

BUILD/progmem.hex: BUILD/progmem.bin
	xxd -p -c 4 < $< > $@

BUILD/progmem: $(OBJ) BUILD/progmem.lds
	$(LD) $(LDFLAGS) -o $@ $(OBJ)

start.s: start-$(PROGMEM).s
	cp $< $@

BUILD/progmem.lds: arch/$(ARCH)-$(PROGMEM).lds
	cp $< $@

### HARDWARE ###

hardware: $(ASC_SYN)

$(BLIF) $(JSON): $(YS) $(SRC) BUILD/progmem_syn.hex BUILD/defines.sv
	yosys $(QUIET) $<

syntax: $(SRC) BUILD/progmem_syn.hex BUILD/defines.sv
	iverilog -D$(shell echo $(ARCH) | tr 'a-z' 'A-Z') -Wall -t null -g2012 $(YS_ICE40) $(SV)

BUILD/defines.sv: boards/$(BOARD)-defines.sv
	cat boards/$(BOARD)-defines.sv programs/$(PROGRAM)/$(BOARD)-defines.sv > BUILD/defines.sv

time: $(TIME_RPT)
	cat $<

stat: $(STAT)
	cat $<

### SYSTEM ###

system: $(BIN)

