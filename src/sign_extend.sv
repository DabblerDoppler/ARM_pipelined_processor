`timescale 1ps/1ps

// ============================================================================
// Sign Extension Module Implementation
// ============================================================================
// This module implements a parameterized sign extension operation with the following features:
//
// Core Functionality:
// - Parameterized input width (default 16 bits)
// - 64-bit output width
// - Configurable sign/zero extension via is_signed control
// - Efficient multiplexer-based implementation
// - Input width validation
//
// Implementation Details:
// - Uses 2:1 multiplexer for sign bit selection
// - Parameterized generate block for extension bits
// - Input width validation on initialization
// - Direct assignment for lower bits
// - Generate block for upper bits
//
// Operation:
// - When is_signed = 1: 
//   * Extends MSB of input to all upper bits (sign extension)
//   * Example: 16'b1000_0000_0000_0000 -> 64'b1111...1000_0000_0000_0000
//   * Preserves two's complement representation
// - When is_signed = 0:
//   * Extends with zeros to all upper bits (zero extension)
//   * Example: 16'b1000_0000_0000_0000 -> 64'b0000...1000_0000_0000_0000
//   * Treats input as unsigned value
//
// Parameters:
// - IMMLENGTH: Length of input immediate value (must be > 0)
// - Default: 16 bits
//
// Timing:
// - 1ps resolution for simulation
// - Single-cycle operation
// - No clock required (combinational logic)
//
// ============================================================================


module sign_extend #(parameter IMMLENGTH = 16) (in, is_signed, out);
	input logic [IMMLENGTH-1:0] in;
	input logic is_signed; 
	output logic [63:0] out;
	
	logic temp;
	
	initial assert (IMMLENGTH > 0);
	
	assign out[IMMLENGTH-1:0] = in[IMMLENGTH-1:0];
	
	mux2_1 sign_ext_mux (.out(temp), .i0(1'b0), .i1(in[IMMLENGTH-1]), .sel(is_signed));
	
	genvar i;
	generate
		for(i=IMMLENGTH; i<64; i++) begin : ThisMuxInput
			assign out[i] = temp;
		end
	endgenerate
	
	
endmodule
