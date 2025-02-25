`timescale 1ps/1ps
module DFF_ResetToOne (q, d, reset, clk);   output reg q; 
  input d, reset, clk; 
 
  always_ff @(posedge clk) 
  if (reset) 
    q <= 1;  // On reset, set to 1 
  else 
    q <= d; // Otherwise out = d 
endmodule 