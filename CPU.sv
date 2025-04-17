//====================================================================================
// File: CPU.sv
// Description: Pipelined CPU Implementation with Forwarding
//====================================================================================
// This module implements a 5-stage pipelined CPU with the following stages:
// 1. Instruction Fetch (IF): Fetches instructions from instruction memory
// 2. Register Fetch (RF): Reads operands from register file
// 3. Execute (EX): Performs ALU operations or shift operations
// 4. Memory (MEM): Accesses data memory for loads and stores
// 5. Write Back (WB): Writes results back to register file
//
// The CPU supports the following ARM-like instructions:
// - B: Unconditional branch
// - B.LT: Branch if less than (negative ≠ overflow)
// - CBZ: Compare and branch if zero
// - ADDI: Add immediate
// - ADDS: Add and set flags
// - AND: Bitwise AND
// - EOR: Exclusive OR
// - LDUR: Load register
// - LSR: Logical shift right
// - STUR: Store register
// - SUBS: Subtract and set flags
//
// The CPU includes a forwarding unit to handle data hazards, allowing for
// back-to-back execution of dependent instructions without stalls in most cases.
//====================================================================================

`timescale 1ps/1ps

module cpu(clock, reset);

    parameter delay = 50;  // Standard delay for gate propagation

    //====================================================================================
    // PRIMARY INPUTS AND PARAMETERS
    //====================================================================================
    
    input logic clock;     // System clock
    input logic reset;     // Active high reset signal

    //====================================================================================
    // INSTRUCTION PROCESSING
    //====================================================================================
    
    // Current instruction being processed
    logic [31:0] instruction;  // Current instruction from instruction memory
    logic [31:0] instruction_temp; //instruction fetched before flushing logic
	logic [31:0] rf_instruction; //Current instruction being decoded

    // Instruction type enumeration for better readability
    typedef enum { 
        RESET, B, BLT, CBZ, ADDI, ADDS, AND, EOR, LDUR, LSR, STUR, SUBS, NOOP, ERROR 
    } instruction_type;    // Defines all supported instruction types

    instruction_type current_instruction;    // Current instruction type being processed

    //====================================================================================
    // CONTROL SIGNALS
    //====================================================================================
    
    // Main control signals
    logic reg_to_loc;          // 0: Use rd_addr as second register, 1: Use rm_addr
    logic alu_src;             // 0: Use register value for ALU B input, 1: Use immediate
    logic read_mem;          // 0: Pass ALU result to register, 1: Pass memory data
    logic imm_size;            // 0: Use 9-bit immediate, 1: Use 12-bit immediate
    logic reg_write;           // 1: Write to register file
    logic mem_write;           // 1: Write to data memory
    logic branch_taken;        // 1: Take branch
    logic uncond_branch;       // 1: Unconditional branch, 0: Conditional branch
	logic delayed_branch;      // 1: Attempt to take branch in EX for CBZ
    logic lsr_in_use;          // 1: Use LSR result instead of ALU result
    logic debug_mode;          // Debug flag for simulation
    logic flags_should_set;    // 1: Update condition flags
    logic [2:0] alu_op;        // ALU operation code

    // Condition flags
    logic zero_flag, temp_zero_flag;             // Set when result is zero
    logic negative_flag, temp_negative_flag;     // Set when result is negative
    logic overflow_flag, temp_overflow_flag;     // Set when operation causes overflow
    logic carryout_flag, temp_carryout_flag;     // Set when operation causes carry
    logic cbz_should_branch;                     // Signal for CBZ branch condition
	logic cbz_branch_taken;
    logic blt_should_branch;                     // Signal for B.LT branch condition

    //====================================================================================
    // REGISTER ADDRESSES
    //====================================================================================
    
    // Register addresses from instruction
    logic [4:0] rd_addr;               // Destination register address
    logic [4:0] rm_addr;               // Second source register address
    logic [4:0] rn_addr;               // First source register address
    logic [4:0] ab_addr;               // Selected second register address (rd_addr or rm_addr)
    
    // Register addresses in pipeline stages
    logic [4:0] rf_rd_addr;            // Destination register in RF stage
    logic [4:0] ex_rd_addr;            // Destination register in EX stage
    logic [4:0] mem_rd_addr;           // Destination register in MEM stage
    logic [4:0] wb_rd_addr;            // Destination register in WB stage
    logic [4:0] rf_rm_addr;            // Second source register in RF stage
    logic [4:0] rf_rn_addr;            // First source register in RF stage
    
    // Special register constant
    logic [4:0] do_not_write;          // Special register that can't be written to (x31)

    //====================================================================================
    // IMMEDIATE VALUES
    //====================================================================================
    
    // Immediate fields from instruction
    logic [8:0] d_addr_9;              // 9-bit immediate for memory addressing
    logic [11:0] imm_12;               // 12-bit immediate for ALU operations
    logic [18:0] cond_addr_19;         // 19-bit conditional branch address field
    logic [25:0] branch_addr_26;       // 26-bit unconditional branch address field
    logic [5:0] ex_shift_amount;       // Shift amount for LSR instruction
    
    // Immediate fields in RF stage
    logic [8:0] rf_d_addr_9;           // 9-bit immediate in RF stage
    logic [11:0] rf_imm_12;            // 12-bit immediate in RF stage

    //====================================================================================
    // DATA PATH SIGNALS
    //====================================================================================
    
    // Extended immediate values
    logic [63:0] d_addr_extended;      // Sign-extended 9-bit immediate for memory addressing
    logic [63:0] imm12_extended;       // Zero-extended 12-bit immediate for ALU operations
    logic [63:0] cond_addr_extended;   // Sign-extended conditional branch address
    logic [63:0] branch_addr_extended; // Sign-extended unconditional branch address
    logic [63:0] ex_branch_addr_extended; // Sign-extended unconditional branch address
	logic [63:0] rf_cond_addr_extended, ex_cond_addr_extended, mem_cond_addr_extended; //for cbz delayed branching
    
    // ALU and data signals
    logic [63:0] write_to_register;    // Data to be written to register file
    logic [63:0] alu_b_input;          // B input to ALU (register or immediate)
    logic [63:0] data_a;               // Data read from register file (first operand)
    logic [63:0] data_b;               // Data read from register file (second operand)
    logic [63:0] imm_choice;           // Selected immediate value based on imm_size
    logic [63:0] alu_result;           // Result of ALU operation
    logic [63:0] data_out;             // Data read from data memory
    logic [63:0] alu_mux_input;        // Direct output from ALU before LSR mux
    logic [63:0] lsr_mux_input;        // Output from LSR unit
    
    // Program counter and branch signals
    logic [63:0] program_counter;      // Current program counter value
    logic [63:0] ex_program_counter;   // 1-stage delayed pipelined program counter value
    logic [63:0] chosen_addr;          // Selected branch address based on branch type
    logic [63:0] shifted_addr;         // Branch address shifted left by 2 bits
    logic [63:0] next_count_branch;    // Next PC if branch is taken
	logic [63:0] cbz_next_branch;      // Next PC if CBZ is taken
	logic [63:0] branch_addr_final;    // Next PC if any branch is taken after pipeline
    logic [63:0] next_count;           // Next PC if branch is not taken (PC+4)
	logic [63:0] temp_addr;			   // Mux input for branch selection
    logic [63:0] next_addr;            // Final next PC value

    // Single bit pipelined branch control signals
    logic ex_uncond_branch;             // Pipelined unconditional branch signal 
    logic ex_branch_taken_final;        // Combined branch taken signal in EX stage
    logic branch_taken_final;           // Final branch taken signal after pipelining
    logic ex_cbz_branch_taken;          // CBZ branch taken signal in EX stage
    logic ex_delayed_branch;            // Delayed branch signal for CBZ in EX stage

    //====================================================================================
    // PIPELINE REGISTERS
    //====================================================================================
    
    // Pipeline enable signal
    logic pipeline_enable;             // Active when not in reset
    
    // Data pipeline registers
    logic [63:0] if_out;               // Output from IF stage
    logic [63:0] rf_a_out;             // First operand from RF stage
    logic [63:0] rf_b_out;             // Second operand from RF stage
    logic [4:0] rf_w_out;             // Destination register address from RF stage
    logic [63:0] ex_out;               // ALU/LSR result from EX stage
    logic [63:0] ex_a_out;             // Output from EX stage for operand A (needed for forwarding)
    logic [63:0] ex_b_out;             // Bypass data from EX stage (for store instructions)
    logic [4:0] ex_w_out;             // Destination register address from EX stage
    logic [63:0] mem_out;              // Data from MEM stage
    logic [4:0] mem_w_out;            // Destination register address from MEM stage
    logic [63:0] rf_bypass_out;        // Bypass data for store instructions
    
    // Instruction pipeline registers
    logic [31:0] ex_instruction;       // Instruction in EX stage
    logic [31:0] mem_instruction;      // Instruction in MEM stage
    logic [31:0] wb_instruction;       // Instruction in WB stage

    //====================================================================================
    // FORWARDING UNIT SIGNALS
    //====================================================================================
    
    // Forwarding inputs
    logic [63:0] rf_a_input;           // Input A to RF stage (possibly forwarded)
    logic [63:0] rf_b_input;           // Input B to RF stage (possibly forwarded)

    
    // Equality check results
    logic eq_rn_ex, eq_rn_mem, eq_rn_wb;    // Equality check results for rn_addr
    logic eq_rd_ex, eq_rd_mem, eq_rd_wb;    // Equality check results for rd_addr
    logic eq_rm_ex, eq_rm_mem, eq_rm_wb;    // Equality check results for rm_addr
    
    // Register writability signals
    logic rn_cant_write, rn_can_write;      // Whether rn_addr can be written to
    logic rd_cant_write, rd_can_write;      // Whether rd_addr can be written to
    logic rm_cant_write, rm_can_write;      // Whether rm_addr can be written to
    
    // Control signal inversions
    logic not_reg_to_loc, not_alu_src;      // Inverted control signals
    
    // Forwarding control signals
    // From EX stage
    logic forward_rd_exec_to_a;             // Forward from EX to A input
    logic forward_rd_exec_to_rd;            // Forward from EX to rd_addr
    logic forward_rd_exec_to_rm;            // Forward from EX to rm_addr
    logic forward_rd_exec_to_b;             // Forward from EX to B input
    
    // From MEM stage
    logic forward_rd_mem_to_a;              // Forward from MEM to A input
    logic forward_rd_mem_to_rd;             // Forward from MEM to rd_addr
    logic forward_rd_mem_to_rm;             // Forward from MEM to rm_addr
    logic forward_rd_mem_to_b;              // Forward from MEM to B input
    
    // From WB stage
    logic forward_rd_wb_to_a;               // Forward from WB to A input
    logic forward_rd_wb_to_rd;              // Forward from WB to rd_addr
    logic forward_rd_wb_to_rm;              // Forward from WB to rm_addr
    logic forward_rd_wb_to_b;               // Forward from WB to B input
    
    // Forwarding data signals
    logic [63:0] forwarding_choice_a;       // Selected data for A input
    logic [63:0] forwarding_choice_b;       // Selected data for B input
    logic [63:0] mem_wb_forwarding_choice_a; // Selected data from MEM/WB for A
    logic [63:0] mem_wb_forwarding_choice_b; // Selected data from MEM/WB for B    
    logic [63:0] ldur_forward_data;     // Selected data from MEM/WB for stur/ldur
    logic [63:0] ldur_b_forward_result; // selected data from stur/ldur muxing
    
    // Final forwarding control signals
    logic mem_wb_forward_a, mem_wb_forward_b; // Control signals for MEM/WB forwarding
    logic forward_a, forward_b;               // Final forwarding control signals

    //====================================================================================
    // PIPELINED CONTROL SIGNALS
    //====================================================================================

    
    // EX stage control signals
    logic ex_reg_write;                // Register write in EX stage
    logic ex_mem_write;                // Memory write in EX stage
    logic ex_read_mem;               // Memory to register in EX stage
    logic ex_reg_to_loc;               // Register to location in EX stage
    logic ex_flags_should_set;         // Flag update in EX stage
    logic ex_lsr_in_use;               // LSR use in EX stage
    logic [2:0] ex_alu_op;             // ALU operation in EX stage
    
    // MEM stage control signals
    logic mem_reg_write;               // Register write in MEM stage
    logic mem_mem_write;               // Memory write in MEM stage
    logic mem_read_mem;              // Memory to register in MEM stage
    logic mem_reg_to_loc;              // Register to location in MEM stage
    
    // WB stage control signals
    logic wb_reg_write;                // Register write in WB stage
    logic wb_read_mem;

    //====================================================================================
    // FLUSHING LOGIC
    //====================================================================================

    logic flush_rf;                    // When high, flush IF and ID.
    logic flush_ex;                    // When high, flush IF, ID, and EX.
    logic reset_flush_rf;              // Register .reset input, = flush_rf | flush_ex | reset
    logic reset_flush_ex;              // Register .reset input, = flush_ex | reset


    //====================================================================================
    // OPCODE CONSTANTS
    //====================================================================================

// Top 6-bit opcodes
localparam [5:0] OPCODE_B    = 6'b000101;

// Top 8-bit opcodes
localparam [7:0] OPCODE_BLT  = 8'b01010100;
localparam [7:0] OPCODE_CBZ  = 8'b10110100;

// Top 10-bit opcodes
localparam [9:0] OPCODE_ADDI = 10'b1001000100;

// Top 11-bit opcodes
localparam [10:0] OPCODE_ADDS = 11'b10101011000;
localparam [10:0] OPCODE_AND  = 11'b10001010000;
localparam [10:0] OPCODE_EOR  = 11'b11001010000;
localparam [10:0] OPCODE_LDUR = 11'b11111000010;
localparam [10:0] OPCODE_LSR  = 11'b11010011010;
localparam [10:0] OPCODE_STUR = 11'b11111000000;
localparam [10:0] OPCODE_SUBS = 11'b11101011000;

// Special opcodes
localparam [31:0] OPCODE_NOOP = 31'h91000000; // ADDI X0, X0, #0 — No-op



    //====================================================================================
    // INSTRUCTION FETCH STAGE
    //====================================================================================
    // This stage fetches instructions from instruction memory based on the program counter

    // Extract branch address fields from instruction
    assign cond_addr_19 = rf_instruction[23:5];
    assign branch_addr_26 = rf_instruction[25:0];

    // Sign extend branch address fields to 64 bits
    sign_extend #(.IMMLENGTH(19)) cond_extend   (.in(cond_addr_19),   .is_signed(1'b1), .out(cond_addr_extended));
    sign_extend #(.IMMLENGTH(26)) branch_extend (.in(branch_addr_26), .is_signed(1'b1), .out(branch_addr_extended));
	
	//pipeline for b
	register rf_addr_26_reg (.clk(clock), .in(branch_addr_extended), .reset(reset), .enable(pipeline_enable), .out(ex_branch_addr_extended));
    register #(.WIDTH(1)) rf_uncond_branch_reg (.clk(clock), .in(uncond_branch), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_uncond_branch));
    register #(.WIDTH(1)) rf_branch_taken_reg (.clk(clock), .in(branch_taken), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_branch_taken));
	register rf_pc_reg (.clk(clock), .in(program_counter), .reset(reset), .enable(pipeline_enable), .out(ex_program_counter));


	//Pipeline for cbz and conditional branches
	register rf_cond_addr_19_reg (.clk(clock), .in(cond_addr_extended), .reset(reset), .enable(pipeline_enable), .out(ex_cond_addr_extended));
	register ex_cond_addr_19_reg (.clk(clock), .in(ex_cond_addr_extended), .reset(reset), .enable(pipeline_enable), .out(mem_cond_addr_extended));
    register #(.WIDTH(1)) rf_cbz_branch_taken_reg (.clk(clock), .in(cbz_branch_taken), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_cbz_branch_taken));
	register #(.WIDTH(1)) rf_cbz_should_branch_reg (.clk(clock), .in(cbz_should_branch), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_cbz_should_branch));

    //Pipeline for all branches
	register branch_addr_final_reg (.clk(clock), .in(next_count_branch), .reset(reset), .enable(pipeline_enable), .out(branch_addr_final));
	register #(.WIDTH(1)) branch_taken_final_reg (.clk(clock), .in(ex_branch_taken_final), .reset(reset_flush_ex), .enable(pipeline_enable), .out(branch_taken_final));
	
	

    // Select between conditional and unconditional branch address
    genvar i;
    generate
        for(i = 0; i < 64; i++) begin : each_br_addr_bit
		mux2_1 branch_addr_mux (.out(temp_addr[i]), .i0(cond_addr_extended[i]), .i1(branch_addr_extended[i]), .sel(uncond_branch));
		mux2_1 cbz_addr_mux    (.out(chosen_addr[i]), .i0(temp_addr[i]), .i1(cond_addr_extended[i]),  .sel(cbz_branch_taken));
        end
    endgenerate

    // Shift the address left by 2 bits (multiply by 4 for byte addressing)
    linear_shift_left #(.SHIFT(2)) addr_shifter (.in(chosen_addr), .enable(1'b1), .out(shifted_addr));

    // Calculate the next address options
    adder branch_adder (.A(shifted_addr), .B(ex_program_counter), .sum(next_count_branch), .carryOut(), .overflow());
    adder count_adder  (.A(program_counter), .B(64'h4), .sum(next_count), .carryOut(), .overflow());
	
	or #delay (ex_branch_taken_final, branch_taken, cbz_branch_taken);
	
	//Flush logic
	or #delay (reset_flush_ex, reset, ex_cbz_branch_taken);
	or #delay (reset_flush_rf, reset, reset_flush_ex, ex_branch_taken);

    // Select between PC+4 and branch target based on branch_taken signal
    generate
        for(i = 0; i < 64; i++) begin : each_br_sel_addr_bit
            mux2_1 branch_sel_mux (.out(next_addr[i]), .i0(next_count[i]), .i1(branch_addr_final[i]), .sel(branch_taken_final));
        end
    endgenerate

        // Select between normal instruction and NO_OP for flushing
    generate
        for(i = 0; i < 64; i++) begin : each_noop_mux_bit
            mux2_1 noop_mux (.out(instruction[i]), .i0(instruction_temp[i]), .i1(OPCODE_NOOP[i]), .sel(reset_flush_rf));
        end
    endgenerate
	
	
	//if this is true, the register is 0 and cbz should branch.
	zero_checker cbz_zero_checker (.in(rf_b_input), .out(cbz_should_branch));

	//if we're at the right stage for CBZ to branch and the register it checked is 0, branch.
	//NOTE: This should be a higher priority branch than other branches because those instructions will be squashed if we take this.
	and #delay (cbz_branch_taken, delayed_branch, cbz_should_branch);
	
    // Branch condition logic for B.LT instruction
    // I likely will need to come back to this, it's a little jank

    //this is essentially a quick and dirty way to forward flags
    not (not_flags_set, ex_flags_should_set);
    and #delay (valid_negative_flag, negative_flag, not_flags_set);
    or #delay (blt_negative_flag, temp_negative_flag, valid_negative_flag);   
    and #delay (valid_overflow_flag, overflow_flag, not_flags_set);
    or #delay (blt_overflow_flag, temp_overflow_flag, valid_overflow_flag); 

    xor #delay (blt_should_branch, blt_negative_flag, blt_overflow_flag);  // B.LT branches when N≠V

    // Program counter register
    register pc_register (.clk(clock), .in(next_addr), .reset(reset), .enable(1'b1), .out(program_counter));

    // Instruction memory - fetches the instruction at the current PC
    instructmem instruction_memory (.address(program_counter), .instruction(instruction_temp), .clk(clock));
	
	

    //====================================================================================
    // REGISTER FETCH STAGE
    //====================================================================================
    // This stage reads operands from the register file and prepares them for execution

    // Extract register addresses from instruction
    assign rd_addr = rf_instruction[4:0];
    assign rm_addr = rf_instruction[20:16];
    assign rn_addr = rf_instruction[9:5];

    // Extract shift amount for LSR instruction
    assign ex_shift_amount = ex_instruction[15:10];
    
    // Extract immediate fields from instruction in RF stage
    assign rf_d_addr_9 = rf_instruction[20:12];
    assign rf_imm_12 = rf_instruction[21:10];

    // Select between rd_addr and rm_addr based on reg_to_loc for second register operand
    generate
        for(i = 0; i < 5; i++) begin : each_register_bit
            mux2_1 a_mux (.out(ab_addr[i]), .i0(rf_rd_addr[i]), .i1(rf_rm_addr[i]), .sel(reg_to_loc));
        end
    endgenerate

    // Register file - reads operands from registers
    register_file cpu_register_file (
        .clk(clock), 
        .write_enable(wb_reg_write),       // Write enable from WB stage
        .write_data(mem_out),           // Data to write from MEM stage
        .write_addr(mem_w_out[4:0]),     // Register to write to from MEM stage
        .read_data_1(data_a),            // First operand output
        .read_data_2(data_b),            // Second operand output
        .read_addr_1(rf_rn_addr),    // First register address
        .read_addr_2(ab_addr),       // Second register address
        .reset(reset)
    );

    // Sign extension for immediate values
    sign_extend #(.IMMLENGTH(9)) d_extend (.in(rf_d_addr_9), .is_signed(1'b1), .out(d_addr_extended));
    sign_extend #(.IMMLENGTH(12)) imm12_extend (.in(rf_imm_12), .is_signed(1'b0), .out(imm12_extended));

    // Select between different immediate values and register values for ALU input
    generate
        for(i = 0; i < 64; i++) begin : each_data_bit
            // Select between 9-bit and 12-bit immediate based on imm_size
            mux2_1 imm_mux (.out(imm_choice[i]), .i0(d_addr_extended[i]), .i1(imm12_extended[i]), .sel(imm_size));
            
            // Select between register value and immediate for ALU B input
            mux2_1 alu_b_mux (.out(alu_b_input[i]), .i0(rf_b_input[i]), .i1(imm_choice[i]), .sel(alu_src));
        end
    endgenerate

    //====================================================================================
    // EXECUTION STAGE
    //====================================================================================
    // This stage performs ALU operations or shift operations on the operands

    // ALU operation - performs arithmetic and logic operations
    alu main_alu (
        .A(rf_a_out),                  // First operand
        .B(rf_b_out),                  // Second operand
        .cntrl(ex_alu_op),             // ALU operation code
        .result(alu_mux_input),        // Result of operation
        .negative(temp_negative_flag), // Negative flag
        .zero(temp_zero_flag),         // Zero flag
        .overflow(temp_overflow_flag), // Overflow flag
        .carry_out(temp_carryout_flag) // Carry out flag
    );

    // Logical shift right operation for LSR instruction
    linear_shift_right_dynamic logical_shift_right (.in(rf_a_out), .shift_amount(ex_shift_amount), .out(lsr_mux_input));

    // Select between ALU and LSR results based on lsr_in_use
    generate
        for(i = 0; i < 64; i++) begin : each_alu_or_lsr_bit
            mux2_1 alu_lsr_mux (.out(alu_result[i]), .i0(alu_mux_input[i]), .i1(lsr_mux_input[i]), .sel(ex_lsr_in_use));
        end
    endgenerate

    //====================================================================================
    // MEMORY STAGE
    //====================================================================================
    // This stage accesses data memory for load and store instructions

    // Data memory access - reads or writes data based on control signals
    datamem data_memory (
        .address(ex_out),              // Memory address from EX stage
        .write_enable(mem_mem_write),  // Write enable signal
        .read_enable(mem_read_mem),  // Read enable signal
        .write_data(ex_b_out),         // Data to write for store instructions
        .clk(clock),                   // System clock
        .xfer_size(4'b1000),           // Transfer size in bytes (always 8 for this implementation)
        .read_data(data_out)           // Data read from memory
    );

    // Select between memory data and ALU result based on read_mem
    generate
        for(i = 0; i < 64; i++) begin : each_mem_or_alu_bit
            mux2_1 mem_or_alu_mux (.out(write_to_register[i]), .i0(ex_out[i]), .i1(data_out[i]), .sel(mem_read_mem));
        end
    endgenerate

    //====================================================================================
    // PIPELINE REGISTERS IMPLEMENTATION
    //====================================================================================
    // These registers pass data and control signals between pipeline stages

    // Pipeline enable signal - active when not in reset
    not #delay (pipeline_enable, reset);

    //-----------------------------------------------------------------------------------
    // Register Fetch Stage Pipeline Registers
    //-----------------------------------------------------------------------------------
    
    // RF stage data registers
    register rf_a_reg (.clk(clock), .in(rf_a_input), .reset(reset), .enable(pipeline_enable), .out(rf_a_out));
    register rf_b_reg (.clk(clock), .in(alu_b_input), .reset(reset), .enable(pipeline_enable), .out(rf_b_out));
    register rf_bypass_reg (.clk(clock), .in(rf_b_input), .reset(reset), .enable(pipeline_enable), .out(rf_bypass_out));
    register #(.WIDTH(5)) rf_w_reg (.clk(clock), .in(rf_rd_addr[4:0]), .reset(reset), .enable(pipeline_enable), .out(rf_w_out));

    //-----------------------------------------------------------------------------------
    // Execute Stage Pipeline Registers
    //-----------------------------------------------------------------------------------
    
    // EX stage data registers
    register ex_reg   (.clk(clock), .in(alu_result), .reset(reset), .enable(pipeline_enable), .out(ex_out));
	register ex_a_reg (.clk(clock), .in(rf_a_out), .reset(reset), .enable(pipeline_enable), .out(ex_a_out));
    register ex_b_reg (.clk(clock), .in(rf_bypass_out), .reset(reset), .enable(pipeline_enable), .out(ex_b_out));
    register #(.WIDTH(5)) ex_w_reg (.clk(clock), .in(rf_w_out), .reset(reset), .enable(pipeline_enable), .out(ex_w_out));

    //-----------------------------------------------------------------------------------
    // Memory Stage Pipeline Registers
    //-----------------------------------------------------------------------------------
    
    // MEM stage data registers
    register mem_reg (.clk(clock), .in(write_to_register), .reset(reset), .enable(pipeline_enable), .out(mem_out));
    register #(.WIDTH(5)) mem_w_reg (.clk(clock), .in(ex_w_out), .reset(reset), .enable(pipeline_enable), .out(mem_w_out));

    //-----------------------------------------------------------------------------------
    // Instruction Pipeline Registers
    //-----------------------------------------------------------------------------------
    
    // Extract register addresses from pipelined instructions
    assign rf_rd_addr = rf_instruction[4:0];
    assign ex_rd_addr = ex_instruction[4:0];
    assign mem_rd_addr = mem_instruction[4:0];
    assign wb_rd_addr = wb_instruction[4:0];
    assign rf_rm_addr = rf_instruction[20:16];
    assign rf_rn_addr = rf_instruction[9:5];

    // Pass the instruction through the pipeline
    // By resetting to one instead of 0, the forwarding unit won't try to forward anything
    // since it'll always be at x31 (register that can't be written to)
    register #(.RESET(1'b1), .WIDTH(32)) rf_instruction_reg (.clk(clock), .in(instruction), .reset(reset), .enable(pipeline_enable), .out(rf_instruction));
    register #(.RESET(1'b1), .WIDTH(32)) ex_instruction_reg (.clk(clock), .in(rf_instruction), .reset(reset), .enable(pipeline_enable), .out(ex_instruction));
    register #(.RESET(1'b1), .WIDTH(32)) mem_instruction_reg (.clk(clock), .in(ex_instruction), .reset(reset), .enable(pipeline_enable), .out(mem_instruction));
    register #(.RESET(1'b1), .WIDTH(32)) wb_instruction_reg (.clk(clock), .in(mem_instruction), .reset(reset), .enable(pipeline_enable), .out(wb_instruction));

    //-----------------------------------------------------------------------------------
    // Control Signal Pipeline Registers
    //-----------------------------------------------------------------------------------

    // EX stage control registers
    register #(.WIDTH(1)) ex_reg_write_reg (.clk(clock), .in(reg_write), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_reg_write));
    register #(.WIDTH(1)) ex_mem_write_reg (.clk(clock), .in(mem_write), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_mem_write));
    register #(.WIDTH(1)) ex_read_mem_reg (.clk(clock), .in(read_mem), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_read_mem));
    register #(.WIDTH(1)) ex_reg_to_loc_reg (.clk(clock), .in(reg_to_loc), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_reg_to_loc));
    register #(.WIDTH(1)) ex_flags_should_set_reg (.clk(clock), .in(flags_should_set), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_flags_should_set));
    register #(.WIDTH(1)) ex_lsr_in_use_reg (.clk(clock), .in(lsr_in_use), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_lsr_in_use));
	register #(.WIDTH(1)) ex_cbz_branch_reg (.clk(clock), .in(delayed_branch), .reset(reset_flush_rf), .enable(pipeline_enable), .out(ex_delayed_branch));
    register #(.WIDTH(3)) ex_alu_op_reg (.clk(clock), .in(alu_op), .reset(reset), .enable(pipeline_enable), .out(ex_alu_op));

    // MEM stage control registers
	register #(.WIDTH(1)) mem_cbz_branch_reg (.clk(clock), .in(ex_delayed_branch), .reset(reset_flush_ex), .enable(pipeline_enable), .out(mem_delayed_branch));
    register #(.WIDTH(1)) mem_reg_write_reg (.clk(clock), .in(ex_reg_write), .reset(reset_flush_ex), .enable(pipeline_enable), .out(mem_reg_write));
    register #(.WIDTH(1)) mem_mem_write_reg (.clk(clock), .in(ex_mem_write), .reset(reset_flush_ex), .enable(pipeline_enable), .out(mem_mem_write));
    register #(.WIDTH(1)) mem_read_mem_reg (.clk(clock), .in(ex_read_mem), .reset(reset_flush_ex), .enable(pipeline_enable), .out(mem_read_mem));
    register #(.WIDTH(1)) mem_reg_to_loc_reg (.clk(clock), .in(ex_reg_to_loc), .reset(reset_flush_ex), .enable(pipeline_enable), .out(mem_reg_to_loc));

    // WB stage control registers
    register #(.WIDTH(1)) wb_reg_write_reg (.clk(clock), .in(mem_reg_write), .reset(reset), .enable(pipeline_enable), .out(wb_reg_write));
    register #(.WIDTH(1)) wb_read_mem_reg (.clk(clock), .in(mem_read_mem), .reset(reset_flush_ex), .enable(pipeline_enable), .out(wb_read_mem));

    //====================================================================================
    // FORWARDING UNIT
    //====================================================================================
    // This unit detects and resolves data hazards by forwarding results from later
    // pipeline stages to earlier stages when dependencies are detected

    //-----------------------------------------------------------------------------------
    // Hazard Detection Logic
    //-----------------------------------------------------------------------------------
    
    // Check if rf_rn_addr (which goes into Aa) of instruction (in the RF stage) is equal to rd_addr in each stage
    equality_checker eq_rn_rf_checker (.in0(rf_rn_addr), .in1(ex_rd_addr), .out(eq_rn_ex));
    equality_checker eq_rn_ex_checker (.in0(rf_rn_addr), .in1(mem_rd_addr), .out(eq_rn_mem));
    equality_checker eq_rn_mem_checker (.in0(rf_rn_addr), .in1(wb_rd_addr), .out(eq_rn_wb));

    // Check if rd_addr, which goes into Ab when reg_to_loc is false, is equal to rd_addr in upcoming stages
    equality_checker eq_rd_rf_checker (.in0(rf_rd_addr), .in1(ex_rd_addr), .out(eq_rd_ex));
    equality_checker eq_rd_ex_checker (.in0(rf_rd_addr), .in1(mem_rd_addr), .out(eq_rd_mem));
    equality_checker eq_rd_mem_checker (.in0(rf_rd_addr), .in1(wb_rd_addr), .out(eq_rd_wb));

    // Check if rm_addr, which goes into Ab when reg_to_loc is true, is equal to rd_addr in each stage
    equality_checker eq_rm_rf_checker (.in0(rf_rm_addr), .in1(ex_rd_addr), .out(eq_rm_ex));
    equality_checker eq_rm_ex_checker (.in0(rf_rm_addr), .in1(mem_rd_addr), .out(eq_rm_mem));
    equality_checker eq_rm_mem_checker (.in0(rf_rm_addr), .in1(wb_rd_addr), .out(eq_rm_wb));

    // Register x31 is used as a special case (cannot be written to)
    assign do_not_write = 31;

    //-----------------------------------------------------------------------------------
    // Forwarding from Execution Stage
    //-----------------------------------------------------------------------------------
    
    // If rf_rn_addr is equal to rd_addr in the exec stage, and we're going to write with rd_addr, 
    // and rf_rn_addr is not x31, use the output of the ALU instead of rf_rn_addr
    equality_checker is_rn_x31 (.in0(rf_rn_addr), .in1(do_not_write), .out(rn_cant_write));
    not #delay (rn_can_write, rn_cant_write);
    and #delay (forward_rd_exec_to_a, rn_can_write, eq_rn_ex, ex_reg_write);

    // Forwarding for B input
    equality_checker is_rd_x31 (.in0(rf_rd_addr), .in1(do_not_write), .out(rd_cant_write));
    not #delay (rd_can_write, rd_cant_write);

    equality_checker is_rm_x31 (.in0(rf_rm_addr), .in1(do_not_write), .out(rm_cant_write));
    not #delay (rm_can_write, rm_cant_write);

    // Invert control signals for logic gates
    not #delay (not_reg_to_loc, reg_to_loc);
    not #delay (not_alu_src, alu_src);

    // Generate forwarding control signals for B input
    // Forward from EX stage to rd_addr when:
    // - rd_addr matches destination in EX stage
    // - EX stage will write to register file
    // - rd_addr is not x31
    // - reg_to_loc is 0 (using rd_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_exec_to_rd, eq_rd_ex, ex_reg_write, rd_can_write, not_reg_to_loc, not_alu_src_or_stur);

    or #delay (not_alu_src_or_stur, not_alu_src, mem_write);
    
    // Forward from EX stage to rm_addr when:
    // - rm_addr matches destination in EX stage
    // - EX stage will write to register file
    // - rm_addr is not x31
    // - reg_to_loc is 1 (using rm_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_exec_to_rm, eq_rm_ex, ex_reg_write, rm_can_write, reg_to_loc, not_alu_src);
    
    // Combine forwarding signals for B input
    or #delay (forward_rd_exec_to_b, forward_rd_exec_to_rm, forward_rd_exec_to_rd);

    //-----------------------------------------------------------------------------------
    // Forwarding from Memory Stage
    //-----------------------------------------------------------------------------------
    
    // Forward from MEM stage to A input when:
    // - rn_addr matches destination in MEM stage
    // - MEM stage will write to register file
    // - rn_addr is not x31
    and #delay (forward_rd_mem_to_a, rn_can_write, eq_rn_mem, mem_reg_write);

    // Forward from MEM stage to B input
    // Forward from MEM stage to rd_addr when:
    // - rd_addr matches destination in MEM stage
    // - MEM stage will write to register file
    // - rd_addr is not x31
    // - reg_to_loc is 0 (using rd_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_mem_to_rd, eq_rd_mem, mem_reg_write, rd_can_write, not_alu_src, not_reg_to_loc);
    
    // Forward from MEM stage to rm_addr when:
    // - rm_addr matches destination in MEM stage
    // - MEM stage will write to register file
    // - rm_addr is not x31
    // - reg_to_loc is 1 (using rm_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_mem_to_rm, eq_rm_mem, mem_reg_write, rm_can_write, not_alu_src, reg_to_loc);
    
    // Combine forwarding signals for B input from MEM stage
    or #delay (forward_rd_mem_to_b, forward_rd_mem_to_rd, forward_rd_mem_to_rm);

    //-----------------------------------------------------------------------------------
    // Forwarding from Writeback Stage
    //-----------------------------------------------------------------------------------
    
    // Forward from WB stage to A input when:
    // - rn_addr matches destination in WB stage
    // - WB stage will write to register file
    // - rn_addr is not x31
    and #delay (forward_rd_wb_to_a, rn_can_write, eq_rn_wb, wb_reg_write);

    // Forward from WB stage to B input
    // Forward from WB stage to rd_addr when:
    // - rd_addr matches destination in WB stage
    // - WB stage will write to register file
    // - rd_addr is not x31
    // - reg_to_loc is 0 (using rd_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_wb_to_rd, eq_rd_wb, wb_reg_write, rd_can_write, not_alu_src, not_reg_to_loc);
    
    // Forward from WB stage to rm_addr when:
    // - rm_addr matches destination in WB stage
    // - WB stage will write to register file
    // - rm_addr is not x31
    // - reg_to_loc is 1 (using rm_addr as second operand)
    // - alu_src is 0 (using register value, not immediate)
    and #delay (forward_rd_wb_to_rm, eq_rm_wb, wb_reg_write, rm_can_write, not_alu_src, reg_to_loc);
    
    // Combine forwarding signals for B input from WB stage
    or #delay (forward_rd_wb_to_b, forward_rd_wb_to_rd, forward_rd_wb_to_rm);

    //-----------------------------------------------------------------------------------
    // Forwarding Muxes
    //-----------------------------------------------------------------------------------
    
    // Choose between MEM and WB forwarding
    generate
        for(i = 0; i < 64; i++) begin : each_mem_wb_forward_choice_mux
            mux2_1 a_forward_choice_mux (.out(mem_wb_forwarding_choice_a[i]), .i0(mem_out[i]), .i1(write_to_register[i]), .sel(forward_rd_mem_to_a));
            mux2_1 b_forward_choice_mux (.out(mem_wb_forwarding_choice_b[i]), .i0(mem_out[i]), .i1(write_to_register[i]), .sel(forward_rd_mem_to_b));
        end
    endgenerate

    // Select control signals for MEM/WB forwarding
    mux2_1 mem_wb_a_forward_choice_mux_e (.out(mem_wb_forward_a), .i0(forward_rd_wb_to_a), .i1(forward_rd_mem_to_a), .sel(forward_rd_mem_to_a));
    mux2_1 mem_wb_b_forward_choice_mux_e (.out(mem_wb_forward_b), .i0(forward_rd_wb_to_b), .i1(forward_rd_mem_to_b), .sel(forward_rd_mem_to_b));

    // Choose between MEM/WB forwarding and EX forwarding
    // EX forwarding has higher priority
    generate
        for(i = 0; i < 64; i++) begin : each_forward_choice_mux
            mux2_1 a_forward_choice_mux (.out(forwarding_choice_a[i]), .i0(mem_wb_forwarding_choice_a[i]), .i1(alu_result[i]), .sel(forward_rd_exec_to_a));
            mux2_1 b_forward_choice_mux (.out(forwarding_choice_b[i]), .i0(mem_wb_forwarding_choice_b[i]), .i1(alu_result[i]), .sel(forward_rd_exec_to_b));
        end
    endgenerate

    // Determine final forwarding control signals
    or #delay(forward_a, mem_wb_forward_a, forward_rd_exec_to_a);
    or #delay(forward_b, mem_wb_forward_b, forward_rd_exec_to_b);

    // Final forwarding muxes - select between register file output and forwarded data
    generate
        for(i = 0; i < 64; i++) begin : each_forward_mux
            mux2_1 a_forward_mux (.out(rf_a_input[i]), .i0(data_a[i]), .i1(forwarding_choice_a[i]), .sel(forward_a));
            mux2_1 b_forward_mux (.out(rf_b_input[i]), .i0(data_b[i]), .i1(ldur_b_forward_result[i]), .sel(forward_b));
        end
    endgenerate

    //-----------------------------------------------------------------------------------
    // LDUR → STUR Forwarding
    //-----------------------------------------------------------------------------------

    // Match STUR's store data register (rf_rn_addr) with the destination registers
    // in MEM and WB stages, respectively
    equality_checker eq_ldur_stur_mem (.in0(rf_rn_addr), .in1(mem_rd_addr), .out(ldur_stur_eq_mem));
    equality_checker eq_ldur_stur_wb  (.in0(rf_rn_addr), .in1(wb_rd_addr),  .out(ldur_stur_eq_wb));

    // Forward loaded value from MEM stage to STUR store input (B)
    and #delay (forward_ldur_mem_to_store_b, ldur_stur_eq_mem, mem_write, mem_read_mem, mem_reg_write);

    // Forward loaded value from WB stage to STUR store input (B)
    and #delay (forward_ldur_wb_to_store_b, ldur_stur_eq_wb, mem_write, wb_read_mem, wb_reg_write);

    // Combine LDUR → STUR forwarding for B input
    or #delay (forward_ldur_to_store_b, forward_ldur_mem_to_store_b, forward_ldur_wb_to_store_b);

    // First: mux between MEM and WB loaded data
    generate
        for (i = 0; i < 64; i++) begin : ldur_data_select
            mux2_1 ldur_value_mux (
                .out(ldur_forward_data[i]),
                .i0(mem_out[i]),
                .i1(write_to_register[i]),
                .sel(forward_rd_mem_to_a) // if MEM match, use mem_out, else use WB value
            );
        end
    endgenerate

    // Choose value for STUR's store-data path: forward LDUR result or use RF B
    generate
        for (i = 0; i < 64; i++) begin : ldur_store_forward_mux
            mux2_1 store_b_ldur_mux (
                .out(ldur_b_forward_result[i]),
                .i0(forwarding_choice_b[i]),      // normal B input (already chosen from EX/MEM/WB ALU paths)
                .i1(ldur_forward_data[i]),         // use the previously mux'd LDUR value
                .sel(forward_ldur_to_store_b)     // only override for LDUR→STUR case
            );
        end
    endgenerate


    //====================================================================================
    // FLAG REGISTERS
    //====================================================================================
    // These registers store condition flags for branch instructions
    
    dff_with_enable zero_flag_dff (.clk(clock), .in(temp_zero_flag), .reset(reset), .enable(ex_flags_should_set), .out(zero_flag));
    dff_with_enable carryout_flag_dff (.clk(clock), .in(temp_carryout_flag), .reset(reset), .enable(ex_flags_should_set), .out(carryout_flag));
    dff_with_enable negative_flag_dff (.clk(clock), .in(temp_negative_flag), .reset(reset), .enable(ex_flags_should_set), .out(negative_flag));
    dff_with_enable overflow_flag_dff (.clk(clock), .in(temp_overflow_flag), .reset(reset), .enable(ex_flags_should_set), .out(overflow_flag));

    //====================================================================================
    // RESET LOGIC
	//I don't think this is necessary so it's commented out
    //====================================================================================
    // Initialize CPU state on reset
    /*
    always_ff @(posedge clock) begin
        if(reset) begin
            program_counter = 0;
            next_addr = 0;
            instruction =    OPCODE_NOOP;  // NOP instruction
            rf_instruction = OPCODE_NOOP;  // NOP instruction
            debug_mode = 0;
            zero_flag = 0;
            negative_flag = 0;
            overflow_flag = 0;
            carryout_flag = 0;
        end
    end
	*/
    //====================================================================================
    // INSTRUCTION DECODER
    //====================================================================================
    // This combinational logic decodes the instruction and sets control signals
    
always_comb begin
    case (rf_instruction[31:26])
        OPCODE_B: begin
            current_instruction = B;
            reg_write = 0;
            mem_write = 0;
            branch_taken = 1;
            uncond_branch = 1;
            flags_should_set = 0;
            delayed_branch = 0;

            reg_to_loc = 0;
            alu_src = 0;
            lsr_in_use = 0;
            alu_op = 3'b000;
            read_mem = 0;
            imm_size = 0;
        end
        default: begin
            case (rf_instruction[31:24])
                OPCODE_BLT: begin
                    current_instruction = BLT;
                    reg_to_loc = 0;
                    alu_src = 0;
                    reg_write = 0;
                    mem_write = 0;
                    lsr_in_use = 0;
                    branch_taken = blt_should_branch;
                    uncond_branch = 0;
                    delayed_branch = 0;
                    flags_should_set = 0;
                    alu_op = 3'b000;
                    read_mem = 0;
                    imm_size = 0;
                end
                OPCODE_CBZ: begin
                    current_instruction = CBZ;
                    reg_to_loc = 0;
                    alu_src = 0;
                    reg_write = 0;
                    mem_write = 0;
                    lsr_in_use = 0;
                    flags_should_set = 0;
                    branch_taken = 0;
                    uncond_branch = 0;
                    delayed_branch = 1;
                    alu_op = 3'b000;
                    read_mem = 0;
                    imm_size = 0;
                end
                default: begin
                    case (rf_instruction[31:22])
                        OPCODE_ADDI: begin
				if(rf_instruction[31:5] === OPCODE_NOOP[31:5]) begin
					current_instruction = NOOP;
				end else begin
                            		current_instruction = ADDI;
				end
                            reg_to_loc = 1;
                            alu_src = 1;
                            read_mem = 0;
                            reg_write = 1;
                            flags_should_set = 0;
                            mem_write = 0;
                            lsr_in_use = 0;
                            branch_taken = 0;
                            imm_size = 1;
                            alu_op = 3'b010;
                            delayed_branch = 0;
                            uncond_branch = 0;
                        end
                        default: begin
                            case (rf_instruction[31:21])
                                OPCODE_ADDS: begin
                                    current_instruction = ADDS;
                                    reg_to_loc = 1;
                                    alu_src = 0;
                                    read_mem = 0;
                                    flags_should_set = 1;
                                    reg_write = 1;
                                    lsr_in_use = 0;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    alu_op = 3'b010;
                                    delayed_branch = 0;
                                    imm_size = 0;
                                    uncond_branch = 0;
                                end
                                OPCODE_AND: begin
                                    current_instruction = AND;
                                    reg_to_loc = 1;
                                    alu_src = 0;
                                    flags_should_set = 0;
                                    lsr_in_use = 0;
                                    read_mem = 0;
                                    reg_write = 1;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    alu_op = 3'b100;
                                    delayed_branch = 0;
                                    imm_size = 0;
                                    uncond_branch = 0;
                                end
                                OPCODE_EOR: begin
                                    current_instruction = EOR;
                                    reg_to_loc = 1;
                                    alu_src = 0;
                                    lsr_in_use = 0;
                                    flags_should_set = 0;
                                    read_mem = 0;
                                    reg_write = 1;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    alu_op = 3'b110;
                                    delayed_branch = 0;
                                    imm_size = 0;
                                    uncond_branch = 0;
                                end
                                OPCODE_LDUR: begin
                                    current_instruction = LDUR;
                                    alu_src = 1;
                                    read_mem = 1;
                                    lsr_in_use = 0;
                                    reg_write = 1;
                                    flags_should_set = 0;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    delayed_branch = 0;
                                    imm_size = 0;
                                    alu_op = 3'b010;
                                    reg_to_loc = 0;
                                    uncond_branch = 0;
                                end
                                OPCODE_LSR: begin
                                    current_instruction = LSR;
                                    reg_to_loc = 1;
                                    alu_src = 1;
                                    read_mem = 0;
                                    reg_write = 1;
                                    flags_should_set = 0;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    delayed_branch = 0;
                                    imm_size = 1;
                                    lsr_in_use = 1;
                                    alu_op = 3'b000;
                                    uncond_branch = 0;
                                end
                                OPCODE_STUR: begin
                                    current_instruction = STUR;
                                    reg_to_loc = 0;
                                    alu_src = 1;
                                    flags_should_set = 0;
                                    lsr_in_use = 0;
                                    reg_write = 0;
                                    mem_write = 1;
                                    branch_taken = 0;
                                    uncond_branch = 1;
                                    delayed_branch = 0;
                                    imm_size = 0;
                                    alu_op = 3'b010;
                                    read_mem = 0;
                                end
                                OPCODE_SUBS: begin
                                    current_instruction = SUBS;
                                    reg_to_loc = 1;
                                    alu_src = 0;
                                    flags_should_set = 1;
                                    lsr_in_use = 0;
                                    read_mem = 0;
                                    reg_write = 1;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    delayed_branch = 0;
                                    alu_op = 3'b011;
                                    imm_size = 0;
                                    uncond_branch = 0;
                                end
                                default: begin
                                    current_instruction = ERROR;
                                    reg_to_loc = 0;
                                    alu_src = 0;
                                    flags_should_set = 0;
                                    lsr_in_use = 0;
                                    read_mem = 0;
                                    reg_write = 0;
                                    mem_write = 0;
                                    branch_taken = 0;
                                    delayed_branch = 0;
                                    uncond_branch = 0;
                                    alu_op = 3'b000;
                                    imm_size = 0;
                                end
                            endcase
                        end
                    endcase
                end
            endcase
        end
    endcase
end

endmodule

//====================================================================================
// CPU Testbench
//====================================================================================
// This module tests the CPU by applying clock and reset signals and observing behavior

module cpu_testbench();

    parameter ClockDelay = 500000;  // Clock period in picoseconds

    // Testbench signals
    logic clk, reset;
    
    // Instantiate the CPU
    cpu dut (.clock(clk), .reset);
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(ClockDelay/2) clk <= ~clk;  // Toggle clock every half period
    end
    
    // Test sequence
    integer i;
    initial begin
        // Initialize
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        
        // Apply reset
        reset = 1; @(posedge clk); 
        
        // Release reset and run
        reset = 0; @(posedge clk); 
        
        // Run for many clock cycles to observe behavior
        repeat(1500) @(posedge clk);
        
        // End simulation
        $stop;
    end
endmodule
