module PipelineCPU (
    input clk,
    input start,
    output signed [31:0] r [0:31]
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,
// you can modify it as you wish except I/O pin and register module

// instruction
wire [31:0] inst_IF, inst_ID;
// PC control
wire PCSel, PCWrite;

// address
wire [31:0] instAddr_IF, instAddr_ID, instAddr_EX, instAddr_MEM, instAddr_WB;
wire [31:0] nextInstAddr, jumpInstAddr, writeInstAddr, PCin;
wire [4:0] rs1_EX, rs2_EX, rd_EX, rd_MEM, rd_WB;

// immediate
wire [31:0] immediate_ID, immediate_EX;

// control signals
wire [1:0] ALUOp_ID, memtoReg_ID;
wire memRead_ID, memWrite_ID, regWrite_ID, ALUSrc_ID;
wire [1:0] ALUOp_EX, memtoReg_EX;
wire memRead_EX, memWrite_EX, regWrite_EX, ALUSrc_EX;
wire [1:0] memtoReg_MEM;
wire memRead_MEM, memWrite_MEM, regWrite_MEM;
wire [1:0] memtoReg_WB;
wire regWrite_WB;

// register file io
wire [31:0] writeToReg, readFromReg1, readFromReg2;
// correct data
wire [31:0] regData1_ID, regData1_EX;
wire [31:0] regData2_ID, regData2_EX, regData2_MEM;

// ALU
wire [3:0] ALUCtl, funct;
wire [31:0] ALUin1, ALUin2, ALUOut_EX, ALUOut_MEM, ALUOut_WB;

// memory io
wire [31:0] readFromMemory_MEM, readFromMemory_WB;

// hazard detection
wire write, flush, controlFlush;
// forwarding control
wire [1:0] ASel, BSel;
wire BJSel1, BJSel2;

// instruction fetch stage
PC m_PC(
    .clk(clk),
    .rst(start),
	.PCWrite(PCWrite),
    .pc_i(PCin),
    .pc_o(instAddr_IF)
);

Adder m_Adder_1(
    .a(instAddr_IF),
    .b(32'h0000_0004),
    .sum(nextInstAddr)
);

InstructionMemory m_InstMem(
    .readAddr(instAddr_IF),
    .inst(inst_IF)
);
// end of instruction fetch stage

Pipeline_Reg_IF_ID IF_ID(
	.clk(clk),
	.rst(start),
	.write(write),
	.flush(flush),
	.PC_in(instAddr_IF),
	.inst_in(inst_IF),
	.PC_out(instAddr_ID),
	.inst_out(inst_ID)
);

// instruction decoding stage
Control m_Control(
    .opcode(inst_ID[6:0]),
	.ALUSrc(ALUSrc_ID),
    .ALUOp(ALUOp_ID),
    .memRead(memRead_ID),
    .memWrite(memWrite_ID),
    .memtoReg(memtoReg_ID),
    .regWrite(regWrite_ID)
);

// For Student: 
// Do not change the Register instance name!
// Or you will fail validation.

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite_WB),
    .readReg1(inst_ID[19:15]),
    .readReg2(inst_ID[24:20]),
    .writeReg(rd_WB),
    .writeData(writeToReg),
    .readData1(readFromReg1),
    .readData2(readFromReg2)
);

// ======= for validation ======= 
// == Dont change this section ==
assign r = m_Register.regs;
// ======= for vaildation =======

Mux2to1 #(.size(32)) m_Mux_BJ_A(
    .sel(BJSel1),
    .s0(readFromReg1),
    .s1(ALUOut_MEM),
	.out(regData1_ID)
);

Mux2to1 #(.size(32)) m_Mux_BJ_B(
    .sel(BJSel2),
    .s0(readFromReg2),
    .s1(ALUOut_MEM),
    .out(regData2_ID)
);

BranchJump j(
	.opcode(inst_ID[6:0]),
	.Bfunct3(inst_ID[14:12]),
	.readData1(regData1_ID),
	.readData2(regData2_ID),
	.PCSel(PCSel)
);

ImmGen m_ImmGen(
    .inst(inst_ID),
    .imm(immediate_ID)
);

Adder m_Adder_2(
    .a((inst_ID[6:0] == 7'b1100111) ? regData1_ID : instAddr_ID), // jalr -> rd1
    .b(immediate_ID),
    .sum(jumpInstAddr)
);

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSel),
    .s0(nextInstAddr),
    .s1(jumpInstAddr),  // branch, jal, jalr
    .out(PCin)
);

hazardDetect hd(
	.opcode_ID(inst_ID[6:0]),
	.rs1_ID(inst_ID[19:15]),
	.rs2_ID(inst_ID[24:20]),
	.rd_EX(rd_EX),
	.rd_MEM(rd_MEM),
	.PCSel(PCSel),
	.regWrite_EX(regWrite_EX),
	.memRead_EX(memRead_EX),
	.memRead_MEM(memRead_MEM),
	.PCWrite(PCWrite),
	.IFID_write(write),
	.IFID_flush(flush),
	.controlFlush(controlFlush)
);
// end of instruction decoding stage

Pipeline_Reg_ID_EX ID_EX(
	.clk(clk),
	.rst(start),

	.controlFlush(controlFlush),

	.regWrite_in(regWrite_ID),
	.memtoReg_in(memtoReg_ID),
	.memRead_in (memRead_ID ),
	.memWrite_in(memWrite_ID),
	.ALUSrc_in  (ALUSrc_ID  ),
	.ALUOp_in   (ALUOp_ID   ),

	.PC_in(instAddr_ID),
	.readData1_in(regData1_ID),
	.readData2_in(regData2_ID),
	.immediate_in(immediate_ID),

	.funct_in({ inst_ID[30], inst_ID[14:12] }),
	.rs1_in(inst_ID[19:15]),
	.rs2_in(inst_ID[24:20]),
	.rd_in (inst_ID[11: 7]),

	.regWrite_out(regWrite_EX),
	.memtoReg_out(memtoReg_EX),
	.memRead_out (memRead_EX ),
	.memWrite_out(memWrite_EX),
	.ALUSrc_out  (ALUSrc_EX  ),
	.ALUOp_out   (ALUOp_EX   ),

	.PC_out(instAddr_EX),
	.readData1_out(regData1_EX),
	.readData2_out(regData2_EX),
	.immediate_out(immediate_EX),

	.funct_out(funct),
	.rs1_out(rs1_EX),
	.rs2_out(rs2_EX),
	.rd_out (rd_EX )
);

// execution stage
ForwardingUnit f(
	.rs1_ID(inst_ID[19:15]),
	.rs2_ID(inst_ID[24:20]),
	.rs1_EX(rs1_EX),
	.rs2_EX(rs2_EX),
	.rd_MEM(rd_MEM),
	.rd_WB(rd_WB),
	.regWrite_MEM(regWrite_MEM),
	.regWrite_WB(regWrite_WB),
	.BJSel1(BJSel1),
	.BJSel2(BJSel2),
	.ASel(ASel),
	.BSel(BSel)
);

Mux4to1 #(.size(32)) m_Mux_ALU_A(
    .sel(ASel),
    .s0(regData1_EX),
    .s1(ALUOut_MEM),
	.s2(writeToReg),
	.s3(32'b0),
    .out(ALUin1)
);

Mux4to1 #(.size(32)) m_Mux_ALU_B(
    .sel(BSel),
    .s0(regData2_EX),
    .s1(ALUOut_MEM),
	.s2(writeToReg),
	.s3(32'b0),
    .out(ALUin2)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp_EX),
    .funct(funct),
    .ALUCtl(ALUCtl)
);

ALU m_ALU(
    .ALUctl(ALUCtl),
    .A(ALUin1),
    .B(ALUSrc_EX ? immediate_EX : ALUin2),
    .ALUOut(ALUOut_EX)
);
// end of execution stage

Pipeline_Reg_EX_MEM EX_MEM(
	.clk(clk),
	.rst(start),

	.regWrite_in(regWrite_EX),
	.memtoReg_in(memtoReg_EX),
	.memRead_in (memRead_EX ),
	.memWrite_in(memWrite_EX),

	.PC_in(instAddr_EX),
	.ALUOut_in(ALUOut_EX),
	.readData2_in(ALUin2),
	.rd_in(rd_EX),

	.regWrite_out(regWrite_MEM),
	.memtoReg_out(memtoReg_MEM),
	.memRead_out (memRead_MEM ),
	.memWrite_out(memWrite_MEM),

	.PC_out(instAddr_MEM),
	.ALUOut_out(ALUOut_MEM),
	.readData2_out(regData2_MEM),
	.rd_out(rd_MEM)
);

// memory access stage
DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite_MEM),
    .memRead(memRead_MEM),
    .address(ALUOut_MEM),
    .writeData(regData2_MEM),
    .readData(readFromMemory_MEM)
);
// end of memory access stage

Pipeline_Reg_MEM_WB MEM_WB(
	.clk(clk),
	.rst(start),

	.PC_in(instAddr_MEM),
	.regWrite_in(regWrite_MEM),
	.memtoReg_in(memtoReg_MEM),
	.readMemData_in(readFromMemory_MEM),
	.ALUOut_in(ALUOut_MEM),
	.rd_in(rd_MEM),

	.PC_out(instAddr_WB),
	.regWrite_out(regWrite_WB),
	.memtoReg_out(memtoReg_WB),
	.readMemData_out(readFromMemory_WB),
	.ALUOut_out(ALUOut_WB),
	.rd_out(rd_WB)
);

// write back stage
Adder m_Adder_3(
	.a(instAddr_WB),
	.b(32'h0000_0004),
	.sum(writeInstAddr)
);

Mux4to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg_WB),
    .s0(ALUOut_WB),
    .s1(readFromMemory_WB),
	.s2(writeInstAddr),
    .s3(32'b0),
    .out(writeToReg)
);
// also in register file
// end of write back stage

endmodule

