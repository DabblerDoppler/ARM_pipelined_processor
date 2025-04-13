# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./alu.sv"
vlog "./adder.sv"
vlog "./bitwise_and.sv"
vlog "./bitwise_or.sv"
vlog "./bitwise_xor.sv"
vlog "./decoder.sv"
vlog "./full_adder.sv"
vlog "./zero_checker.sv"
vlog "./inverter.sv"
vlog "./mux_recursive.sv"
vlog "./mux2_1.sv"
vlog "./d_flipflop.sv"
vlog "./register_file.sv"
vlog "./dff_with_enable.sv"
vlog "./register.sv"
vlog "./cpu.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./sign_extend.sv"
vlog "./linear_shift_left.sv"
vlog "./linear_shift_right.sv"
vlog "./linear_shift_right_dynamic.sv"
vlog "./equality_checker.sv"


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
