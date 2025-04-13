`timescale 1ns/1ns


module zero_checker #(parameter WIDTH=64) (in, out);
	parameter delay = 50;

	initial assert (WIDTH > 3);

	input logic [WIDTH-1:0] in;
	output logic out;

	
	logic [31:0] temp1;
	logic [15:0] temp2;
	logic [7:0] temp3;
	logic [3:0] temp4;
	
	genvar i;
	
	generate
	
		for(i=0; i < WIDTH; i+=2) begin : firstLoop
			or #delay (temp1[i/2], in[i], in[i+1]);
		end
		for(i=0; i < WIDTH/2; i+=2) begin : secondLoop
			or #delay (temp2[i/2], temp1[i], temp1[i+1]);
		end
		for(i=0; i < WIDTH/4; i+=2) begin : thirdLoop
			or #delay (temp3[i/2], temp2[i], temp2[i+1]);
		end
		for(i=0; i < WIDTH / 8; i+=2) begin : fourthLoop
			or #delay (temp4[i/2], temp3[i], temp3[i+1]);
		end
	endgenerate
		
	
	nor #delay (out, temp4[0], temp4[1], temp4[2], temp4[3]);

endmodule