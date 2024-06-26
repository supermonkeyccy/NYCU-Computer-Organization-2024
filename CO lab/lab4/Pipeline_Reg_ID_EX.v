module Pipeline_Reg_ID_EX (
	input clk,
	input rst,
	// control signals
	input controlFlush,
	input regWrite_in,
	input [1:0] memtoReg_in,
	input memRead_in,
	input memWrite_in,
	input ALUSrc_in,
	input [1:0] ALUOp_in,
	// data
	input [31:0] PC_in,
	input [31:0] readData1_in,
	input [31:0] readData2_in,
	input [31:0] immediate_in,
	// decoded instruction
	input [3:0] funct_in, // [30, 14:12]
	input [4:0] rs1_in,
	input [4:0] rs2_in,
	input [4:0] rd_in,
	// output
	// control signals
	output reg regWrite_out,
	output reg [1:0] memtoReg_out,
	output reg memRead_out,
	output reg memWrite_out,
	output reg ALUSrc_out,
	output reg [1:0] ALUOp_out,
	// data
	output reg [31:0] PC_out,
	output reg [31:0] readData1_out,
	output reg [31:0] readData2_out,
	output reg [31:0] immediate_out,
	// decoded instruction
	output reg [3:0] funct_out,
	output reg [4:0] rs1_out,
	output reg [4:0] rs2_out,
	output reg [4:0] rd_out
);

	always @(posedge clk, negedge rst) begin
		if (~rst) begin
			regWrite_out <= 0;
			memRead_out <= 0;
			memWrite_out <= 0;
			memtoReg_out <= 0;
			ALUSrc_out <= 0;
			ALUOp_out <= 0;

			PC_out <= 0;
			readData1_out <= 0;
			readData2_out <= 0;
			immediate_out <= 0;

			funct_out <= 0;
			rs1_out <= 0;
			rs2_out <= 0;
			rd_out <= 0;
		end
		else if (controlFlush) begin
			regWrite_out <= 0;
			memRead_out <= 0;
			memWrite_out <= 0;
			memtoReg_out <= 0;
			ALUSrc_out <= 0;
			ALUOp_out <= 0;

			PC_out <= PC_in;
			readData1_out <= readData1_in;
			readData2_out <= readData2_in;
			immediate_out <= immediate_in;

			funct_out <= funct_in;
			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			rd_out <= rd_in;
		end
		else begin
			regWrite_out <= regWrite_in;
			memtoReg_out <= memtoReg_in;
			memRead_out <= memRead_in;
			memWrite_out <= memWrite_in;
			ALUSrc_out <= ALUSrc_in;
			ALUOp_out <= ALUOp_in;

			PC_out <= PC_in;
			readData1_out <= readData1_in;
			readData2_out <= readData2_in;
			immediate_out <= immediate_in;

			funct_out <= funct_in;
			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			rd_out <= rd_in;
		end
	end

endmodule

