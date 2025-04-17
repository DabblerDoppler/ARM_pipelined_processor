# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "../src/alu.sv"
vlog "../src/adder.sv"
vlog "../src/bitwise_and.sv"
vlog "../src/bitwise_or.sv"
vlog "../src/bitwise_xor.sv"
vlog "../src/decoder.sv"
vlog "../src/full_adder.sv"
vlog "../src/zero_checker.sv"
vlog "../src/inverter.sv"
vlog "../src/mux_recursive.sv"
vlog "../src/mux2_1.sv"
vlog "../src/d_flipflop.sv"
vlog "../src/register_file.sv"
vlog "../src/dff_with_enable.sv"
vlog "../src/register.sv"
vlog "../cpu.sv"
vlog "../src/datamem.sv"
vlog "../src/instructmem.sv"
vlog "../src/sign_extend.sv"
vlog "../src/linear_shift_left.sv"
vlog "../src/linear_shift_right.sv"
vlog "../src/linear_shift_right_dynamic.sv"
vlog "../src/equality_checker.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_testbench

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
