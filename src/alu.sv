`timescale 1ns/1ns

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B			value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

//this module takes two inputs and a control signal and performs the logic functions above
//based on that control signal. 
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic		[63:0]	A, B;
	input logic		[2:0]		cntrl;
	output logic	[63:0]	result;
	output logic				negative, zero, overflow, carry_out;
	
	
	
	//setup logic units for our functions
	
	logic [63:0] base_result, add_result, sub_result, and_result, or_result, xor_result;
	
	assign base_result = B;
	assign overflowBase = 0;
	assign cOutBase = 0;
	
	logic [63:0] add_sub_mux_out;
	
	//invert bits then make use an adder to make a subtractor.
	logic [63:0] b_inverted;
	inverter subtraction_inverter(.in(B), .out(b_inverted));
	
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : each_add_sub_mux
			mux2_1 add_sub_mux(.out(add_sub_mux_out[i]), .i0(B[i]), .i1(b_inverted[i]), .sel(cntrl[0]));
		end
	endgenerate
	
	adder alu_adder(.A(A), .B(add_sub_mux_out), .sum(add_result), .carry_out(carry_out), .overflow(overflow));
	
	
	
	
	bitwise_and alu_and(.A, .B, .out(and_result));
	bitwise_or alu_or(.A, .B, .out(or_result));
	bitwise_xor alu_xor(.A, .B, .out(xor_result));
	
	logic [63:0] zeroes;
	
	//set result to the correct ALU function based on cntrl
	
	logic [63:0] mux_in [7:0];
	
	assign mux_in [0] = base_result;
	assign mux_in [1] = zeroes;
	assign mux_in [2] = add_result;
	assign mux_in [3] = add_result;
	assign mux_in [4] = and_result;
	assign mux_in [5] = or_result;
	assign mux_in [6] = xor_result;
	assign mux_in [7] = zeroes;
	
	logic [7:0] mux_in_flipped [63:0];
	
	genvar j;
	
	//flip mux_in
	generate
		for(i=0; i<8; i++) begin : eachBit_8
			for (j=0; j<64; j++) begin :eachBit_64
				always_comb begin
					mux_in_flipped[j][i] = mux_in[i][j];
				end
			end
		end
	endgenerate
	
	
	generate
		for(i = 0; i < 64; i++) begin : eachMux
			mux_recursive #(.WIDTH(8)) aMux (.in(mux_in_flipped[i][7:0]), .read(cntrl), .out(result[i]));
		end
	endgenerate
	
	
	
	
	//set zero and negative
	
	zero_checker #(.WIDTH(64)) myChecker(.in(result), .out(zero));
	
	
	assign negative = result[63];
	


endmodule