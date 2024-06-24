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
	
	logic [63:0] baseResult, addResult, subResult, andResult, orResult, xorResult;
	logic overflowSub, overflowAdd, overflowBase, cOutSub, cOutAdd, cOutBase;
	
	assign baseResult = B;
	assign overflowBase = 0;
	assign cOutBase = 0;
	
	logic [63:0] AddOrSubMuxd;
	
	//invert bits then make use an adder to make a subtractor.
	logic [63:0] bInverted;
	inverter toBeSubbed(.in(B), .out(bInverted));
	
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : eachAddSubMux
			mux2_1 addSubMux(.out(AddOrSubMuxd[i]), .i0(B[i]), .i1(bInverted[i]), .sel(cntrl[0]));
		end
	endgenerate
	
	adder myAdder(.A(A), .B(AddOrSubMuxd), .sum(addResult), .carryOut(carry_out), .overflow(overflow));
	
	
	
	
	bitwiseAnd myAnd(.A, .B, .out(andResult));
	bitwiseOr myOr(.A, .B, .out(orResult));
	bitwiseXor myXor(.A, .B, .out(xorResult));
	
	logic [63:0] zeroes;
	
	//set result to the correct ALU function based on cntrl
	
	logic [63:0] muxInput [7:0];
	
	assign muxInput [0] = baseResult;
	assign muxInput [1] = zeroes;
	assign muxInput [2] = addResult;
	assign muxInput [3] = addResult;
	assign muxInput [4] = andResult;
	assign muxInput [5] = orResult;
	assign muxInput [6] = xorResult;
	assign muxInput [7] = zeroes;
	
	logic [7:0] muxInput_Flipped [63:0];
	
	genvar j;
	
	//flip muxInput
	generate
		for(i=0; i<8; i++) begin : eachBit_8
			for (j=0; j<64; j++) begin :eachBit_64
				always_comb begin
					muxInput_Flipped[j][i] = muxInput[i][j];
				end
			end
		end
	endgenerate
	
	
	generate
		for(i = 0; i < 64; i++) begin : eachMux
			mux_recursive #(.WIDTH(8)) aMux (.in(muxInput_Flipped[i][7:0]), .read(cntrl), .out(result[i]));
		end
	endgenerate
	
	
	
	
	//set zero and negative
	
	zeroChecker #(.WIDTH(64)) myChecker(.in(result), .out(zero));
	
	
	assign negative = result[63];
	


endmodule