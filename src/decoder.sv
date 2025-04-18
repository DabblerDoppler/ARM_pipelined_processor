`timescale 1ps/1ps
//this module generates a decoder by continiously splitting the input into two outputs,
//and then making a new decoder recursively with those outputs.

module decoder_recursive #(parameter WIDTH=32) (enable, in, out);

	//this ensures the width parameter is a power of 2 greater than 0.
	initial assert (WIDTH && !(WIDTH & (WIDTH - 1)));
	
	parameter delay = 50;
	
	input logic enable;
	localparam bits = $clog2(WIDTH)-1;
	input logic [bits:0] in;
	output logic [WIDTH-1:0] out;
	
	
	initial begin	
		$display(WIDTH, " ", bits);
	end
	
	
	genvar i;
	
	generate
		//end case, just divide the inputs into two bits by using in
		if(WIDTH < 3) begin
			
			logic in_not;
			not #delay myNot (in_not, in);
			and #delay myAnd_0 (out[0], enable, in_not);
			and #delay myAnd_1 (out[1], enable, in);
			
		//else recurse, creating another decoder of half size and then splitting the outputs with the last bit
		end else begin
			logic[(WIDTH/2)-1:0] tempOut;
			decoder_recursive #(.WIDTH(WIDTH/2)) decoder(.enable, .in(in[bits:1]), .out(tempOut));
			for(i = 0; i < (WIDTH); i++) begin : eachOut
				if((i % 2) == 0) begin
					// out[i] = ~in[0] & tempOut[temp]
					logic in_not;
					not #delay myNot (in_not, in[0]);
					and #delay myAnd (out[i], in_not, tempOut[i/2]);
				end else begin
					// out[i] = in[0] & tempOut[temp]
					and #delay myAnd(out[i], in[0], tempOut[i/2]);	
				end
			end
		end
	
	endgenerate
	
endmodule
