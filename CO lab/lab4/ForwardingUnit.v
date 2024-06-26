module ForwardingUnit (
	// forward to ID for BranchJump
	input [4:0] rs1_ID,
	input [4:0] rs2_ID,
	// forward to EX for ALU
	input [4:0] rs1_EX,
	input [4:0] rs2_EX,
	// previous instruction
	input [4:0] rd_MEM,
	input [4:0] rd_WB,
	input regWrite_MEM,
	input regWrite_WB,
	// BranchJump (ID)
	output reg BJSel1,
	output reg BJSel2,
	// ALU (EX)
	output reg [1:0] ASel,
	output reg [1:0] BSel
);

	always @(*) begin
		BJSel1 = 1'b0;
		if (regWrite_MEM &&
			rd_MEM != 5'b00000 && rd_MEM == rs1_ID)
			BJSel1 = 1'b1;

		BJSel2 = 1'b0;
		if (regWrite_MEM &&
			rd_MEM != 5'b00000 && rd_MEM == rs2_ID)
			BJSel2 = 1'b1;
	end

	always @(*) begin
		ASel = 2'b00;
		// data dependency
		if (regWrite_MEM &&
			rd_MEM != 5'b00000 && rd_MEM == rs1_EX)
			ASel = 2'b01;
		// load - nop - R/I
		else if (regWrite_WB &&
			rd_WB  != 5'b00000 && rd_WB  == rs1_EX)
			ASel = 2'b10;

		BSel = 2'b00;
		// data dependency
		if (regWrite_MEM &&
			rd_MEM != 5'b00000 && rd_MEM == rs2_EX)
			BSel = 2'b01;
		// load - nop - R/I
		else if (regWrite_WB &&
			rd_WB  != 5'b00000 && rd_WB  == rs2_EX)
			BSel = 2'b10;
	end

endmodule

