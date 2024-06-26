module Pipeline_Reg_IF_ID (
	input clk,
	input rst,
	input write,
	input flush,
	input [31:0] PC_in,
	input [31:0] inst_in,
	output reg [31:0] PC_out,
	output reg [31:0] inst_out
);

	always @(posedge clk, negedge rst) begin
		if (~rst || flush) begin
			PC_out <= 0;
			inst_out <= 0;
		end
		else if (write) begin
			PC_out <= PC_in;
			inst_out <= inst_in;
		end
	end

endmodule

