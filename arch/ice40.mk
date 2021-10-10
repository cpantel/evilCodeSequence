PNR     ?= nextpnr
PCF      = boards/$(BOARD).pcf
ifeq ($(SPEED),up)
FREQ_PLL = 16
else
ifeq ($(SPEED),hx)
FREQ_PLL = 36
else
FREQ_PLL = 48
endif
endif

ifeq ($(SEED),)
SEEDVAL =
else
SEEDVAL = --seed $(SEED)
endif

BUILD/progmem_syn.hex:
	icebram -g 32 2048 > $@

$(PLL):
	icepll $(QUIET) -i $(FREQ_OSC) -o $(FREQ_PLL) -m -f $@

ifeq ($(PNR),arachne-pnr)
$(ASC_SYN): $(BLIF) $(PCF)
	arachne-pnr $(QUIET) -d $(DEVICE) -P $(PACKAGE) -o $@ -p $(PCF) $<
else
$(ASC_SYN): $(JSON) $(PCF)
	nextpnr-ice40 $(QUIET) --$(SPEED)$(DEVICE) --package $(PACKAGE) $(SEEDVAL) --json $< --pcf $(PCF) --freq $(FREQ_PLL) --asc $@
endif

$(ASC): $(ASC_SYN) BUILD/progmem_syn.hex BUILD/progmem.hex
ifeq ($(PROGMEM),ram)
	icebram BUILD/progmem_syn.hex BUILD/progmem.hex < $< > $@
else
	cp $< $@
endif

$(BIN): $(ASC)
ifeq ($(PROGMEM),flash)
	icepack -s $< $@
else
	icepack $< $@
endif

$(TIME_RPT): $(ASC_SYN) $(PCF)
	icetime -t -m -d $(SPEED)$(DEVICE) -P $(PACKAGE) -p $(PCF) -c $(FREQ_PLL) -r $@ $<

$(STAT): $(ASC_SYN)
	icebox_stat $< > $@

flash: $(BIN) BUILD/progmem.bin $(TIME_RPT)
	iceprog $<
ifeq ($(PROGMEM),flash)
	iceprog -o 1M BUILD/progmem.bin
endif
