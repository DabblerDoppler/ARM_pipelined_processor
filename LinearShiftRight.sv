`timescale 1ps/1ps

module LinearShiftRight #(parameter SHIFT = 1) (in, enable, out);
	parameter WIDTH = 64;
	input logic [WIDTH-1:0] in;
	input logic enable;
	logic signExtend;
	output logic [WIDTH-1:0] out;
	
	initial assert (SHIFT > 0 && WIDTH > 0);
	
	genvar i;
	
	logic [(WIDTH * 2) - 1:0] temp;
	
	//pretty simple loop, connects the first SHIFT bits on the right to 0 or themselves
	//and the rest to the bit to be shifted to them or themselves.
	generate
		for(i=WIDTH-1; i > (WIDTH-1) - SHIFT; i--) begin: zeroLoop
			var [0:1] in0;
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = 0;
			mux2_1 thisMux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
		
		for(i= (WIDTH-1) - SHIFT; i >= 0; i--) begin : shiftLoop
			var [0:1] in1;
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = in[i+SHIFT];
			mux2_1 thisMux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
	
	endgenerate


endmodule

module LSR_tb();

	parameter ClockDelay = 5000;

	logic [63:0] in, out;
	logic enable;
	logic clk;

	LinearShiftRight #(.SHIFT(1)) dut (.in, .enable, .out);
	
	
	
	
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