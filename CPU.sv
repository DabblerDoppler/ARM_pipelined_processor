`timescale 1ps/1ps

module CPU(clock, reset);

parameter delay = 50;

input logic clock;

input logic reset;

logic [31:0] command;

//control logic
logic Reg2Loc, ALUSrc, MemToReg, ImmSize, RegWrite, MemWrite, BrTaken, UncondBr, LSRInUse, DEBUG, FlagsShouldSet;

// cntrl			Operation						Notes:
// 000:			result = B			value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
logic [2:0] ALUOp;

//flags
logic zeroFlag, tempZeroFlag, negativeFlag, tempNegativeFlag, overflowFlag, tempOverflowFlag, carryoutFlag, tempCarryOutFlag, CBZShouldBranch;





//____________________________________________________________________________________INSTRUCTION STUFF________________________________________________________________________________

logic [18:0] CondAddr19;
logic [25:0] BrAddr26;


//getting parts of the command necessary for variables in the instruction path.
assign CondAddr19 =  command[23:5];
assign BrAddr26 = command[25:0];

logic [63:0] PC;



logic [63:0] CondAddrExtended, BrAddrExtended,  ChosenAddr, ShiftedAddr, NextCountBranch, NextCount, NextAddr;

//sign extend our two constant friends
Sext #(.IMMLENGTH(19))  CondXtend (.in(CondAddr19), .isSigned(1'b1), .out(CondAddrExtended));
Sext  #(.IMMLENGTH(26)) BrXtend (.in(BrAddr26), .isSigned(1'b1), .out(BrAddrExtended));



genvar i;
generate
	for(i = 0; i < 64; i++) begin : eachBrAddrBit
		mux2_1 BrAddrMux (.out(ChosenAddr[i]), .i0(CondAddrExtended[i]), .i1(BrAddrExtended[i]), .sel(UncondBr));
	end
endgenerate



LinearShiftLeft #(.SHIFT(2)) AddrShifter (.in(ChosenAddr), .enable(1), .out(ShiftedAddr));

//calculate the next address
adder BranchAdder(.A(ShiftedAddr), .B(PC), .sum(NextCountBranch), .carryOut(), .overflow());
adder CountAdder (.A(PC), .B(4), .sum(NextCount), .carryOut(), .overflow());

generate
	for(i = 0; i < 64; i++) begin : eachBrSelAddrBit
		mux2_1 BrSelMux (.out(NextAddr[i]), .i0(NextCount[i]), .i1(NextCountBranch[i]), .sel(BrTaken));
	end
endgenerate

register PCRegister(.clk(clock), .in(NextAddr), .reset(reset), .enable(1'b1), .out(PC));

instructmem instructionMemory (.address(PC), .instruction(command), .clk(clock));




//____________________________________________________________________________________DATA STUFF_____________________________________________________________________________________

logic [63:0] DAddrExtended, Imm12Extended, WriteToRegister, ALU_B, Da, Db, ImmChoice, ALUResult, Dout, ALUMuxInput, LSRMuxInput;
logic [8:0] DAddr9;
logic [11:0] Imm12;

logic [4:0] Rd, Rm, Rn, Ab;

// _____________Pipeline data that might need to be declared early__________

logic [63:0] IFOut, RFAOut, RFBOut, RFWOut, EXOut, EXBOut, EXWOut, MemOut, MemWOut; 

logic [31:0] RFCommand, EXCommand, MemCommand, WBCommand;

logic [4:0] RFRd, EXRd, MemRd, WBRd, RFRm, RFRn;

logic RFRegWrite, RFMemWrite, RF, RFLSRInUse, RFMemToReg, RFReg2Loc, RFALUSrc, RFImmSize;

logic [2:0] RFALUOp;

logic EXRegWrite, EXMemWrite, EXMemToReg, EXReg2Loc, EX, EXLSRInUse;

logic [2:0] EXALUOp;

logic MemRegWrite, MemMemWrite, MemMemToReg, MemReg2Loc;

logic WBRegWrite;

logic [63:0] RF_Aa_Input, RF_Ab_Input;

logic [8:0] RF_DAddr9;
logic [11:0] RF_Imm12;


//____________________________RegFetch_______________________

//set up variables from the command for the datapath.
assign Rd = command[4:0];
assign Rm = command[20:16];
assign Rn = command[9:5];

logic [5:0] EXShAmt;

assign EXShAmt = EXCommand[15:10];
assign RF_DAddr9 = RFCommand[20:12];
assign RF_Imm12 = RFCommand[21:10];


generate
	for(i = 0; i < 5; i++) begin : eachRegisterBit
		mux2_1 aMux (.out(Ab[i]), .i0(RFRd[i]), .i1(RFRm[i]), .sel(Reg2Loc));
	end
endgenerate

regfile RegisterFile (.clk(clock), .RegWrite(WBRegWrite), .WriteData(MemOut), .WriteRegister(MemWOut), .ReadData1(Da), .ReadData2(Db), .ReadRegister1(RFRn), .ReadRegister2(Ab), .reset(reset));

//more sign extension
//IMM12 should be unsigned
Sext #(.IMMLENGTH(9)) DXtend  (.in(RF_DAddr9), .isSigned(1'b1), .out(DAddrExtended));
Sext #(.IMMLENGTH(12)) Imm12Xtend (.in(RF_Imm12), .isSigned(1'b0), .out(Imm12Extended));


//check if CBZ and/or BLT should branch
//this might need to be put through a pipeline, not sure yet
logic BLTShoudlBranch;

assign CBZShouldBranch = zeroFlag;
xor #delay (BLTShouldBranch, negativeFlag, overflowFlag);

generate
	for(i = 0; i < 64; i++) begin : eachDataBit
		//not 100% sure RFImmSize should be here
		mux2_1 ImmMux(.out(ImmChoice[i]), .i0(DAddrExtended[i]), .i1(Imm12Extended[i]), .sel(RFImmSize));
		//
		mux2_1 ALUBMux (.out(ALU_B[i]), .i0(RF_Ab_Input[i]), .i1(ImmChoice[i]), .sel(RFALUSrc));
	end
endgenerate


//____________________________EXEC_______________________

alu myALU(.A(RFAOut), .B(RFBOut), .cntrl(EXALUOp), .result(ALUMuxInput), .negative(tempNegativeFlag), .zero(tempZeroFlag), .overflow(tempOverflowFlag), .carry_out(tempCarryoutFlag));

//this is for the LSR command
LSR_64 myLSR(.in(RFAOut), .enable(EXShAmt), .out(LSRMuxInput));


generate
	for(i = 0; i < 64; i++) begin : eachALUorLSRBit
		mux2_1 ALUBMux (.out(ALUResult[i]), .i0(ALUMuxInput[i]), .i1(LSRMuxInput[i]), .sel(EXLSRInUse));
	end
endgenerate

//____________________________MEM_______________________

//xfer size can be constant for this lab since we're always passing the same size value into and out of datamem
//LDURB and other instructions will need logic in xfer_size.


datamem DataMemory (.address(EXOut), .write_enable(MemMemWrite), .read_enable(MemMemToReg), .write_data(EXBOut), .clk(clock), .xfer_size(8), .read_data(Dout));

generate
	for(i = 0; i < 64; i++) begin : eachMemOrALUBit
		mux2_1 MemOrALUMux(.out(WriteToRegister[i]), .i0(EXOut[i]), .i1(Dout[i]), .sel(MemMemToReg));
	end
endgenerate


//______________________________________________________________________________________PIPELINING____________________________________________________________________________________


logic pipelineEnable;

not #delay (pipelineEnable, reset);

//assign pipelineEnable = 1;


//data pipeline

logic [63:0] RFBypassOut;



//end of RF
register RFAReg (.clk(clock), .in(RF_Aa_Input), .reset(reset), .enable(pipelineEnable), .out(RFAOut));

register RFBReg (.clk(clock), .in(ALU_B), .reset(reset), .enable(pipelineEnable), .out(RFBOut));

register RFBypassReg (.clk(clock), .in(RF_Ab_Input), .reset(reset), .enable(pipelineEnable), .out(RFBypassOut));

register RFWReg (.clk(clock), .in(RFRd), .reset(reset), .enable(pipelineEnable), .out(RFWOut));

//end of EX
register EXReg  (.clk(clock), .in(ALUResult), .reset(reset), .enable(pipelineEnable), .out(EXOut));

register EXBReg (.clk(clock), .in(RFBypassOut), .reset(reset), .enable(pipelineEnable), .out(EXBOut));

register EXWReg (.clk(clock), .in(RFWOut), .reset(reset), .enable(pipelineEnable), .out(EXWOut));


//end of Mem
register MemReg (.clk(clock), .in(WriteToRegister), .reset(reset), .enable(pipelineEnable), .out(MemOut));

register MemWReg(.clk(clock), .in(EXWOut), .reset(reset), .enable(pipelineEnable), .out(MemWOut));



//_______________command pipeline______________________

//remember: 
//Rd = command[4:0];
//Rm = command[20:16];
//Rn = command[9:5];

//after pipelining
//rd = RFCommand[4:0];


assign RFRd = RFCommand[4:0];
assign EXRd = EXCommand[4:0];
assign MemRd = MemCommand[4:0];
assign WBRd = WBCommand[4:0];


assign RFRm = RFCommand[20:16];

assign RFRn = RFCommand[9:5];



//pass the command through the pipeline
//by resetting to one instead of 0 I'm hoping the forwarding unit won't try to forward anything since
//it'll always be at x31
register_resetToOne RFCommandReg (.clk(clock), .in(command), .reset(reset), .enable(pipelineEnable), .out(RFCommand));

register_resetToOne EXCommandReg (.clk(clock), .in(RFCommand), .reset(reset), .enable(pipelineEnable), .out(EXCommand));

register_resetToOne MemCommandReg (.clk(clock), .in(EXCommand), .reset(reset), .enable(pipelineEnable), .out(MemCommand));

register_resetToOne WBCommandReg (.clk(clock), .in(MemCommand), .reset(reset), .enable(pipelineEnable), .out(WBCommand));



//__________________control logic pipeline____________________

			/*
			BrTaken = 0;
			UncondBr = 0;
			RegWrite = 0;
			MemWrite = 0;
			FlagsShouldSet = 0;
			Reg2Loc = 0;
			ALUSrc = 0;
			LSRInUse = 0;
			ALUOp = 3'b000;
			MemToReg = 0;
			ImmSize = 0;
			*/

//these still need to be passed to the appropriate spots
//also many are unnecessary so it would be good to trim down on the hardware cost here

//there's some jank here so these control signals are one label ahead of some shit

register #(.WIDTH(1)) RFRegWriteReg        (.clk(clock), .in(RegWrite), .reset(reset), .enable(pipelineEnable), .out(RFRegWrite));
register #(.WIDTH(1)) RFMemWriteReg        (.clk(clock), .in(MemWrite), .reset(reset), .enable(pipelineEnable), .out(RFMemWrite));
register #(.WIDTH(1)) RFFlagsShouldSetReg  (.clk(clock), .in(FlagsShouldSet), .reset(reset), .enable(pipelineEnable), .out(RFFlagsShouldSet));
register #(.WIDTH(1)) RFLSRInUseReg  		 (.clk(clock), .in(LSRInUse), .reset(reset), .enable(pipelineEnable), .out(RFLSRInUse));
register #(.WIDTH(1)) RFMemToRegReg  		 (.clk(clock), .in(MemToReg), .reset(reset), .enable(pipelineEnable), .out(RFMemToReg));
register #(.WIDTH(1)) RFReg2LocReg  		 (.clk(clock), .in(Reg2Loc), .reset(reset), .enable(pipelineEnable), .out(RFReg2Loc));
//
register #(.WIDTH(1)) RFALUSrcReg  		    (.clk(clock), .in(ALUSrc), .reset(reset), .enable(pipelineEnable), .out(RFALUSrc));
register #(.WIDTH(1)) RFImmSizeReg  		 (.clk(clock), .in(ImmSize), .reset(reset), .enable(pipelineEnable), .out(RFImmSize));
//
register #(.WIDTH(3)) RFALUOpReg  			 (.clk(clock), .in(ALUOp), .reset(reset), .enable(pipelineEnable), .out(RFALUOp));


register #(.WIDTH(1)) EXRegWriteReg        (.clk(clock), .in(RFRegWrite), .reset(reset), .enable(pipelineEnable), .out(EXRegWrite));
register #(.WIDTH(1)) EXMemWriteReg        (.clk(clock), .in(RFMemWrite), .reset(reset), .enable(pipelineEnable), .out(EXMemWrite));
register #(.WIDTH(1)) EXMemToRegReg  		 (.clk(clock), .in(RFMemToReg), .reset(reset), .enable(pipelineEnable), .out(EXMemToReg));
register #(.WIDTH(1)) EXReg2LocReg  		 (.clk(clock), .in(RFReg2Loc), .reset(reset), .enable(pipelineEnable), .out(EXReg2Loc));
register #(.WIDTH(1)) EXFlagsShouldSetReg  (.clk(clock), .in(RFFlagsShouldSet), .reset(reset), .enable(pipelineEnable), .out(EXFlagsShouldSet));
register #(.WIDTH(1)) EXLSRInUseReg  		 (.clk(clock), .in(RFLSRInUse), .reset(reset), .enable(pipelineEnable), .out(EXLSRInUse));
register #(.WIDTH(3)) EXALUOpReg  			 (.clk(clock), .in(RFALUOp), .reset(reset), .enable(pipelineEnable), .out(EXALUOp));



register #(.WIDTH(1)) MemRegWriteReg       (.clk(clock), .in(EXRegWrite), .reset(reset), .enable(pipelineEnable), .out(MemRegWrite));
register #(.WIDTH(1)) MemMemWriteReg       (.clk(clock), .in(EXMemWrite), .reset(reset), .enable(pipelineEnable), .out(MemMemWrite));
register #(.WIDTH(1)) MemMemToRegReg  		 (.clk(clock), .in(EXMemToReg), .reset(reset), .enable(pipelineEnable), .out(MemMemToReg));
register #(.WIDTH(1)) MemReg2LocReg  		 (.clk(clock), .in(EXReg2Loc), .reset(reset), .enable(pipelineEnable), .out(MemReg2Loc));



register #(.WIDTH(1)) WBRegWriteReg        (.clk(clock), .in(MemRegWrite), .reset(reset), .enable(pipelineEnable), .out(WBRegWrite));




//________________________Forwarding Unit____________________

//Check if Rn (which goes into Aa) of Command (in the RF stage) is equal to Rd in each stage.

logic EqOut_Rn_RF, EqOut_Rn_EX, EqOut_Rn_Mem;

EqualityChecker_5 EQ_Rn_RF (.in0(RFRn), .in1(EXRd), .out(EqOut_Rn_RF));
EqualityChecker_5 EQ_Rn_EX (.in0(RFRn), .in1(MemRd), .out(EqOut_Rn_EX));
EqualityChecker_5 EQ_Rn_Mem (.in0(RFRn), .in1(WBRd), .out(EqOut_Rn_Mem));

//Check if Rd, which goes into Ab when Reg2Loc is false, is equal to Rd in upcoming stages. 

logic EqOut_Rd_RF, EqOut_Rd_EX, EqOut_Rd_Mem;

EqualityChecker_5 EQ_Rd_RF (.in0(RFRd), .in1(EXRd), .out(EqOut_Rd_RF));
EqualityChecker_5 EQ_Rd_EX (.in0(RFRd), .in1(MemRd), .out(EqOut_Rd_EX));
EqualityChecker_5 EQ_Rd_Mem (.in0(RFRd), .in1(WBRd), .out(EqOut_Rd_Mem));

//Check if Rm, which goes into Ab when Reg2Loc is false, is equal to Rd in each stage.

logic EqOut_Rm_RF, EqOut_Rm_EX, EqOut_Rm_Mem;

EqualityChecker_5 EQ_Rm_RF (.in0(RFRm), .in1(EXRd), .out(EqOut_Rm_RF));
EqualityChecker_5 EQ_Rm_EX (.in0(RFRm), .in1(MemRd), .out(EqOut_Rm_EX));
EqualityChecker_5 EQ_Rm_Mem (.in0(RFRm), .in1(WBRd), .out(EqOut_Rm_Mem));


//general use logic that can be compared in liu of x31
logic [4:0] DoNotWrite;

assign DoNotWrite = 31;


//___________________________Forwarding from Execution Phase____________________


//If Rn is equal to Rd in the exec stage, and we're going to write with Rd, and Rn is not x31, use the output of the ALU instead of Rn. 

logic RnCantWrite, RnCanWrite, Forward_RdExec_ToAa;

EqualityChecker_5 IsRnX31 (.in0(RFRn), .in1(DoNotWrite), .out(RnCantWrite));

not #delay (RnCanWrite, RnCantWrite);

and #delay (Forward_RdExec_ToAa, RnCanWrite, EqOut_Rn_RF, EXRegWrite);

//there should be a mux here to decide whether we use the default output or the forwarded output as ALU_A. Forward_RdExec_ToRn is the .sel of the mux.




//If Rd is equal to Rd in the exec stage, and we're going to write with Rd(exec), and Rd is not X31, and Reg2Loc is false (we're using Rd as Ab), AND aluSrc is 0, then use the output of the ALU instead of Rd.
//Otherwise, if Reg2Loc is 1, and Rm is equal to Rd in the exec stage, and we're going to write with Rd, and Rm is not X31, AND aluSrc is 0, then also use the output of the ALU instead of Rm.


logic RdCantWrite, RdCanWrite, RmCantWrite, RmCanWrite, Forward_RdExec_ToRd, Forward_RdExec_ToRm, Forward_RdExec_ToAb;

logic NotReg2Loc, NotALUSrc;

EqualityChecker_5 IsRdX31 (.in0(RFRd), .in1(DoNotWrite), .out(RdCantWrite));

not #delay (RdCanWrite, RdCantWrite);

EqualityChecker_5 IsRmX31 (.in0(RFRm), .in1(DoNotWrite), .out(RmCantWrite));

not #delay (RmCanWrite, RmCantWrite);

not #delay (NotReg2Loc, RFReg2Loc);

not #delay (NotALUSrc, RFALUSrc);


and #delay (Forward_RdExec_ToRd, EqOut_Rd_RF, EXRegWrite, RdCanWrite, NotReg2Loc, NotALUSrc);

and #delay (Forward_RdExec_ToRm, EqOut_Rm_RF, EXRegWrite, RmCanWrite, RFReg2Loc, NotALUSrc);

or #delay (Forward_RdExec_ToAb, Forward_RdExec_ToRm, Forward_RdExec_ToRd);

//need a mux here, same deal as above. 


//___________________________Forwarding from Memory Stage____________________________


//If Rn is equal to Rd in the Mem stage, and we're going to write with Rd, and Rn is not X31, use the result of the Mem stage instead of Rn as Aa.

logic Forward_RdMem_ToAa;


and #delay(Forward_RdMem_ToAa, RnCanWrite, EqOut_Rn_EX, MemRegWrite);


//mux here please



//If Rd is equal to Rd in the mem stage, and we're going to write with Rd(mem), and Rd is not X31, and Reg2Loc is false (we're using Rd as Ab), AND aluSrc is 0, then use the output of the mem stage instead of Rd.
//Otherwise, if Reg2Loc is 1, and Rm is equal to Rd in the mem stage, and we're going to write with Rd, and Rm is not X31, AND aluSrc is 0, then also use the output of the mem stage instead of Rm.

logic Forward_RdMem_ToRd, Forward_RdMem_ToRm, Forward_RdMem_ToAb;

and #delay (Forward_RdMem_ToRd, EqOut_Rd_EX, MemRegWrite, RdCanWrite, NotALUSrc, NotReg2Loc);

and #delay (Forward_RdMem_ToRm, EqOut_Rm_EX, MemRegWrite, RmCanWrite, NotALUSrc, Reg2Loc);

or #delay (Forward_RdMem_ToAb, Forward_RdMem_ToRd, Forward_RdMem_ToRm);



//Forwarding from WB stage
//I thought this wasn't going to be necessary but my WB happens at the end of the clock cycle so apparently it is.

logic Forward_RdWB_ToAa;

and #delay (Forward_RdWB_ToAa, RnCanWrite, EqOut_Rn_Mem, WBRegWrite);

logic Forward_RdWB_ToRd, Forward_RdWB_ToRm, Forward_RdWB_ToAb;

and #delay (Forward_RdWB_ToRd, EqOut_Rd_Mem, WBRegWrite, RdCanWrite, NotALUSrc, NotReg2Loc);

and #delay (Forward_RdWB_ToRm, EqOut_Rm_Mem, WBRegWrite, RmCanWrite, NotALUSrc, Reg2Loc);

or #delay (Forward_RdWB_ToAb, Forward_RdWB_ToRd, Forward_RdWB_ToRm);



//now, we need muxes to determine whether to use the forwarding from memory or exec. Exec takes precedence, so muxes using Forward_RdExec_ToAb and Forward_RdExec_ToAa as the sel should work.


logic [63:0] ForwardingChoice_Aa, ForwardingChoice_Ab;


//ALUResult is the result of the exec stage
//WriteToRegister is the result of the Mem stage

logic [63:0] MemWBForwardingChoice_Aa, MemWBForwardingChoice_Ab;

logic MemWBForward_Aa, MemWBForward_Ab;

//choose Mem or WB

generate
	for(i = 0; i < 64; i++) begin : eachMemWBForwardChoiceMux
		mux2_1 Aa_ForwardChoice_Mux (.out(MemWBForwardingChoice_Aa[i]), .i0(MemOut[i]), .i1(WriteToRegister[i]), .sel(Forward_RdMem_ToAa));
		mux2_1 Ab_ForwardChoice_Mux (.out(MemWBForwardingChoice_Ab[i]), .i0(MemOut[i]), .i1(WriteToRegister[i]), .sel(Forward_RdMem_ToAb));
	end
endgenerate

mux2_1 MemWB_Aa_ForwardChoice_Mux_e (.out(MemWBForward_Aa), .i0(Forward_RdWB_ToAa), .i1(Forward_RdMem_ToAa), .sel(Forward_RdMem_ToAa));
mux2_1 MemWB_Ab_ForwardChoice_Mux_e (.out(MemWBForward_Ab), .i0(Forward_RdWB_ToAb), .i1(Forward_RdMem_ToAb), .sel(Forward_RdMem_ToAb));

//choose previous or Exec

generate
	for(i = 0; i < 64; i++) begin : eachForwardChoiceMux
		mux2_1 Aa_ForwardChoice_Mux (.out(ForwardingChoice_Aa[i]), .i0(MemWBForwardingChoice_Aa[i]), .i1(ALUResult[i]), .sel(Forward_RdExec_ToAa));
		mux2_1 Ab_ForwardChoice_Mux (.out(ForwardingChoice_Ab[i]), .i0(MemWBForwardingChoice_Ab[i]), .i1(ALUResult[i]), .sel(Forward_RdExec_ToAb));
	end
endgenerate

//need to determine whether Exec or Mem stage was used for each

logic Forward_Aa, Forward_Ab;

//there's a cleaner way to do this but I don't have that kind of time to figure it out
mux2_1 Aa_ForwardChoice_Mux_e (.out(Forward_Aa), .i0(MemWBForward_Aa), .i1(Forward_RdExec_ToAa), .sel(Forward_RdExec_ToAa));
mux2_1 Ab_ForwardChoice_Mux_e (.out(Forward_Ab), .i0(MemWBForward_Ab), .i1(Forward_RdExec_ToAb), .sel(Forward_RdExec_ToAb));


//default input for Aa is Da
//default input for Ab is ALU_B


generate
	for(i = 0; i < 64; i++) begin : eachForwardMux
		mux2_1 Aa_ForwardChoice_Mux (.out(RF_Aa_Input[i]), .i0(Da[i]), .i1(ForwardingChoice_Aa[i]), .sel(Forward_Aa));
		mux2_1 Ab_ForwardChoice_Mux (.out(RF_Ab_Input[i]), .i0(Db[i]), .i1(ForwardingChoice_Ab[i]), .sel(Forward_Ab));
	end
endgenerate



//____________________________________________________________________________________CONTROL LOGIC___________________________________________________________________________________


typedef enum { RESET, B, BLT, CBZ, ADDI, ADDS, AND, EOR, LDUR, LSR, STUR, SUBS, ERROR } commands;

commands commandType;

//flag setters

dff_with_enable zeroDFF(.clk(clock), .in(tempZeroFlag), .reset(reset), .enable(EXFlagsShouldSet), .out(zeroFlag));
dff_with_enable coutDFF(.clk(clock), .in(tempCarryoutFlag), .reset(reset), .enable(EXFlagsShouldSet), .out(carryoutFlag));
dff_with_enable negDFF(.clk(clock), .in(tempNegativeFlag), .reset(reset), .enable(EXFlagsShouldSet), .out(negativeFlag));
dff_with_enable overflowDFF(.clk(clock), .in(tempOverflowFlag), .reset(reset), .enable(EXFlagsShouldSet), .out(overflowFlag));


always_ff @(posedge clock) begin
		if(reset) begin
			PC = 0;
			NextAddr = 0;
			command = 32'b10010001000000000000001111111111;
			DEBUG = 0;
			zeroFlag = 0;
			negativeFlag = 0;
			overflowFlag = 0;
			carryoutFlag = 0;
		end

end

//main control logic
//get ready for some nested case statements ((:
//basically checks for the smallest length commands first
always_comb begin


		case(command[31:26])
			6'b000101 : begin
				//B
				commandType = B;
				RegWrite = 0;
				MemWrite = 0;
				BrTaken = 1;
				UncondBr = 1;
				FlagsShouldSet = 0;
				
				//don't cares
				//all don't care's will be down one line in this format
				Reg2Loc = 0;
				ALUSrc = 0;
				LSRInUse = 0;
				ALUOp = 3'b000;
				MemToReg = 0;
				ImmSize = 0;
				
			end
			default: begin
				case(command[31:24])
					8'b01010100 : begin
						//B.LT
						commandType = BLT;				
						Reg2Loc = 0;
						ALUSrc = 0;
						RegWrite = 0;
						MemWrite = 0;
						LSRInUse = 0;
						BrTaken = BLTShouldBranch;
						UncondBr = 0;
						FlagsShouldSet = 0;
						ALUOp = 3'b000;
						
						
						MemToReg = 0;
						ImmSize = 0;
					end
					8'b10110100 : begin
						//CBZ
						commandType = CBZ;
						Reg2Loc = 0;
						ALUSrc = 0;
						RegWrite = 0;
						MemWrite = 0;
						LSRInUse = 0;
						FlagsShouldSet = 0;
						BrTaken = CBZShouldBranch;
						UncondBr = 0;
						ALUOp = 3'b000;
						
						
						MemToReg = 0;
						ImmSize = 0;
					end
					default: begin
						case(command[31:22])
						10'b1001000100 : begin
							//ADDI
							commandType = ADDI;
							Reg2Loc = 1;
							ALUSrc = 1;
							MemToReg = 0;
							RegWrite = 1;
							FlagsShouldSet = 0;
							MemWrite = 0;
							LSRInUse = 0;
							BrTaken = 0;
							ImmSize = 1;
							ALUOp = 3'b010;
							ImmSize = 1;
							
							UncondBr = 0;
						end
						default: begin
							case(command[31:21])
								  //10101011000
								11'b10101011000 : begin
									//ADDS
									commandType = ADDS;
									Reg2Loc = 1;
									ALUSrc = 0;
									MemToReg = 0;
									FlagsShouldSet = 1;
									RegWrite = 1;
									LSRInUse = 0;
									MemWrite = 0;
									BrTaken = 0;
									ALUOp = 3'b010;
									
									ImmSize = 0;
									UncondBr = 0;
									
								end
								11'b10001010000 : begin
									//AND
									commandType = AND;
									Reg2Loc = 1;
									ALUSrc = 0;
									FlagsShouldSet = 0;
									LSRInUse = 0;
									MemToReg = 0;
									RegWrite = 1;
									MemWrite = 0;
									BrTaken = 0;
									ALUOp = 3'b100;
									
									ImmSize = 0;
									UncondBr = 0;
								end
								11'b11001010000 : begin
									//EOR
									commandType = EOR;
									Reg2Loc = 1;
									ALUSrc = 0;
									LSRInUse = 0;
									FlagsShouldSet = 0;
									MemToReg = 0;
									RegWrite = 1;
									MemWrite = 0;
									BrTaken = 0;
									ALUOp = 3'b110;
									
									ImmSize = 0;
									UncondBr = 0;
								end
								11'b11111000010 : begin
									//LDUR
									commandType = LDUR;
									ALUSrc = 1;
									MemToReg = 1;
									LSRInUse = 0;
									RegWrite = 1;
									FlagsShouldSet = 0;
									MemWrite = 0;
									BrTaken = 0;
									ImmSize = 0;
									ALUOp = 3'b010;
									
									Reg2Loc = 0;
									UncondBr = 0;
									
								end
								11'b11010011010 : begin
									//LSR
									commandType = LSR;
									Reg2Loc = 1;
									ALUSrc = 1;
									MemToReg = 0;
									RegWrite = 1;
									FlagsShouldSet = 0;
									MemWrite = 0;
									BrTaken = 0;
									ImmSize = 1;
									LSRInUse = 1;
									
									ALUOp = 3'b000;
									UncondBr = 0;
								end
								11'b11111000000 : begin
									//STUR
									commandType = STUR;
									Reg2Loc = 0;
									ALUSrc = 1;
									FlagsShouldSet = 0;
									LSRInUse = 0;
									RegWrite = 0;
									MemWrite = 1;
									BrTaken = 0;
									//this looks wrong but not gonna change yet
									UncondBr = 1;
									ImmSize = 0;
									ALUOp = 3'b010;
									
									MemToReg = 0;
								end
								
								  //10101011000
								11'b11101011000 : begin
									//SUBS
									commandType = SUBS;
									Reg2Loc = 1;
									ALUSrc = 0;
									FlagsShouldSet = 1;
									LSRInUse = 0;
									MemToReg = 0;
									RegWrite = 1;
									MemWrite = 0;
									BrTaken = 0;
									ALUOp = 3'b011;
									
									ImmSize = 0;
									UncondBr = 0;
									
								end
								default: begin
									//error
									commandType = ERROR;		
									
									Reg2Loc = 0;
									ALUSrc = 0;
									FlagsShouldSet = 0;
									LSRInUse = 0;
									MemToReg = 0;
									RegWrite = 0;
									MemWrite = 0;
									BrTaken = 0;
									ALUOp = 3'b000;
									ImmSize = 0;
									UncondBr = 0;
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

module CPU_testbench ();

	parameter ClockDelay = 500000;


	logic					clk, reset;
	
	CPU dut (.clock(clk), .reset);
	
	initial begin // Set up the clock
		clk = 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
			//can be a lil finicky if you change reset to 0 on the clock edge so I just avoided it here
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			reset = 1; @(posedge clk); 
			reset = 0; @(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
			@(posedge clk); 
		$stop;
		
	end
endmodule

