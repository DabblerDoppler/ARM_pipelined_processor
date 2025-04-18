
`timescale 1ps/1ps

//This is a width-parameterized adder module made out of full adders. 

module adder #(parameter WIDTH = 64)(A, B, sum, carry_out, overflow);

	parameter delay = 50;
	
	initial assert (WIDTH >= 2);

	input logic[WIDTH-1:0] A, B;

	output logic[WIDTH-1:0] sum; 
	output logic carry_out, overflow;

	logic [WIDTH-1:0] internal_carry;
	
	logic zero;
	assign zero = 0;

	genvar i;

	full_adder start_adder (.A(A[0]), .B(B[0]), .c_in(zero), .c_out(internal_carry[0]), .sum(sum[0]));

	generate 
		for(i=1; i<WIDTH-1; i++) begin : middle_adders
			full_adder middle_adder (.A(A[i]), .B(B[i]), .c_in(internal_carry[i-1]), .c_out(internal_carry[i]), .sum(sum[i]));
		end
	endgenerate


	full_adder end_adder (.A(A[WIDTH-1]), .B(B[WIDTH-1]), .c_in(internal_carry[WIDTH-2]), .c_out(carryOut), .sum(sum[WIDTH-1]));
	
	
	//overflow only occurs if the two numbers being added have the same sign ~(A xor B), and the output has a different sign ~(A xor sum)
	//MSB of a 2s complement number contains the sign
	logic not_a_xor_b, a_xor_out;
	
	xnor #delay xnor1(not_a_xor_b, A[WIDTH-1], B[WIDTH-1]);
	xor #delay xor2(a_xor_out, A[WIDTH-1], sum[WIDTH-1]);
	and #delay and1(overflow, a_xor_out, not_a_xor_b);
	

	
endmodule
