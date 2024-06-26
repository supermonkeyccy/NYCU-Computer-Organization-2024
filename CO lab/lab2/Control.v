module Control (
    input [6:0] opcode,
    output reg [1:0] PCSel,
    output reg memRead,
    output reg [1:0] memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite
);

    // TODO: implement your Control here
    // Hint: follow the Architecture (figure in spec) to set output signal
    always @(*) begin
		case(opcode)
			7'b0110011: begin // R type
				ALUSrc   = 1'b0;
				memtoReg = 2'b00;
				regWrite = 1'b1;
				memRead  = 1'b0;
				memWrite = 1'b0;
				PCSel    = 2'b00;
				ALUOp    = 2'b10;
			end
			7'b0000011: begin // load
				ALUSrc   = 1'b1;
				memtoReg = 2'b01;
				regWrite = 1'b1;
				memRead  = 1'b1;
				memWrite = 1'b0;
				PCSel    = 2'b00;
				ALUOp    = 2'b00;
			end
			7'b0100011: begin // store
				ALUSrc   = 1'b1;
				memtoReg = 2'bxx;
				regWrite = 1'b0;
				memRead  = 1'b0;
				memWrite = 1'b1;
				PCSel    = 2'b00;
				ALUOp    = 2'b00;
			end
			7'b1100011: begin // branch
				ALUSrc   = 1'b0;
				memtoReg = 2'bxx;
				regWrite = 1'b0;
				memRead  = 1'b0;
				memWrite = 1'b0;
				PCSel    = 2'b01;
				ALUOp    = 2'b01;
			end
			7'b0010011: begin // I type
				ALUSrc   = 1'b1;
				memtoReg = 2'b00;
				regWrite = 1'b1;
				memRead  = 1'b0;
				memWrite = 1'b0;
				PCSel    = 2'b00;
				ALUOp    = 2'b11;
			end
			7'b1101111: begin // jal
				ALUSrc   = 1'bx;
				memtoReg = 2'b10;
				regWrite = 1'b1;
				memRead  = 1'b0;
				memWrite = 1'b0;
				PCSel    = 2'b01;
				ALUOp    = 2'bxx;
			end
			7'b1100111: begin // jalr
				ALUSrc   = 1'b1;
				memtoReg = 2'b10;
				regWrite = 1'b1;
				memRead  = 1'b0;
				memWrite = 1'b0;
				PCSel    = 2'b10;
				ALUOp    = 2'b11;
			end
			default   : begin
				ALUSrc   = 1'bx;
				memtoReg = 2'bxx;
				regWrite = 1'bx;
				memRead  = 1'bx;
				memWrite = 1'bx;
				PCSel    = 2'bxx;
				ALUOp    = 2'bxx;
			end
		endcase
	end

endmodule

