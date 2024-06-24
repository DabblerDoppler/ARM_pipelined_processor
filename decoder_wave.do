onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /decoder_tb/enable
add wave -noupdate /decoder_tb/in
add wave -noupdate /decoder_tb/out
add wave -noupdate /decoder_tb/dut/genblk1/decoder/in
add wave -noupdate /decoder_tb/dut/genblk1/decoder/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83783 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 300
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {182225 ps}
