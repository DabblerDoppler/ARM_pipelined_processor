module mux_32 (in, read, out);
	input logic [4:0] read;
	input logic [31:0] in;
	output logic out;
	
	logic [1:0] temp;
	
	mux_16 muxNumber1 (.in(in[0:15]), .read(read[0:3]), .out(temp[0]));
	mux_16 muxNumber2 (.in(in[16:31]), .read(read[0:3]), .out(temp[1]));
	mux_2 muxFinal (.in(temp), .read(read[4]), .out);
	
endmodule

module mux_16(in, read, out);
	input logic [3:0] read;
	input logic [15:0] in;
	output logic out;
	
	logic [1:0] temp;
	
	mux_8 muxNumber1 (.in(in[0:7]), .read(read[0:2]), .out(temp[0]));
	mux_8 muxNumber2 (.in(in[8:15]), .read(read[0:2]), .out(temp[1]));
	mux_2 muxFinal (.in(temp), .read(read[3]), .out);
	
	
endmodule

module mux_8(in, read, out);
	input logic [2:0] read;
	input logic [7:0] in;
	output logic out;
	
	logic [1:0] temp;
	
	mux_4 muxNumber1 (.in(in[0:3]), .read(read[0:1]), .out(temp[0]));
	mux_4 muxNumber2 (.in(in[4:7]), .read(read[0:1]), .out(temp[1]));
	mux_2 muxFinal (.in(temp), .read(read[2]), .out);
	
	
endmodule


module mux_4(in, read, out);
	input logic [1:0] read;
	input logic [3:0] in;
	output logic out;
	
	logic [1:0] temp;
	
	mux_2 muxNumber1 (.in(in[0:1]), .read(read[0]), .out(temp[0]));
	mux_2 muxNumber2 (.in(in[2:3]), .read(read[0]), .out(temp[1]));
	mux_2 muxFinal (.in(temp), .read(read[1]), .out);
	
	
endmodule
	
	
module mux_2 (in, read, out);
	input logic read;
	input logic [1:0] in;
	output logic out;
	
	always_comb begin
		out = (in[0] & ~read) | (in[1] & read);
	end
	
endmodule
	
	