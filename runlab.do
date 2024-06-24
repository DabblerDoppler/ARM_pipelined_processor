# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./alu.sv"
vlog "./adder.sv"
vlog "./bitwiseAnd.sv"
vlog "./bitwiseOr.sv"
vlog "./bitwiseXor.sv"
vlog "./decoder.sv"
vlog "./fullAdder.sv"
vlog "./zeroChecker.sv"
vlog "./inverter.sv"
vlog "./mux_recursive.sv"
vlog "./mux2_1.sv"
vlog "./D_FF.sv"
vlog "./regfile.sv"
vlog "./dff_with_enable.sv"
vlog "./register.sv"
vlog "./CPU.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./ImmExtender.sv"
vlog "./LinearShiftLeft.sv"
vlog "./LinearShiftRight.sv"
vlog "./LSR_64.sv"
vlog "./EqualityChecker_5.sv"
vlog "./dff_with_enable_resettoone.sv"
vlog "./DFF_ResetToOne.sv"
vlog "./register_resetToOne.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work CPU_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
