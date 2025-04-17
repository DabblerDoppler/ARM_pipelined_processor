onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Input Logic}
add wave -noupdate /cpu_testbench/dut/clock
add wave -noupdate /cpu_testbench/dut/reset
add wave -noupdate -divider {Instruction Logic}
add wave -noupdate -radix unsigned /cpu_testbench/dut/program_counter
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instruction
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instruction_temp
add wave -noupdate /cpu_testbench/dut/current_instruction
add wave -noupdate /cpu_testbench/dut/rf_imm_12
add wave -noupdate -divider {ALU Logic}
add wave -noupdate -radix decimal /cpu_testbench/dut/rf_a_input
add wave -noupdate -radix decimal /cpu_testbench/dut/rf_b_input
add wave -noupdate -radix decimal /cpu_testbench/dut/rf_a_out
add wave -noupdate -radix decimal /cpu_testbench/dut/rf_b_out
add wave -noupdate /cpu_testbench/dut/alu_op
add wave -noupdate /cpu_testbench/dut/alu_src
add wave -noupdate -radix decimal /cpu_testbench/dut/alu_b_input
add wave -noupdate -radix decimal -childformat {{{/cpu_testbench/dut/alu_result[63]} -radix decimal} {{/cpu_testbench/dut/alu_result[62]} -radix decimal} {{/cpu_testbench/dut/alu_result[61]} -radix decimal} {{/cpu_testbench/dut/alu_result[60]} -radix decimal} {{/cpu_testbench/dut/alu_result[59]} -radix decimal} {{/cpu_testbench/dut/alu_result[58]} -radix decimal} {{/cpu_testbench/dut/alu_result[57]} -radix decimal} {{/cpu_testbench/dut/alu_result[56]} -radix decimal} {{/cpu_testbench/dut/alu_result[55]} -radix decimal} {{/cpu_testbench/dut/alu_result[54]} -radix decimal} {{/cpu_testbench/dut/alu_result[53]} -radix decimal} {{/cpu_testbench/dut/alu_result[52]} -radix decimal} {{/cpu_testbench/dut/alu_result[51]} -radix decimal} {{/cpu_testbench/dut/alu_result[50]} -radix decimal} {{/cpu_testbench/dut/alu_result[49]} -radix decimal} {{/cpu_testbench/dut/alu_result[48]} -radix decimal} {{/cpu_testbench/dut/alu_result[47]} -radix decimal} {{/cpu_testbench/dut/alu_result[46]} -radix decimal} {{/cpu_testbench/dut/alu_result[45]} -radix decimal} {{/cpu_testbench/dut/alu_result[44]} -radix decimal} {{/cpu_testbench/dut/alu_result[43]} -radix decimal} {{/cpu_testbench/dut/alu_result[42]} -radix decimal} {{/cpu_testbench/dut/alu_result[41]} -radix decimal} {{/cpu_testbench/dut/alu_result[40]} -radix decimal} {{/cpu_testbench/dut/alu_result[39]} -radix decimal} {{/cpu_testbench/dut/alu_result[38]} -radix decimal} {{/cpu_testbench/dut/alu_result[37]} -radix decimal} {{/cpu_testbench/dut/alu_result[36]} -radix decimal} {{/cpu_testbench/dut/alu_result[35]} -radix decimal} {{/cpu_testbench/dut/alu_result[34]} -radix decimal} {{/cpu_testbench/dut/alu_result[33]} -radix decimal} {{/cpu_testbench/dut/alu_result[32]} -radix decimal} {{/cpu_testbench/dut/alu_result[31]} -radix decimal} {{/cpu_testbench/dut/alu_result[30]} -radix decimal} {{/cpu_testbench/dut/alu_result[29]} -radix decimal} {{/cpu_testbench/dut/alu_result[28]} -radix decimal} {{/cpu_testbench/dut/alu_result[27]} -radix decimal} {{/cpu_testbench/dut/alu_result[26]} -radix decimal} {{/cpu_testbench/dut/alu_result[25]} -radix decimal} {{/cpu_testbench/dut/alu_result[24]} -radix decimal} {{/cpu_testbench/dut/alu_result[23]} -radix decimal} {{/cpu_testbench/dut/alu_result[22]} -radix decimal} {{/cpu_testbench/dut/alu_result[21]} -radix decimal} {{/cpu_testbench/dut/alu_result[20]} -radix decimal} {{/cpu_testbench/dut/alu_result[19]} -radix decimal} {{/cpu_testbench/dut/alu_result[18]} -radix decimal} {{/cpu_testbench/dut/alu_result[17]} -radix decimal} {{/cpu_testbench/dut/alu_result[16]} -radix decimal} {{/cpu_testbench/dut/alu_result[15]} -radix decimal} {{/cpu_testbench/dut/alu_result[14]} -radix decimal} {{/cpu_testbench/dut/alu_result[13]} -radix decimal} {{/cpu_testbench/dut/alu_result[12]} -radix decimal} {{/cpu_testbench/dut/alu_result[11]} -radix decimal} {{/cpu_testbench/dut/alu_result[10]} -radix decimal} {{/cpu_testbench/dut/alu_result[9]} -radix decimal} {{/cpu_testbench/dut/alu_result[8]} -radix decimal} {{/cpu_testbench/dut/alu_result[7]} -radix decimal} {{/cpu_testbench/dut/alu_result[6]} -radix decimal} {{/cpu_testbench/dut/alu_result[5]} -radix decimal} {{/cpu_testbench/dut/alu_result[4]} -radix decimal} {{/cpu_testbench/dut/alu_result[3]} -radix decimal} {{/cpu_testbench/dut/alu_result[2]} -radix decimal} {{/cpu_testbench/dut/alu_result[1]} -radix decimal} {{/cpu_testbench/dut/alu_result[0]} -radix decimal}} -subitemconfig {{/cpu_testbench/dut/alu_result[63]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[62]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[61]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[60]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[59]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[58]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[57]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[56]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[55]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[54]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[53]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[52]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[51]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[50]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[49]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[48]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[47]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[46]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[45]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[44]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[43]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[42]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[41]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[40]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[39]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[38]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[37]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[36]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[35]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[34]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[33]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[32]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[31]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[30]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[29]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[28]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[27]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[26]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[25]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[24]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[23]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[22]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[21]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[20]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[19]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[18]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[17]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[16]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[15]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[14]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[13]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[12]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[11]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[10]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[9]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[8]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[7]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[6]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[5]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[4]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[3]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[2]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[1]} {-height 15 -radix decimal} {/cpu_testbench/dut/alu_result[0]} {-height 15 -radix decimal}} /cpu_testbench/dut/alu_result
add wave -noupdate -radix decimal /cpu_testbench/dut/ex_out
add wave -noupdate -radix decimal /cpu_testbench/dut/mem_out
add wave -noupdate -radix unsigned /cpu_testbench/dut/mem_w_out
add wave -noupdate -divider {Register Data}
add wave -noupdate -childformat {{{/cpu_testbench/dut/cpu_register_file/registerData[31]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[30]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[29]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[28]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[27]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[26]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[25]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[24]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[23]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[22]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[21]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[20]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[19]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[18]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[17]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[16]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[15]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[14]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[13]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[12]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[11]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[10]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[9]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[8]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[7]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[6]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[5]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[4]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[3]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[2]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[1]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[0]} -radix decimal}} -expand -subitemconfig {{/cpu_testbench/dut/cpu_register_file/registerData[31]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[30]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[29]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[28]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[27]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[26]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[25]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[24]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[23]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[22]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[21]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[20]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[19]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[18]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[17]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[16]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[15]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[14]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[13]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[12]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[11]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[10]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[9]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[8]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[7]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[6]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[5]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[4]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[3]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[2]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[1]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[0]} {-height 15 -radix decimal}} /cpu_testbench/dut/cpu_register_file/registerData
add wave -noupdate -childformat {{{/cpu_testbench/dut/data_memory/mem[15]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[14]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[13]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[12]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[11]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[10]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[9]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[8]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[7]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[6]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[5]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[4]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[3]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[2]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[1]} -radix decimal} {{/cpu_testbench/dut/data_memory/mem[0]} -radix decimal}} -subitemconfig {{/cpu_testbench/dut/data_memory/mem[15]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[14]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[13]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[12]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[11]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[10]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[9]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[8]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[7]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[6]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[5]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[4]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[3]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[2]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[1]} {-height 15 -radix decimal} {/cpu_testbench/dut/data_memory/mem[0]} {-height 15 -radix decimal}} /cpu_testbench/dut/data_memory/mem
add wave -noupdate /cpu_testbench/dut/imm_choice
add wave -noupdate -radix decimal /cpu_testbench/dut/branch_addr_extended
add wave -noupdate -radix unsigned /cpu_testbench/dut/next_count_branch
add wave -noupdate /cpu_testbench/dut/blt_should_branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48918831 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
configure wave -valuecolwidth 394
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 1
configure wave -griddelta 80
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {107362500 ps}
