`timescale 1ns/1ns

//This module is a parameter-scalable inverter which NOTs all of the input bits, then adds one. 
//This is  useful for subtracting instead of adding. 

module inverter #(parameter WIDTH=64) (in, out);

	parameter delay = 50;
	input logic [WIDTH-1:0] in;
	output logic [WIDTH-1:0] out;

	genvar i;

	logic [WIDTH-1:0] not_in, carry, sum;

	logic zero, one;
	assign zero = 0;
	assign one = 1;
	
	full_adder first_adder(.A(not_in[0]), .B(zero), .c_in(one), .c_out(carry[0]), .sum(out[0]));

	generate
		for(i=0; i < WIDTH; i++) begin : invertLoop
			//invert the bits
			not #delay thisNot(not_in[i], in[i]);
		end
		
		for(i=1; i < WIDTH; i++) begin : addLoop
			//add one
			full_adder this_adder(.A(not_in[i]), .B(zero), .c_in(carry[i-1]), .c_out(carry[i]), .sum(out[i]));
		end
		
	endgenerate


endmodule
