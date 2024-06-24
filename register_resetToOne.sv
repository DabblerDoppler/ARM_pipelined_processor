//this is a register which uses a set number of d flip flops with enables to maintain
//and determine when to write data.

`timescale 1ps/1ps
module register_resetToOne #(parameter WIDTH=64) (clk, in, reset, enable, out);
	output logic [WIDTH-1:0] out;
	input logic [WIDTH-1:0] in;
	input logic clk, enable, reset;
	
	initial assert (WIDTH > 0);

	genvar i;
	
	generate
		for(i=0; i<WIDTH; i++) begin : eachDff
			dff_with_enable_resetToOne dflipflop (.clk(clk), .in(in[i]), .reset(reset), .enable(enable), .out(out[i]));
			//D_FF dflipflop (.clk, .q(out[i]), .reset(reset), .d(in[i]));
		end
	endgenerate
	
endmodule
