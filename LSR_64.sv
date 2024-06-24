module LSR_64 (in, enable, out);
	input logic [63:0] in;
	input logic [5:0] enable;
	output logic [63:0] out;
	
	logic [63:0] out1, out2, out3, out4, out5;
	
	//this was gone over in class
	//this combo of shift values lets us make any shift we want up to 63.
	LinearShiftRight #(.SHIFT(1)) lsr1   (.in(in), .enable(enable[0]), .out(out1));
	LinearShiftRight #(.SHIFT(2)) lsr2   (.in(out1), .enable(enable[1]), .out(out2));
	LinearShiftRight #(.SHIFT(4)) lsr4   (.in(out2), .enable(enable[2]), .out(out3));
	LinearShiftRight #(.SHIFT(8)) lsr8   (.in(out3), .enable(enable[3]), .out(out4));
	LinearShiftRight #(.SHIFT(16)) lsr16   (.in(out4), .enable(enable[4]), .out(out5));
	LinearShiftRight #(.SHIFT(32)) lsr32   (.in(out5), .enable(enable[5]), .out(out));
	
	
	
endmodule