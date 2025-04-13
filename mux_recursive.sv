//this module creates any mux with a width of a power of two by recursively generating smaller muxes.

`timescale 1ps/1ps
module mux_recursive #(parameter WIDTH=32) (in, read, out);

	//This makes it so only powers of two greater than 0 are valid for the width.	
	//other values wouldn't work properly with the recursion.
	initial assert (WIDTH && !(WIDTH & (WIDTH - 1)));
	
	parameter delay = 50;
	
	localparam w = WIDTH/2;
	localparam bits = $clog2(WIDTH)-1;

	input logic [WIDTH-1:0]	in;
	input logic [bits:0] read;
	output logic out;
	
	time gate_delay = 50;
		
	generate
			//recurse, making 2 more muxes of half the size as well as a 2x1 mux to split between thenm
			if(WIDTH > 2) begin
				var [0:1] out1;
				mux_recursive #(.WIDTH(w)) m1 (.in(in[w-1:0]), .read(read[bits-1:0]), .out(out1[1]));
				mux_recursive #(.WIDTH(w)) m2 (.in(in[WIDTH-1:w]), .read(read[bits-1:0]), .out(out1[0]));
				mux_recursive #(.WIDTH(2)) m3 (.in(out1), .read(read[bits]), .out);
			end else begin
				//2x1 mux default case
				/*
				always_comb begin
					out = (in[0] & ~read[0]) | (in[1] & read[0]);
				end
				*/
				
				logic read_not;
				not #delay myNot (read_not, read[0]);
				logic and_one;
				and #delay myAnd_0 (and_one, read_not, in[0]);
				logic and_two;
				and #delay myAnd_1 (and_two, read, in[1]);
				or #delay myOr (out, and_one, and_two);
				
			end
	endgenerate
			
	
endmodule
	
//32 bit bench for testing
module mux_tb ();

	logic [31:0] in;
	logic [4:0] read;
	logic  out;
	
	mux_recursive dut(.in, .read, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		read = 1; in = 53; @(posedge CLOCK_50);
		read = 0; in = 1; @(posedge CLOCK_50);
		read = 3; in = 25; @(posedge CLOCK_50);
		read = 1; in = 88; @(posedge CLOCK_50);
		read = 1; in = 47; @(posedge CLOCK_50);
		read = 1; in = 3; @(posedge CLOCK_50);
		read = 9; in = 53; @(posedge CLOCK_50);
		read = 6; in = 25; @(posedge CLOCK_50);
		read = 4; in = 88; @(posedge CLOCK_50);
		read = 12; in = 47; @(posedge CLOCK_50);
		read = 0; in = 3; @(posedge CLOCK_50);
		read = 0; in = 1; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		//simulating a game
		$stop; 
	end


endmodule
	
/*
//8 width bench for testing
module mux_tb ();

	logic [7:0] in;
	logic [2:0] read;
	logic  out;
	
	mux_recursive #(.WIDTH(8)) dut(.in, .read, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 100;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		read = 0; in = 1; @(posedge CLOCK_50);
		read = 1; in = 255; @(posedge CLOCK_50);
		read = 2; in = 8; @(posedge CLOCK_50);
		read = 3; in = 9; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		//simulating a game
		$stop; 
	end


endmodule	

*/


