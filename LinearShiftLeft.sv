`timescale 1ps/1ps

module LinearShiftLeft #(parameter SHIFT = 1) (in, enable, out);
	parameter WIDTH = 64;
	input logic [WIDTH-1:0] in;
	input logic enable;
	output logic [WIDTH-1:0] out;
	
	initial assert (SHIFT > 0 && WIDTH > 0);
	
	genvar i;
	
	
	logic [(WIDTH * 2) - 1:0] temp;



	generate
		for(i = 0; i < SHIFT; i++) begin : zeroLoop
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = 0;
			mux2_1 thisMux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
		
		for(i=SHIFT; i < WIDTH; i++) begin : shiftLoop
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = in[i-SHIFT];
			mux2_1 thisMux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
	
	endgenerate
	
endmodule

module LSL_tb();

	parameter ClockDelay = 5000;

	logic [63:0] in, out;
	logic enable;
	logic clk;

	LinearShiftLeft #(.SHIFT(2)) dut (.in, .enable, .out);
	
	
	
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	
	initial begin
	
			in = 5; enable = 0; @(posedge clk); 
			in = 5; enable = 1; @(posedge clk); 
			in = 64'd9223372036854775807; enable = 1; @(posedge clk); 
			in = 5; enable = 0; @(posedge clk); 
			in = 0; enable = 1; @(posedge clk); 
			in = 5; enable = 0; @(posedge clk); 
			$stop;
	end
endmodule
