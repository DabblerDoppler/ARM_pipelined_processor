`timescale 1ps/1ps

// ============================================================================
// Linear Shift Right Module Implementation
// ============================================================================
// This module implements a parameterized linear shift right operation with the following features:
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
//   * Zero-fill phase for shifted bits (WIDTH-1 to WIDTH-SHIFT)
//   * Shift phase for remaining bits (WIDTH-SHIFT-1 to 0)
// - Parameter validation for shift amount
// - Efficient multiplexer-based design
//
// Operation:
// - When enabled: shifts input right by SHIFT bits
// - When disabled: passes input through unchanged
// - Shifted bits are filled with zeros
// - SHIFT must be positive and less than WIDTH
// - WIDTH must be positive
//
// Example:
// - Input:  0x0000000000000004
// - SHIFT:  2
// - Output: 0x0000000000000001 (when enabled)
// - Output: 0x0000000000000004 (when disabled)
//
// Timing:
// - 1ps resolution for simulation
// - Single-cycle operation
// - No clock required (combinational logic)
//
// ============================================================================

module linear_shift_right #(
	parameter SHIFT = 1,
	parameter WIDTH = 64
) (in, enable, out);
	input logic [WIDTH-1:0] in;
	input logic enable;
	output logic [WIDTH-1:0] out;
	
	//ensure parameters are valid
	initial assert (SHIFT > 0 && WIDTH > 0);
	
	//internal signal
	logic [(WIDTH * 2) - 1:0] temp;
	
	//Connects the first SHIFT bits on the right to 0 or themselves
	//and the rest to the bit to be shifted to them or themselves.
	genvar i;
	generate
		for(i=WIDTH-1; i > (WIDTH-1) - SHIFT; i--) begin: zeroLoop
			var [0:1] in0;
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = 0;
			mux2_1 zero_mux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
		
		for(i= (WIDTH-1) - SHIFT; i >= 0; i--) begin : shiftLoop
			var [0:1] in1;
			assign temp[(2*i) + 0] = in[i];
			assign temp[(2*i) + 1] = in[i+SHIFT];
			mux2_1 shift_mux(.i0(temp[(2*i)]), .i1(temp[(2*i)+1]), .sel(enable), .out(out[i]));
		end
	
	endgenerate


endmodule
