`timescale 1ps/1ps

//this is a basic 2 to 1 multiplexer with a single bit for selection.

module mux2_1 (out, i0, i1, sel);
	parameter delay = 50;
	input logic i0, i1, sel;
	output logic out;

	//assign out = (i1 & sel) | (i0 & ~sel);
	
	logic i1AndSel, NotSel,  i0AndNotSel;
	
	and #delay (i1AndSel, i1, sel);
	not #delay (NotSel, sel);
	and #delay (i0AndNotSel, i0, NotSel);
	or #delay (out, i0AndNotSel, i1AndSel);
	
	
endmodule

module mux2_1_testbench();   
  logic i0, i1, sel;    
  logic out;   
     
  mux2_1 dut (.out, .i0, .i1, .sel);   
   
  initial begin   
    sel=0; i0=0; i1=0; #10;    
    sel=0; i0=0; i1=1; #10;    
    sel=0; i0=1; i1=0; #10;    
    sel=0; i0=1; i1=1; #10;    
    sel=1; i0=0; i1=0; #10;    
    sel=1; i0=0; i1=1; #10;    
    sel=1; i0=1; i1=0; #10;    
    sel=1; i0=1; i1=1; #10;    
  end   
endmodule