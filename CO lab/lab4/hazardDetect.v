module hazardDetect(
	input [6:0] opcode_ID,
	input [4:0] rs1_ID,
	input [4:0] rs2_ID,
	input [4:0] rd_EX,
	input [4:0] rd_MEM,
	input PCSel,
	input regWrite_EX,
	input memRead_EX,
	input memRead_MEM,
	output reg PCWrite,
	output reg IFID_write,
	output reg IFID_flush,
	output reg controlFlush
);

	always @(*) begin
		// load : stall * 1 + forwarding
		if (memRead_EX && (rd_EX == rs1_ID || rd_EX == rs2_ID)) begin
			PCWrite = 1'b0;
			IFID_write = 1'b0;
			IFID_flush = 1'b0;
			controlFlush = 1'b1;
		end

		// load - nop - B
		else if ((opcode_ID == 7'b1100011 || opcode_ID == 7'b1100111) && memRead_MEM && (rd_MEM == rs1_ID || rd_MEM == rs2_ID)) begin
			PCWrite = 1'b0;
			IFID_write = 1'b0;
			IFID_flush = 1'b0;
			controlFlush = 1'b1;
		end

		// R/I - B
		else if ((opcode_ID == 7'b1100011 || opcode_ID == 7'b1100111) && (!memRead_EX) && regWrite_EX && (rd_EX == rs1_ID || rd_EX == rs2_ID)) begin
			PCWrite = 1'b0;
			IFID_write = 1'b0;
			IFID_flush = 1'b0;
			controlFlush = 1'b1;
		end

		// B/J flush
		else if (PCSel) begin
			PCWrite = 1'b1;
			IFID_write = 1'b0;
			IFID_flush = 1'b1;
			controlFlush = 1'b0;
		end

		// normal cases
		else begin
			PCWrite = 1'b1;
			IFID_write = 1'b1;
			IFID_flush = 1'b0;
			controlFlush = 1'b0;
		end
	end

endmodule

