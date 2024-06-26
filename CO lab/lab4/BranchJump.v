module BranchJump (
	input [6:0] opcode,
	input [2:0] Bfunct3,
	input signed [31:0] readData1,
	input signed [31:0] readData2,
	output reg PCSel
);

	always @(*) begin
		if (opcode == 7'b1101111 || // jal
			opcode == 7'b1100111)	// jalr
			PCSel = 1'b1;
		else if (opcode == 7'b1100011) // branch
			case (Bfunct3)
				3'b000: // beq
					PCSel = (readData1 == readData2);
				3'b001: // bne
					PCSel = (readData1 != readData2);
				3'b100: // blt
					PCSel = (readData1 <  readData2);
				3'b101: // bge
					PCSel = (readData1 >= readData2);
				default:
					PCSel = 1'b0;
			endcase
		else
			PCSel = 1'b0;
	end

endmodule
