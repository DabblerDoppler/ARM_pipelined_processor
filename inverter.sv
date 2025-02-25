`timescale 1ns/1ns

module inverter #(parameter WIDTH=64) (in, out);

	parameter delay = 50;
	input logic [WIDTH-1:0] in;
	output logic [WIDTH-1:0] out;

	genvar i;

	logic [WIDTH-1:0] Nin, internalCarry, sum;
	
	//dunno why but modelsim gets unhappy if I just use "0" and "1" instead of these logic 
	//same deal in adder.sv
	logic zero, one;
	assign zero = 0;
	assign one = 1;
	
	fullAdder firstAdder(.A(Nin[0]), .B(zero), .Cin(one), .Cout(internalCarry[0]), .sum(out[0]));

	generate
		for(i=0; i < WIDTH; i++) begin : invertLoop
			//invert the bits
			not #delay thisNot(Nin[i], in[i]);
		end
		
		for(i=1; i < WIDTH; i++) begin : addLoop
			//add one
			fullAdder thisAdder(.A(Nin[i]), .B(zero), .Cin(internalCarry[i-1]), .Cout(internalCarry[i]), .sum(out[i]));
		end
		
	endgenerate


endmodule
