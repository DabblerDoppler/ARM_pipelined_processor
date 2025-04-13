`timescale 1ps/1ps

//This is a D flip-flop with parameterized reset behaviour.

module d_flipflop #(
  parameter RESET = 1'b0
) (q, d, reset, clk);   output reg q; 
  input d, reset, clk; 
 
  always_ff @(posedge clk) 
  if (reset) 
    q <= RESET;  // On reset, set to our designated RESET parameter
  else 
    q <= d; // Otherwise out = d 
endmodule 