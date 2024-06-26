module Pipeline_Reg_EX_MEM (
	input clk,
	input rst,

	input regWrite_in,
	input [1:0] memtoReg_in,
	input memRead_in,
	input memWrite_in,

	input [31:0] PC_in,
	input [31:0] ALUOut_in,
	input [31:0] readData2_in,
	input [4:0] rd_in,

	output reg regWrite_out,
	output reg [1:0] memtoReg_out,
	output reg memRead_out,
	output reg memWrite_out,

	output reg [31:0] PC_out,
	output reg [31:0] ALUOut_out,
	output reg [31:0] readData2_out,
	output reg [4:0] rd_out
);

	always @(posedge clk, negedge rst) begin
		if (~rst) begin
			regWrite_out <= 0;
			memRead_out  <= 0;
			memWrite_out <= 0;
			memtoReg_out <= 0;

			PC_out <= 0;
			readData2_out <= 0;
			ALUOut_out <= 0;
			rd_out <= 0;
		end
		else begin
			regWrite_out <= regWrite_in;
			memtoReg_out <= memtoReg_in;
			memRead_out  <= memRead_in;
			memWrite_out <= memWrite_in;

			PC_out <= PC_in;
			readData2_out <= readData2_in;
			ALUOut_out <= ALUOut_in;
			rd_out <= rd_in;
		end
	end

endmodule

