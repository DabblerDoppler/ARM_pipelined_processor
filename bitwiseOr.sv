`timescale 1ps/1ps

module bitwiseOr #(parameter WIDTH=64)(A, B, out);

	parameter delay = 50;
	
	input logic[WIDTH-1:0] A, B;

	output logic[WIDTH-1:0] out; 
	
	genvar i;
		
	generate 
			for(i=0; i<WIDTH; i++) begin : eachOrGate
				or #delay thisOr (out[i], A[i], B[i]);
			end
	endgenerate

endmodule