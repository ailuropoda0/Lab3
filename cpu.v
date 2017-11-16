//Single-cycle CPU implementation
`include "instrMemory.v"
`include "dataMemory.v"
`include "programCounter.v"
`include "regfile.v"
`include "alu.v"
`include "signExtended.v"

module cpu
(
    input clk
);

//PCSel mux
wire[1:0] PCSel;

//Program counter
wire[31:0] PCInput;
wire[31:0] PCOutput;
wire[3:0] PCLastFour;

//AdderMux
wire[31:0] adderMux1Out;
wire[31:0] adderMux2Out;
wire AdderValControl;

//Adder
wire[31:0] adderOut;

//instruction memory
wire[31:0] instrMemOut;
wire[25:0] jumpAddress;
wire[15:0] instrMemImm;
wire[31:0] extendedInstrMemImm;
wire[5:0] opCode;
wire[4:0] rs;
wire[4:0] rt;
wire[4:0] rd;
wire[5:0] functionCode;
assign jumpAddress = instrMemOut[25:0];
assign instrMemImm = instrMemOut[15:0];
assign opCode = instrMemOut[31:26];
assign rs = instrMemOut[25:21];
assign rt = instrMemOut[20:16];
assign rd = instrMemOut[15:11];
assign functionCode = instrMemOut[5:0];

//registerMux
wire[31:0] registerMux1Out;
wire[4:0] registerMux2Out;
wire[1:0] RegDataWrSel;
wire[1:0] RegAddrWrSel;

//register
wire[31:0] regOut1;
wire[31:0] regOut2;
wire RegWrEn;

//branchControlMux
wire branchControlOut;
wire BranchControl;

//alu Mux
wire ALUImm;
wire[31:0] aluMuxOut;

//alu
wire[31:0] aluOut;
wire carryout;
wire zero;
wire overflow;
wire[2:0] command;

//Data Memory
wire[31:0] dataMemOut;
wire MemWrEn;

mux4input CSelMux(PCInput, PCSel, {PCLastFour, jumpAddress, 2'b00}, regOut1, adderOut, adderOut);
programCounter PC(PCOutput, PCLastFour, PCInput, 1, clk);
signExtended extend(extendedInstrMemImm, instrMemImm);
mux2input adderMux1(adderMux1Out, branchControlOut, extendedInstrMemImm, PCOutput);
mux2input adderMux2(adderMux2Out, AdderValControl,  32'd4, 32'd8);
ALU adder(.result(adderOut), .operandA(adderMux1Out), .operandB(adderMux2Out), .command(3'd0));
instrMemory instrMem(.clk(clk), .Addr(PCOutput[9:0]), .DataOut(instrMemOut), .regWE(0), .RegWrEn(RegWrEn), .MemWrEn(MemWrEn), .PCSel(PCSel), .AdderValControl(AdderValControl), .RegDataWrSel(RegDataWrSel), .RegAddrWrSel(RegAddrWrSel), .BranchControl(BranchControl), .ALUImm(ALUImm), .command(command));
mux4input registerMux1(.out(registerMux1Out), .address(RegDataWrSel), .in0(aluOut), .in1(dataMemOut), .in3(adderOut));
mux4input #(5) registerMux2(.out(registerMux2Out), .address(RegAddrWrSel), .in0(rd), .in1(rt), .in3(5'd31));
regfile register(.ReadData1(regOut1), .ReadData2(regOut2), .WriteData(registerMux1Out), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(registerMux2Out), .RegWrite(RegWrEn), .Clk(clk));
mux2input aluMux(aluMuxOut, ALUImm, regOut2, extendedInstrMemImm);

ALU alu(.result(aluOut), .carryout(carryout), .zero(zero), .overflow(overflow), .operandA(regOut1), .operandB(aluMuxOut), .command(command));
mux2input #(1) branchControlMux(branchControlOut, BranchControl, ~zero, 1'b1);
dataMemory dataMem(.clk(clk), .regWE(MemWrEn), .Addr(aluOut[9:0]), .DataIn(regOut2), .DataOut(dataMemOut));

endmodule
