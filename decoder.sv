`timescale 1ps/1ps
//this module generates a decoder by continiously splitting the input into two outputs
//and then making a new recursive decoder with those two outputs.

module decoder_recursive #(parameter WIDTH=32) (enable, in, out);

	//this should make it so only powers of two greater than 0 work
	initial assert (WIDTH && !(WIDTH & (WIDTH - 1)));
	
	parameter delay = 50;
	
	input logic enable;
	localparam bits = $clog2(WIDTH)-1;
	input logic [bits:0] in;
	output logic [WIDTH-1:0] out;
	
	
	initial begin	
		$display(WIDTH, " ", bits);
	end
	
	
	genvar i;
	
	generate
		//end case, just divide the inputs into two bits by using in
		if(WIDTH < 3) begin
			
			logic inNot;
			not #delay myNot (inNot, in);
			and #delay myAnd_0 (out[0], enable, inNot);
			and #delay myAnd_1 (out[1], enable, in);
			
		//else recurse, creating another decoder of half size and then splitting the outputs with the last bit
		end else begin
			logic[(WIDTH/2)-1:0] tempOut;
			decoder_recursive #(.WIDTH(WIDTH/2)) decoder(.enable, .in(in[bits:1]), .out(tempOut));
			for(i = 0; i < (WIDTH); i++) begin : eachOut
				if((i % 2) == 0) begin
					// out[i] = ~in[0] & tempOut[temp]
					logic inNot;
					not #delay myNot (inNot, in[0]);
					and #delay myAnd (out[i], inNot, tempOut[i/2]);
				end else begin
					// out[i] = in[0] & tempOut[temp]
					and #delay myAnd(out[i], in[0], tempOut[i/2]);	
				end
			end
		end
	
	endgenerate
	
endmodule

/*
//2 bit decoder testbench, tested and works
module decoder_tb ();

	logic enable;
	logic  in;
	logic [1:0] out;
	
	decoder_recursive #(.WIDTH(2)) dut(.enable, .in, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		//simulating a game
		$stop; 
	end


endmodule
*/

/*

//4 bit decoder tb, tested and works
module decoder_tb ();

	logic enable;
	logic [1:0] in;
	logic [3:0] out;
	
	decoder_recursive #(.WIDTH(4)) dut(.enable, .in, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 3; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 2; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 3; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		$stop; 
	end

endmodule

*/

//8 bit decoder tb
module decoder_tb ();

	logic enable;
	logic [2:0] in;
	logic [7:0] out;
	
	decoder_recursive #(.WIDTH(8)) dut(.enable, .in, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 1; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 5; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 7; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 4; @(posedge CLOCK_50);
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 3; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		$stop; 
	end

endmodule


/*

//32 bit decoder tb
module decoder_tb ();

	logic enable;
	logic [4:0] in;
	logic [31:0] out;
	
	decoder_recursive dut(.enable, .in, .out);
	
	logic CLOCK_50;
	
	parameter clk_PERIOD = 10000;
	//creating a new detector to test along with appropriate variables.
	initial begin
		CLOCK_50 <= 0;
		forever #(clk_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		enable = 0; in = 0; @(posedge CLOCK_50);
		enable = 1; in = 15; @(posedge CLOCK_50);
		enable = 1; in = 21; @(posedge CLOCK_50);
		enable = 1; in = 11; @(posedge CLOCK_50);
		enable = 1; in = 22; @(posedge CLOCK_50);
		enable = 0; in = 9; @(posedge CLOCK_50);
		enable = 0; in = 14; @(posedge CLOCK_50);
		
		@(posedge CLOCK_50);
		@(posedge CLOCK_50);
		//simulating a game
		$stop; 
	end


endmodule

*/
