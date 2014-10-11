# Uncomment the appropriate line to set the desired checkpoint
# This variable customizes the compilation of the Verilog for each checkpoint
CS150_CHKPNT := CS150_CHKPNT_1
#CS150_CHKPNT := CS150_CHKPNT_2
#CS150_CHKPNT := CS150_CHKPNT_3

# Set the processor clock speed (in MHz) here.
# Uncomment the appropriate line to set the desired speed.
# These are the only 2 speeds supported.
RISCV_CLK := RISCV_CLK_100
#RISCV_CLK := RISCV_CLK_50

# Set a flag if checkpoint 2 or 3 is enabled. Do not change these lines.
ifeq ($(CS150_CHKPNT), CS150_CHKPNT_2)
    CS150_CHKPNT += CS150_CHKPNT_2_OR_3
endif
ifeq ($(CS150_CHKPNT), CS150_CHKPNT_3)
    CS150_CHKPNT += CS150_CHKPNT_2_OR_3
endif

# Set the project name and directories
TOP := ml505top
SRC := src
TEMPLATES := cfg

TARGETS = all synth xst map par timing bitgen impact report schematic schem ise

BUILDDIR := build/$(TOP)
MAKEFILE := $(BUILDDIR)/Makefile
MAKEARGS := TOP=$(TOP) SRC=../../$(SRC) TEMPLATES=../../$(TEMPLATES) \
            CS150_CHKPNT="$(CS150_CHKPNT)" RISCV_CLK=$(RISCV_CLK)

$(TARGETS): $(MAKEFILE)
	$(MAKE) $@ -C $(BUILDDIR) $(MAKEARGS)

$(MAKEFILE): cfg/Makefile
	mkdir -p build/$(TOP)
	cp $< $@

clean:
	rm -rf build

.PHONY := $(TARGETS) clean
