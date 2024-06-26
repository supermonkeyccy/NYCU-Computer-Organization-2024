module Pipeline_Reg_MEM_WB (
	input clk,
	input rst,

	input [31:0] PC_in,
	input regWrite_in,
	input [1:0] memtoReg_in,
	input [31:0] readMemData_in,
	input [31:0] ALUOut_in,
	input [4:0] rd_in,

	output reg [31:0] PC_out,
	output reg regWrite_out,
	output reg [1:0] memtoReg_out,
	output reg [31:0] readMemData_out,
	output reg [31:0] ALUOut_out,
	output reg [4:0] rd_out
);

	always @(posedge clk, negedge rst) begin
		if (~rst) begin
			PC_out <= 0;
			regWrite_out <= 0;
			memtoReg_out <= 0;
			readMemData_out <= 0;
			ALUOut_out <= 0;
			rd_out <= 0;
		end
		else begin
			PC_out <= PC_in;
			regWrite_out <= regWrite_in;
			memtoReg_out <= memtoReg_in;
			readMemData_out <= readMemData_in;
			ALUOut_out <= ALUOut_in;
			rd_out <= rd_in;
		end
	end

endmodule

