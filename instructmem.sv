// Instruction ROM.  Supports reads only, but is initialized based upon the file specified.
// All accesses are 32-bit.  Addresses are byte-addresses, and must be word-aligned (bottom
// two words of the address must be 0).
//
// To change the file that is loaded, edit the filename here:
//`define BENCHMARK "benchmarks/test01_AddiB.arm"
//`define BENCHMARK "benchmarks/test02_AddsSubs.arm"
`define BENCHMARK "benchmarks/test03_CbzB.arm"
//`define BENCHMARK "benchmarks/test04_LdurStur.arm"
//`define BENCHMARK "benchmarks/test05_Blt.arm"
//`define BENCHMARK "benchmarks/test06_AndEorLsr.arm"
//`define BENCHMARK "benchmarks/test10_forwarding.arm"
//`define BENCHMARK "benchmarks/test11_Sort.arm"
//`define BENCHMARK "benchmarks/test12_CRC16.arm"

//01 expected: 
// X0 = 0
// X1 = 1
// X2 = 2
// X3 = 3
// X4 = 4

//02 expected:
// X0 =  1
// X1 = -1
// X2 =  2
// X3 = -3
// X4 = -2
// X5 = -5
// X6 = 0
// X7 = -6
// Flags: negative = 1, carry-out = 1, overflow = 0, zero = 0

//03 expected
// X0 = 1
// X1 = 0 (anything else indicates an error)
// X2 = 0 on a single-cycle CPU, 4 on pipelined CPUs (counts delay slots executed)
// X3 = 1 (signifies program end was reached)
// X4 = 16+8+4+2+1 = 31 (bit per properly executed branch)
// X5 = 0 (should never get incremented, means accelerated branches not working).

//04 expected
// X0 = 1
// X1 = 2
// X2 = 3
// X3 = 8
// X4 = 11
// X5 = 1
// X6 = 2
// X7 = 3
// Mem[0] = 1
// Mem[8] = 2
// Mem[16] = 3

//05 expected
// X0 =  1
// X1 =  1

//06 expected
// X0 = 0xACE // 2766
// X1 = 0xA   // 10
// X2 = 0xC   // 12
// X3 = 0x0   // 0

//10 expected
// X0 = 0
// X1 = 8
// X2 = 4 (on pipelined CPU), or 0 (single-cycle CPU).
// X3 = 5
// X4 = 7
// X5 = 2
// X6 = -2
// X7 = -2  
// X8 = 0
// X9 = 1
// X10 = -4
// X14 = 5
// X15 = 8
// X16 = 9
// X17 = 1
// X18 = 99
// Mem[0] = 8
// Mem[8] = 5

//11 expected
// X11      =  1
// X12      =  2
// X13      =  3
// X14      =  4
// X15      =  5
// X16      =  6
// X17      =  7
// X18      =  8
// X19      =  9
// X20      = 10

//12 expected
//X0  = 0xA001 (CRC polynomial)
//X1  = 0x9476 (CRC for string "String 01234")
//X2  = 0xC
//X3  = 0x60
//X4  = 0x8
//X5  = 0x0
//X6  = 0x1
//X7  = 0x0
//X8  = 0x1
//X9  = 0xC
//X10 = 0x8


`timescale 1ns/10ps

// How many bytes are in our memory?  Must be a power of two.
`define INSTRUCT_MEM_SIZE		1024
	
module instructmem (
	input		logic		[63:0]	address,
	output	logic		[31:0]	instruction,
	input		logic					clk	// Memory is combinational, but used for error-checking
	);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	// Make sure size is a power of two and reasonable.
	initial assert((`INSTRUCT_MEM_SIZE & (`INSTRUCT_MEM_SIZE-1)) == 0 && `INSTRUCT_MEM_SIZE > 4);
	
	// Make sure accesses are reasonable.
	always_ff @(posedge clk) begin
		if (address !== 'x) begin // address or size could be all X's at startup, so ignore this case.
			assert(address[1:0] == 0);	// Makes sure address is aligned.
			assert(address + 3 < `INSTRUCT_MEM_SIZE);	// Make sure address in bounds.
		end
	end
	
	// The data storage itself.
	logic [31:0] mem [`INSTRUCT_MEM_SIZE/4-1:0];
	
	// Load the program - change the filename to pick a different program.
	initial begin
		$readmemb(`BENCHMARK, mem);
		$display("Running benchmark: ", `BENCHMARK);
	end
	
	// Handle the reads.
	integer i;
	always_comb begin
		if (address + 3 >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address/4];
	end
		
endmodule

module instructmem_testbench ();

	parameter ClockDelay = 5000;

	logic		[63:0]	address;
	logic					clk;
	logic		[31:0]	instruction;
	
	instructmem dut (.address, .instruction, .clk);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		// Read every location, including just past the end of the memory.
		for (i=0; i <= `INSTRUCT_MEM_SIZE; i = i + 4) begin
			address <= i;
			@(posedge clk); 
		end
		$stop;
		
	end
endmodule
