//Single-cycle CPU implementation
`include "instrMemory.v"
`include "dataMemory.v"
`include "programCounter.v"
`include "regfile.v"
`include "alu.v"

module cpu
(
    input clk
);

//PCSel mux
reg[1:0] PCSel;

//Program counter
wire[31:0] PCInput;
wire[31:0] PCOutput;
wire[3:0] PCLastFour;

//AdderMux
wire[31:0] adderMux1Out;
wire[31:0] adderMux2Out;
reg AdderValControl;

//Adder
wire[31:0] adderOut;

//instruction memory
wire[31:0] instrMemOut;
wire[25:0] jumpAddress;
wire[15:0] instrMemImm;
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
reg[1:0] RegDataWrSel;
reg[1:0] RegAddrWrSel;

//register
wire[31:0] regOut1;
wire[31:0] regOut2;
reg RegWrEn;

//branchControlMux
wire branchControlOut;
reg BranchControl;

//alu Mux
reg ALUImm;
wire[31:0] aluMuxOut;

//alu
wire[31:0] aluOut;
wire carryout;
wire zero;
wire overflow;
reg[2:0] command;

//Data Memory
wire[31:0] dataMemOut;
reg MemWrEn;

mux4input PCSelMux(PCInput, PCSel, {PCLastFour, jumpAddress, 2'b00}, regOut1, adderOut, adderOut);
programCounter PC(PCOutput, PCLastFour, PCInput, 1, clk);
mux2input adderMux1(adderMux1Out, branchControlOut, instrMemImm, PCOutput);
mux2input adderMux2(adderMux2Out, AdderValControl,  32'd4, 32'd8);
ALU adder(.result(adderOut), .operandA(adderMux1Out), .operandB(adderMux2Out), .command(3'd0));
instrMemory instrMem(.clk(clk), .Addr(PCOutput), .DataOut(instrMemOut), .regWE(0));
mux4input registerMux1(.out(registerMux1Out), .address(RegDataWrSel), .in0(aluOut), .in1(dataMemOut), .in3(adderOut));
mux4input registerMux2(.out(registerMux2Out), .address(RegAddrWrSel), .in0(rd), .in1(rt), .in3(5'd31));
regfile register(.ReadData1(regOut1), .ReadData2(regOut2), .WriteData(registerMux1Out), .ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(registerMux2Out), .RegWrite(RegWrEn), .Clk(clk));
mux2input aluMux(aluMuxOut, ALUImm, regOut2, instrMemImm);

initial begin
    BranchControl = 1'b1;
    AdderValControl = 1'b0;
    PCSel = 2'b10;
end

always @(posedge clk) begin
    //Decoding op code to alu operation command
    if (opCode == 6'h23) begin //lw
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'h2b) begin //sw
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b1;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'h2) begin //j
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b0;
        PCSel <= 2'b00;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'h0 && functionCode == 6'h08) begin //jr
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b0;
        PCSel <= 2'b01;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'h3) begin //jal
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b00;
        AdderValControl <= 1'b1;
        RegDataWrSel <= 2'b11;
        RegAddrWrSel <= 2'b11;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'd5) begin //bne
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b0;
        ALUImm <= 1'b1;
        command <= 3'd1;
    end
    if (opCode == 6'd14) begin //xori
        command <= 3'd2;
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b00;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'd8) begin //addi
        command <= 3'd0;
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b00;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (opCode == 6'd0 && functionCode == 6'h20) begin //add
        command <= 3'd0;
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b00;
        RegAddrWrSel <= 2'b00;
        BranchControl <= 1'b1;
        ALUImm <= 1'b0;
    end
    if (opCode == 6'd0 && functionCode == 6'h22) begin //sub
        command <= 3'd1;
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b00;
        RegAddrWrSel <= 2'b00;
        BranchControl <= 1'b1;
        ALUImm <= 1'b0;
    end
    if (opCode == 6'd0 && functionCode == 6'h2a) begin //slt
        command <= 3'd3;
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b00;
        RegAddrWrSel <= 2'b00;
        BranchControl <= 1'b1;
        ALUImm <= 1'b0;
    end 
end

ALU alu(.result(aluOut), .carryout(carryout), .zero(zero), .overflow(overflow), .operandA(regOut1), .operandB(aluMuxOut), .command(command));
mux2input #(1) branchControlMux(branchControlOut, BranchControl, ~zero, 1'b1);
dataMemory dataMem(.clk(clk), .regWE(MemWrEn), .Addr(aluOut), .DataIn(regOut2), .DataOut(dataMemOut));

endmodule
