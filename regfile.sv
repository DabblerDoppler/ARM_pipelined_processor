`timescale 1ps/1ps
//top level module. 
module regfile (clk, RegWrite, WriteData, WriteRegister, ReadData1, ReadData2, ReadRegister1, ReadRegister2, reset);
	input  logic  clk; // clock
	input logic RegWrite, reset;
	input logic [4:0] WriteRegister, ReadRegister1, ReadRegister2;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] decoderOutput;
	logic [31:0][63:0] registerData ;
	
	
	genvar i;
	
	decoder_recursive decoder (.enable(RegWrite), .in(WriteRegister), .out(decoderOutput));
	
	
	//create 31 registers, plus a special one at the end that's always 0
	generate
		for(i=0; i<31; i++) begin : eachRegister
			register myRegister(.clk(clk), .in(WriteData), .reset(reset), .enable(decoderOutput[i]), .out(registerData[i][63:0]));
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
			mux_recursive #(.WIDTH(32)) mux32_1 (.in(registerData_flipped[i][31:0]), .read(ReadRegister1), .out(ReadData1[i]));
			mux_recursive #(.WIDTH(32)) mux32_2 (.in(registerData_flipped[i][31:0]), .read(ReadRegister2), .out(ReadData2[i]));
		end
	endgenerate
	
	
endmodule

