`timescale 1ps/1ps

//This module is a 5-bit equality checker. If all of the input bits are equal,
//it outputs 1 - otherwise, it outputs 0.

module equality_checker (in0, in1, out);

	parameter delay = 50;
	
	input logic [4:0] in0, in1;
	
	output logic out;
	
	logic [4:0] temp; 
	
	genvar i;
	
	generate
	
		for(i=0; i < 5; i++) begin : eachEqualityCheck
			xnor #delay (temp[i], in0[i], in1[i]);
		end
		
	
	endgenerate
	
	logic tempAnd;

	//There's a cleaner way to do this but the original project requirements were no gates 
	//with more than 4 inputs, so I'm keeping this implementation.
	and #delay (tempAnd, temp[0], temp[1]);
	and #delay (out, tempAnd, temp[2], temp[3], temp[4]);
	
	
endmodule

module EqChecker_tb ();

	logic enable;
	logic [4:0] in0, in1;
	logic out;
	
	EqualityChecker_5  dut(.in0, .in1, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		
		in0 = 0; in1 = 31; @(posedge CLOCK_50);
		in0 = 0; in1 = 15; @(posedge CLOCK_50);
		in0 = 15; in1 = 15; @(posedge CLOCK_50);
		in0 = 31; in1 = 0; @(posedge CLOCK_50);
		in0 = 2; in1 = 2; @(posedge CLOCK_50);
		in0 = 31; in1 = 1; @(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		$stop; 
	end

endmodule