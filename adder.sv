//needs zero

`timescale 1ps/1ps

module adder #(parameter WIDTH = 64)(A, B, sum, carryOut, overflow);

	parameter delay = 50;
	
	initial assert (WIDTH >= 2);

	input logic[WIDTH-1:0] A, B;

	output logic[WIDTH-1:0] sum; 
	output logic carryOut, overflow;

	logic [WIDTH-1:0] internalCarry;
	
	//modelsim gets pissy if I use "0" and "1".
	logic zero;
	assign zero = 0;

	genvar i;

	fullAdder adder0 (.A(A[0]), .B(B[0]), .Cin(zero), .Cout(internalCarry[0]), .sum(sum[0]));

	generate 
		for(i=1; i<WIDTH-1; i++) begin : eachFullAdder
			fullAdder thisAdder (.A(A[i]), .B(B[i]), .Cin(internalCarry[i-1]), .Cout(internalCarry[i]), .sum(sum[i]));
		end
	endgenerate


	fullAdder adderLast (.A(A[WIDTH-1]), .B(B[WIDTH-1]), .Cin(internalCarry[WIDTH-2]), .Cout(carryOut), .sum(sum[WIDTH-1]));
	
	
	//overflow only occurs if the two numbers being added have the same sign ~(A xor B), and the output has a different sign ~(A xor sum)
	//MSB of a 2s complement number contains the sign
	logic NotAXorB, AXorOut;
	
	xnor #delay xnor1(NotAXorB, A[WIDTH-1], B[WIDTH-1]);
	xor #delay xor2(AXorOut, A[WIDTH-1], sum[WIDTH-1]);
	and #delay and1(overflow, AXorOut, NotAXorB);
	

	
endmodule
