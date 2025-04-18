`timescale 1ps/1ps

//This is a standard implementation of a full-adder at the gate level.

module full_adder (A, B, c_in, c_out, sum);

	parameter delay = 50;

	input logic A, B, c_in;
	output logic c_out, sum;


	logic a_xor_b, a_xor_b_and_c_in, a_and_b;

	//sum = (A Xor B) Xor c_in
	xor #delay Xor1 (a_xor_b, A, B);
	xor #delay xor2 (sum, a_xor_b, c_in);


	//c_out = ((A Xor B) & c_in) | (A & B)
	and #delay and1 (a_xor_b_and_c_in, a_xor_b, c_in);
	and #delay and2 (a_and_b, A, B);
	or #delay or1 (c_out, a_and_b, a_xor_b_and_c_in);

endmodule