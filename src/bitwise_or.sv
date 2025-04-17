`timescale 1ps/1ps

//Parameter-scalable OR module which takes two WIDTH size inputs and has one WIDTH size output.

module bitwise_or #(parameter WIDTH=64)(A, B, out);

	parameter delay = 50;
	
	input logic[WIDTH-1:0] A, B;

	output logic[WIDTH-1:0] out; 
	
	genvar i;
		
	generate 
			for(i=0; i<WIDTH; i++) begin : each_or_gate
				or #delay bitwise_or_gate(out[i], A[i], B[i]);
			end
	endgenerate

endmodule