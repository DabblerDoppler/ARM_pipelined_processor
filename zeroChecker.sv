`timescale 1ns/1ns


module zeroChecker #(parameter WIDTH=64) (in, out);
	parameter delay = 50;

	initial assert (WIDTH > 3);

	input logic [WIDTH-1:0] in;
	output logic out;

	
	logic [31:0] temp1;
	logic [15:0] temp2;
	logic [7:0] temp3;
	logic [3:0] temp4;
	
	genvar i;
	
	generate
	
		for(i=0; i < WIDTH; i+=2) begin : firstLoop
			or #delay (temp1[i/2], in[i], in[i+1]);
		end
		for(i=0; i < WIDTH/2; i+=2) begin : secondLoop
			or #delay (temp2[i/2], temp1[i], temp1[i+1]);
		end
		for(i=0; i < WIDTH/4; i+=2) begin : thirdLoop
			or #delay (temp3[i/2], temp2[i], temp2[i+1]);
		end
		for(i=0; i < WIDTH / 8; i+=2) begin : fourthLoop
			or #delay (temp4[i/2], temp3[i], temp3[i+1]);
		end
	endgenerate
		
	
	nor #delay (out, temp4[0], temp4[1], temp4[2], temp4[3]);




/*
	logic [WIDTH-4:0] nextInput;
	
	initial begin	
		$display(WIDTH);
	end

	//check the first two bits for zero. Make a new zerochecker that checks the second two bits.
	generate
		//end case
		//this would be way more scalable if I used 2 input gates and width < 3
		//but modelsim is being a dick about recursion depth.
		if(WIDTH < 5) begin
		
		nor #delay finalNor(out, in[0], in[1], in[2], in[3]);
		
		end else begin
		
			or #delay thisOr(nextInput[0], in[0], in[1], in[2], in[3]);
			
			assign nextInput[WIDTH-4:1] = in[WIDTH-1:4];
			
			zeroChecker #(.WIDTH( WIDTH - 3 )) nextChecker(.in(nextInput), .out);
		
		end

	endgenerate

*/

endmodule


module zeroChecker_tb ();

	logic [63:0] in;
	logic out, clk;
	
	parameter ClockDelay = 500000;
	
	initial begin // Set up the clock
		clk = 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	zeroChecker dut(.in(in), .out(out));
	
	initial begin 
		@(posedge clk); 
		in = 64'b0; @(posedge clk); 
		@(posedge clk); 
		in = 64'b1; @(posedge clk); 
		@(posedge clk); 
		@(posedge clk); 
		@(posedge clk); 
		
		
		$stop;
	end
		
	
endmodule