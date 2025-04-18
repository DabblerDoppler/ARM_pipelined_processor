`timescale 1ps/1ps

//This is a gate level implementation of a D flip-flop with parameterized reset behaviour. Modeled after the 74LS74.

module d_flipflop #(
  parameter RESET = 1'b0, // default reset to 0
  parameter delay = 50  // Standard delay for gate propagation
) (q, d, reset, clk);   
	output reg q; 
	input d, reset, clk; 

	logic r, r_l, s, s_u, q_not;


and #delay (reset_final, reset, not_RESET);
not #delay (not_RESET, RESET);
and #delay (set_final, reset, RESET); 

not #delay (not_set, set_final);
not #delay (not_reset, reset_final);

nand #delay (r_l, not_reset, r, d);
nand #delay (r, r_l, clk, s);
nand #delay (s, not_reset, clk, s_u);
nand #delay (s_u, r_l, not_set, s);

nand #delay (q, not_set, s, q_not);
nand #delay (q_not, not_reset, q, r);

endmodule 