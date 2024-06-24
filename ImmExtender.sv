`timescale 1ps/1ps

module Sext #(parameter IMMLENGTH = 16) (in, isSigned, out);
	input logic [IMMLENGTH-1:0] in;
	input logic isSigned; 
	output logic [63:0] out;
	
	logic temp;
	
	initial assert (IMMLENGTH > 0);
	
	assign out[IMMLENGTH-1:0] = in[IMMLENGTH-1:0];
	
	mux2_1 SextMux (.out(temp), .i0(1'b0), .i1(in[IMMLENGTH-1]), .sel(isSigned));
	
	genvar i;
	generate
		for(i=IMMLENGTH; i<64; i++) begin : ThisMuxInput
			assign out[i] = temp;
		end
	endgenerate
	
	
endmodule

module SextBench();

	parameter ClockDelay = 5000;

	logic [15:0] in;
	logic [63:0] out;
	logic isSigned;
	logic clk;

	Sext dut (.in, .isSigned, .out);
	
	
	
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	
	initial begin
	
			in = 5; isSigned = 0; @(posedge clk); 
			in = 5; isSigned = 1; @(posedge clk); 
			in = 16'd64775807; isSigned = 1; @(posedge clk); 
			isSigned = 0; @(posedge clk); 
			in = 0; isSigned = 1; @(posedge clk); 
			in = -847; isSigned = 1; @(posedge clk); 
			in = -847; isSigned = 0; @(posedge clk); 
			$stop;
	end
endmodule