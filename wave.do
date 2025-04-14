onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Input Logic}
add wave -noupdate /cpu_testbench/dut/clock
add wave -noupdate /cpu_testbench/dut/reset
add wave -noupdate -divider {Instruction Logic}
add wave -noupdate /cpu_testbench/dut/instruction
add wave -noupdate /cpu_testbench/dut/current_instruction
add wave -noupdate /cpu_testbench/dut/imm_12
add wave -noupdate -divider {ALU Logic}
add wave -noupdate /cpu_testbench/dut/alu_op
add wave -noupdate /cpu_testbench/dut/alu_b_input
add wave -noupdate -divider {Register Data}
add wave -noupdate -childformat {{{/cpu_testbench/dut/cpu_register_file/registerData[31]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[30]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[29]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[28]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[27]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[26]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[25]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[24]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[23]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[22]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[21]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[20]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[19]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[18]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[17]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[16]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[15]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[14]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[13]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[12]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[11]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[10]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[9]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[8]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[7]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[6]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[5]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[4]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[3]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[2]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[1]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[0]} -radix decimal}} -subitemconfig {{/cpu_testbench/dut/cpu_register_file/registerData[31]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[30]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[29]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[28]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[27]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[26]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[25]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[24]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[23]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[22]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[21]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[20]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[19]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[18]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[17]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[16]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[15]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[14]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[13]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[12]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[11]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[10]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[9]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[8]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[7]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[6]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[5]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[4]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[3]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[2]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[1]} {-radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[0]} {-radix decimal}} /cpu_testbench/dut/cpu_register_file/registerData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11357355 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
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
