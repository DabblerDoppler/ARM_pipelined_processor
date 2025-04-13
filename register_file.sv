`timescale 1ps/1ps


// ============================================================================
// Register File Module
// ============================================================================
// This module implements a 32-register file with two read ports and one write port.
// Each register is 64 bits wide. Register x31 is hardwired to zero and cannot be
// written to. The module supports simultaneous read and write operations.
//
// Features:
// - 32 64-bit registers (x0-x31)
// - x31 hardwired to zero
// - Two read ports, one write port
// - Write enable control
// - Asynchronous reset
//
// Parameters:
// - None
//
// Inputs:
// - clock: System clock
// - reset: Asynchronous reset (active high)
// - write_enable: Write enable control
// - write_addr: 5-bit write address
// - write_data: 64-bit data to write
// - read_addr1: 5-bit address for first read port
// - read_addr2: 5-bit address for second read port
//
// Outputs:
// - read_data1: 64-bit data from first read port
// - read_data2: 64-bit data from second read port
//
// Operation:
// - On positive clock edge with write_enable=1, writes data to specified register
// - x31 is always read as zero and cannot be written to
// - Read operations are combinational
//
// ============================================================================


module register_file (clk, write_enabled, write_data, write_addr, read_data_1, read_data_2, read_addr_1, read_addr_2, reset);
	input  logic  clk; // clock
	input logic write_enabled, reset;
	input logic [4:0] write_addr, read_addr_1, read_addr_2;
	input logic [63:0] write_data;
	output logic [63:0] read_data_1, read_data_2;
	
	logic [31:0] decoderOutput;
	logic [31:0][63:0] registerData ;
	
	
	genvar i;
	
	decoder_recursive decoder (.enable(write_enabled), .in(write_addr), .out(decoderOutput));
	
	
	//create 31 registers, plus a special one at the end that's always 0
	generate
		for(i=0; i<31; i++) begin : eachRegister
			register myRegister(.clk(clk), .in(write_data), .reset(reset), .enable(decoderOutput[i]), .out(registerData[i][63:0]));
		end
	endgenerate
	
	
	//this is the special 0-output register.
	register myRegister(.clk(clk), .in(64'b0), .reset(1'b1), .enable(1'b0), .out(registerData[31][63:0]));
	
	
	logic [63:0][31:0] registerData_flipped;
	
	genvar j;
	
	//flip the outputs of register data
	generate
		for(i=0; i<64; i++) begin : eachBit_64
			for (j=0; j<32; j++) begin :eachBit_32
				always_comb begin
					registerData_flipped[i][j] = registerData[j][i];
				end
			end
		end
	endgenerate
	
	
	//create 64 muxes, one for each data bit, for each of two sets.
	generate
		for(i=0; i<64; i++) begin : eachMux
			//something's funky with registerData
			mux_recursive #(.WIDTH(32)) mux32_1 (.in(registerData_flipped[i][31:0]), .read(read_addr_1), .out(read_data_1[i]));
			mux_recursive #(.WIDTH(32)) mux32_2 (.in(registerData_flipped[i][31:0]), .read(read_addr_2), .out(read_data_2[i]));
		end
	endgenerate
	
	
endmodule

