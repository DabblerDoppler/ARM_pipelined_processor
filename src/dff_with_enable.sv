//This is a d flip-flop which has an enable telling it when it can write new data.
//It also inherits the parametrized reset to 0 or 1 from the other d_flipflop module.

`timescale 1ps/1ps
module dff_with_enable #(
	parameter RESET = 1'b0
)(clk, in, reset, enable, out);

	parameter delay = 50;
	
	output logic out;
	input logic clk, reset, in, enable;
	
	logic nextVal;
	
	logic notEnable;
	logic notEnableAndOut;
	logic inAndEnable;
	
	not #delay myNot(notEnable, enable);
	and #delay myAnd_1(notEnableAndOut, notEnable, out);
	and #delay myAnd_2(inAndEnable, in, enable);
	or #delay myOr(nextVal, notEnableAndOut, inAndEnable);
	

	d_flipflop #(.RESET(RESET)) dflipflop (.q(out), .d(nextVal), .reset(reset), .clk(clk));	

endmodule
