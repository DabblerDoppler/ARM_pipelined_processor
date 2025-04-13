// ============================================================================
//                  Linear Shift Right Dynamic Module Implementation
// ============================================================================
//
// This module implements a dynamically configurable linear shift right operation
// with the following features:
//
// Core Functionality:
// -----------------------------------------------------------------------------
// - Dynamic shift amount (0-63 bits) controlled by 6-bit input
// - 64-bit data width
// - Binary-weighted shift implementation
// - Zero-fill on shifted bits
// - Cascaded shift architecture
//
// Implementation Details:
// -----------------------------------------------------------------------------
// - Uses six fixed-shift modules in series
// - Binary-weighted shift amounts (1, 2, 4, 8, 16, 32 bits)
// - Each shift stage is selectively enabled based on corresponding bit in shift_amount
// - Modular design with parameterized sub-modules
// - Enables any shift amount from 0 to 63 bits through binary combination
//
// Operation:
// -----------------------------------------------------------------------------
// - Each bit in shift_amount enables its corresponding shift stage
//   * shift_amount[0] controls 1-bit shift
//   * shift_amount[1] controls 2-bit shift
//   * shift_amount[2] controls 4-bit shift
//   * shift_amount[3] controls 8-bit shift
//   * shift_amount[4] controls 16-bit shift
//   * shift_amount[5] controls 32-bit shift
// - Stages are cascaded (output of one feeds into input of next)
//
// Example:
// -----------------------------------------------------------------------------
// - Input:  0x8000000000000000
// - shift_amount: 6'b010101 (21 decimal)
// - Enabled stages: 1-bit, 4-bit, and 16-bit shifts
// - Output: 0x0000100000000000
//
// Timing:
// -----------------------------------------------------------------------------
// - 1ps resolution for simulation
// - Single-cycle operation (combinational logic)
// - No clock required
// - Propagation delay increases with number of enabled stages
//
// ============================================================================

module linear_shift_right_dynamic (in, shift_amount, out);
	input logic [63:0] in;
	input logic [5:0] shift_amount;
	output logic [63:0] out;
	
	logic [63:0] out1, out2, out3, out4, out5;
	
	//This combination of shifters lets us make any shift we want up to 63.
	//All of these are 64 bit width, same as this module.

	linear_shift_right #(.SHIFT(1)) lsr1   (.in(in), .enable(shift_amount[0]), .out(out1));
	linear_shift_right #(.SHIFT(2)) lsr2   (.in(out1), .enable(shift_amount[1]), .out(out2));
	linear_shift_right #(.SHIFT(4)) lsr4   (.in(out2), .enable(shift_amount[2]), .out(out3));
	linear_shift_right #(.SHIFT(8)) lsr8   (.in(out3), .enable(shift_amount[3]), .out(out4));
	linear_shift_right #(.SHIFT(16)) lsr16   (.in(out4), .enable(shift_amount[4]), .out(out5));
	linear_shift_right #(.SHIFT(32)) lsr32   (.in(out5), .enable(shift_amount[5]), .out(out));
	
	
	
endmodule