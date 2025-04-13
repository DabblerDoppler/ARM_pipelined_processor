`timescale 1ps/1ps


// ============================================================================
// Linear Shift Left Module Implementation
// ============================================================================
// This module implements a parameterized linear shift left operation with the following features:
//
// Core Functionality:
// - Parameterized shift amount (default 1 bit)
// - 64-bit data width (configurable)
// - Enable control for operation
// - Zero-fill on shifted bits
// - Two-phase shift implementation
//
// Implementation Details:
// - Uses multiplexers for shift selection
// - Two-phase implementation:
//   * Zero-fill phase for shifted bits (0 to SHIFT-1)
//   * Shift phase for remaining bits (SHIFT to WIDTH-1)
// - Parameter validation for shift amount
// - Efficient multiplexer-based design
//
// Operation:
// - When enabled: shifts input left by SHIFT bits
// - When disabled: passes input through unchanged
// - Shifted bits are filled with zeros
// - SHIFT must be positive and less than WIDTH
// - WIDTH must be positive
//
// Example:
// - Input:  0x0000000000000001
// - SHIFT:  2
// - Output: 0x0000000000000004 (when enabled)
// - Output: 0x0000000000000001 (when disabled)
//
// Timing:
// - 1ps resolution for simulation
// - Single-cycle operation
// - No clock required (combinational logic)
//
// ============================================================================


module linear_shift_left #(
	parameter SHIFT = 1,
	parameter WIDTH = 64
) (in, enable, out);
	input logic [WIDTH-1:0] in;
	input logic enable;
	output logic [WIDTH-1:0] out;
	
	//ensure parameters are valid
	initial assert (SHIFT > 0 && WIDTH > 0);
	

	
	
	logic [(WIDTH * 2) - 1:0] temp;

	//Connects the first SHIFT bits on the left to 0 or themselves
	//and the rest to the bit to be shifted to them or themselves.
	genvar i;
	generate
		for(i = 0; i < SHIFT; i++) begin : zeroLoop
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = 0;
			mux2_1 zero_mux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
		
		for(i=SHIFT; i < WIDTH; i++) begin : shiftLoop
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = in[i-SHIFT];
			mux2_1 shift_mux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
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
