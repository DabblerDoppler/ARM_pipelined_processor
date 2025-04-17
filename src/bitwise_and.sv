`timescale 1ps/1ps

//Parameter-scalable AND module which takes two WIDTH size inputs and has one WIDTH size output.

module bitwise_and #(parameter WIDTH=64) (A, B, out);

	parameter delay = 50;
	
	input logic[WIDTH-1:0] A, B;

	output logic[WIDTH-1:0] out; 
	

	genvar i;
		
	generate 
			for(i=0; i<WIDTH; i++) begin : each_and_gate
				and #delay bitwise_and_gate(out[i], A[i], B[i]);
			end
	endgenerate
endmodule