//Instruction memory
module instrMemory
(
  input clk, regWE, // clock, register Write Enable
  input[9:0] Addr,
  input[31:0] DataIn,
  output[31:0]  DataOut,
  // control signal
    output reg RegWrEn,
    output reg MemWrEn,
    output reg[1:0] PCSel,
    output reg AdderValControl,
    output reg[1:0] RegDataWrSel,
    output reg[1:0] RegAddrWrSel,
    output reg BranchControl,
    output reg ALUImm,
    output reg[2:0] command
);
  
  reg [31:0] mem[1023:0];  
  
  always @(posedge clk) begin
    if (regWE) begin
      mem[Addr] <= DataIn;
    end
  end
  
  initial $readmemh("subTest.dat", mem);
   
  initial begin
    BranchControl = 1'b1;
    AdderValControl = 1'b0;
    PCSel = 2'b10;
  end
 
  assign DataOut = mem[Addr>>2];

    always @(negedge clk) begin 
    //Decoding op code to alu operation command
    if (DataOut[31:26] == 6'h23) begin //lw
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (DataOut[31:26] == 6'h2b) begin //sw
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b1;
        PCSel <= 2'b10;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (DataOut[31:26] == 6'h2) begin //j
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b0;
        PCSel <= 2'b00;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (DataOut[31:26] == 6'h0 && DataOut[5:0] == 6'h08) begin //jr
        RegWrEn <= 1'b0;
        MemWrEn <= 1'b0;
        PCSel <= 2'b01;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b01;
        RegAddrWrSel <= 2'b01;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (DataOut[31:26] == 6'h3) begin //jal
        RegWrEn <= 1'b1;
        MemWrEn <= 1'b0;
        PCSel <= 2'b00;
        AdderValControl <= 1'b0;
        RegDataWrSel <= 2'b11;
        RegAddrWrSel <= 2'b11;
        BranchControl <= 1'b1;
        ALUImm <= 1'b1;
    end
    if (DataOut[31:26] == 6'd5) begin //bne
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
    if (DataOut[31:26] == 6'd14) begin //xori
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
    if (DataOut[31:26] == 6'd8) begin //addi
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
    if (DataOut[31:26] == 6'd0 && DataOut[5:0] == 6'h20) begin //add
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
    if (DataOut[31:26] == 6'd0 && DataOut[5:0] == 6'h22) begin //sub
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
    if (DataOut[31:26] == 6'd0 && DataOut[5:0] == 6'h2a) begin //slt
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
endmodule
