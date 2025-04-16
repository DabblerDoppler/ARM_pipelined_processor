onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Input Logic}
add wave -noupdate /cpu_testbench/dut/clock
add wave -noupdate /cpu_testbench/dut/reset
add wave -noupdate -divider {Instruction Logic}
add wave -noupdate -radix unsigned /cpu_testbench/dut/program_counter
add wave -noupdate /cpu_testbench/dut/instruction
add wave -noupdate /cpu_testbench/dut/current_instruction
add wave -noupdate /cpu_testbench/dut/rf_imm_12
add wave -noupdate -divider {ALU Logic}
add wave -noupdate /cpu_testbench/dut/rf_a_out
add wave -noupdate /cpu_testbench/dut/rf_b_out
add wave -noupdate /cpu_testbench/dut/alu_op
add wave -noupdate /cpu_testbench/dut/alu_src
add wave -noupdate /cpu_testbench/dut/alu_b_input
add wave -noupdate /cpu_testbench/dut/alu_result
add wave -noupdate -divider {Register Data}
add wave -noupdate -childformat {{{/cpu_testbench/dut/cpu_register_file/registerData[31]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[30]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[29]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[28]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[27]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[26]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[25]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[24]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[23]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[22]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[21]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[20]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[19]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[18]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[17]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[16]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[15]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[14]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[13]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[12]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[11]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[10]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[9]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[8]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[7]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[6]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[5]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[4]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[3]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[2]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[1]} -radix decimal} {{/cpu_testbench/dut/cpu_register_file/registerData[0]} -radix decimal}} -subitemconfig {{/cpu_testbench/dut/cpu_register_file/registerData[31]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[30]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[29]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[28]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[27]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[26]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[25]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[24]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[23]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[22]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[21]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[20]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[19]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[18]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[17]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[16]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[15]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[14]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[13]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[12]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[11]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[10]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[9]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[8]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[7]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[6]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[5]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[4]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[3]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[2]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[1]} {-height 15 -radix decimal} {/cpu_testbench/dut/cpu_register_file/registerData[0]} {-height 15 -radix decimal}} /cpu_testbench/dut/cpu_register_file/registerData
add wave -noupdate /cpu_testbench/dut/cbz_branch_taken
add wave -noupdate /cpu_testbench/dut/ex_cbz_branch_taken
add wave -noupdate /cpu_testbench/dut/cbz_should_branch
add wave -noupdate /cpu_testbench/dut/mem_delayed_branch
add wave -noupdate /cpu_testbench/dut/ex_branch_taken_final
add wave -noupdate /cpu_testbench/dut/branch_taken_final
add wave -noupdate /cpu_testbench/dut/mem_out
add wave -noupdate /cpu_testbench/dut/rf_b_input
add wave -noupdate /cpu_testbench/dut/imm_choice
add wave -noupdate -radix decimal /cpu_testbench/dut/branch_addr_extended
add wave -noupdate -radix unsigned /cpu_testbench/dut/next_count_branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3400167 ps} 0}
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
WaveRestoreZoom {0 ps} {14285424 ps}
