`timescale 1ps/1ps

//This is a standard implementation of a full-adder at the gate level.

module full_adder (A, B, Cin, Cout, sum);

	parameter delay = 50;

	input logic A, B, Cin;
	output logic Cout, sum;


	logic AXorB, AXorBAndCin, AAndB;

	//sum = (A Xor B) Xor Cin
	xor #delay Xor1 (AXorB, A, B);
	xor #delay xor2 (sum, AXorB, Cin);


	//Cout = ((A Xor B) & Cin) | (A & B)
	and #delay and1 (AXorBAndCin, AXorB, Cin);
	and #delay and2 (AAndB, A, B);
	or #delay or1 (Cout, AAndB, AXorBAndCin);

endmodule