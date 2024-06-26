module SingleCycleCPU (
    input clk,
    input start,
    output signed [31:0] r [0:31]
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,
// you can modify it as you wish except I/O pin and register module

// instruction & immediate
wire [31:0] instruction, immediate, offset;
// address
wire [31:0] curInstAddr, nextInstAddr, jumpInstAddr, PCin;
// control signals
wire [1:0] ALUOp, PCSel, memtoReg;
wire ALUSrc, memRead, memWrite, regWrite, zero, lessThan, condition;
// ALU
wire [3:0] ALUCtl;
wire [31:0] ALUin2, ALUOut;
// register file io
wire [31:0] writeToReg, readFromReg1, readFromReg2;
// memory io
wire [31:0] readFromMemory;


PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(PCin),
    .pc_o(curInstAddr)
);

Adder m_Adder_1(
    .a(curInstAddr),
    .b(32'h0000_0004),
    .sum(nextInstAddr)
);

InstructionMemory m_InstMem(
    .readAddr(curInstAddr),
    .inst(instruction)
);

Control m_Control(
    .opcode(instruction[6:0]),
    .PCSel(PCSel),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);

// For Student: 
// Do not change the Register instance name!
// Or you will fail validation.

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(instruction[19:15]),
    .readReg2(instruction[24:20]),
    .writeReg(instruction[11:7]),
    .writeData(writeToReg),
    .readData1(readFromReg1),
    .readData2(readFromReg2)
);

// ======= for validation ======= 
// == Dont change this section ==
assign r = m_Register.regs;
// ======= for vaildation =======

ImmGen m_ImmGen(
    .inst(instruction),
    .imm(immediate)
);

ShiftLeftOne m_ShiftLeftOne(
    .i(immediate),
    .o(offset)
);

Adder m_Adder_2(
    .a(curInstAddr),
    .b(offset),
    .sum(jumpInstAddr)
);

assign condition = (instruction[6:0] == 7'b1101111)				// jal
				|| (instruction[14:12] == 3'b000 && zero)		// beq
				|| (instruction[14:12] == 3'b001 && ~zero)		// bne
				|| (instruction[14:12] == 3'b100 && lessThan)	// blt
				|| (instruction[14:12] == 3'b101 && ~lessThan);	// bge

Mux4to1 #(.size(32)) m_Mux_PC(
    .sel({ PCSel[1], PCSel[0] && condition }),
    .s0(nextInstAddr),
    .s1(jumpInstAddr),  // branch, jal
	.s2(ALUOut), 		// jalr
    .s3(32'b0),
    .out(PCin)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc),
    .s0(readFromReg2),
    .s1(immediate),
    .out(ALUin2)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(instruction[30]),
    .funct3(instruction[14:12]),
    .ALUCtl(ALUCtl)
);

ALU m_ALU(
    .ALUctl(ALUCtl),
    .A(readFromReg1),
    .B(ALUin2),
    .ALUOut(ALUOut),
    .zero(zero),
	.lt(lessThan)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(ALUOut),
    .writeData(readFromReg2),
    .readData(readFromMemory)
);

Mux4to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(ALUOut),
    .s1(readFromMemory),
	.s2(nextInstAddr),
    .s3(32'b0),
    .out(writeToReg)
);

endmodule
