onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /zeroChecker_tb/in
add wave -noupdate /zeroChecker_tb/out
add wave -noupdate /zeroChecker_tb/clk
add wave -noupdate /zeroChecker_tb/dut/temp1
add wave -noupdate /zeroChecker_tb/dut/temp2
add wave -noupdate /zeroChecker_tb/dut/temp3
add wave -noupdate /zeroChecker_tb/dut/temp4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {624509804 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 246
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
WaveRestoreZoom {0 ps} {3412500 ns}
