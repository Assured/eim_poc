#=======================================================================
#
# Makefile
# --------
# Makefile for building the eim_poc.
# This requires OSS CAD Suite to be installed.
# https://github.com/YosysHQ/oss-cad-suite-build
#
#
# Copyright (C) 2024- Joachim Strömbergson
#
#=======================================================================

#-------------------------------------------------------------------
# Top module name ans source files.
#-------------------------------------------------------------------
TOPMODULE = eim_poc
PACKAGE   = CSFBGA285

# FPGA source files.
VERILOG_SRC_DIR = rtl
#VERILOG_SRC = \
#	$(VERILOG_SRC_DIR)/eim_poc.v \
#	$(VERILOG_SRC_DIR)/eim_arbiter.v \
#	$(VERILOG_SRC_DIR)/eim_arbiter_cdc.v \
#	$(VERILOG_SRC_DIR)/eim_cdc_bus_pulse.v \
#	$(VERILOG_SRC_DIR)/eim_da_phy.v \
#	$(VERILOG_SRC_DIR)/eim_indicator.v \
#	$(VERILOG_SRC_DIR)/eim_regs.v \
#	$(VERILOG_SRC_DIR)/clk_reset_gen.v


## For the wiring test
#VERILOG_SRC = \
#	$(VERILOG_SRC_DIR)/eim_wiring_test.v \
#	$(VERILOG_SRC_DIR)/clk_reset_gen.v

# For the minimal poc
VERILOG_SRC = \
	$(VERILOG_SRC_DIR)/eim_mini_poc.v \
	$(VERILOG_SRC_DIR)/clk_reset_gen.v


#-------------------------------------------------------------------
# Build everything.
#-------------------------------------------------------------------
all: eim_poc.dfu


#-------------------------------------------------------------------
# Verilog source linting.
#-------------------------------------------------------------------
LINT_TOOL = verilator

LINT_FLAGS = \
	+1364-2005ext+ \
	--lint-only \
	-Wall \
	-Wno-DECLFILENAME \
	-Wno-WIDTHEXPAND \
	-Wno-UNOPTFLAT \
	-Wno-GENUNNAMED

lint_src: $(VERILOG_SRC)
	$(LINT_TOOL) $(LINT_FLAGS) $^ >lint_issues.txt 2>&1 \
	&& { rm -f lint_issues.txt; exit 0; } \
	|| {   cat lint_issues.txt; exit 1; }
.PHONY: lint_src


#-------------------------------------------------------------------
# Main FPGA build flow.
# Synthesis. Place & Route. Bitstream generation.
#-------------------------------------------------------------------
eim_poc.dfu: fpga.bit
	cp fpga.bit eim_poc.dfu
	dfu-suffix -v 1209 -p 5af0 -a eim_poc.dfu


fpga.bit: fpga.config
	ecppack fpga.config fpga.bit


fpga.config: fpga.json
	nextpnr-ecp5 --85k --json $^ \
		--lpf config/eim_test.pcf \
		--top $(TOPMODULE) \
		--package $(PACKAGE) \
		--ignore-loops \
		--lpf-allow-unconstrained \
		--textcfg $@


fpga.json: $(VERILOG_SRC)
	yosys \
	-l synth.txt \
	-p 'read_verilog $^; synth_ecp5 -json $@'


#-------------------------------------------------------------------
# FPGA device programming.
#-------------------------------------------------------------------
dfu: eim_poc.dfu
	dfu-util --alt 0 -D $<


#-------------------------------------------------------------------
# Cleanup.
#-------------------------------------------------------------------
clean:
	rm -f fpga.json
	rm -f fpga.config
	rm -f fpga.bit
	rm -f fpga.dfu
	rm -f synth.txt


#-------------------------------------------------------------------
# Display info about targets.
#-------------------------------------------------------------------
help:
	@echo ""
	@echo "Build system for CrypTkey FPGA design and firmware."
	@echo ""
	@echo "Supported targets:"
	@echo "------------------"
	@echo "all                Build all targets."
	@echo "prog               Program the FPGA with the bitstream file."
	@echo "clean              Delete all generated files."

#=======================================================================
# EOF Makefile
#=======================================================================
