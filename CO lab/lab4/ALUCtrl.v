module ALUCtrl (
    input [1:0] ALUOp,
    input [3:0] funct,
    output reg [3:0] ALUCtl
);

    // TODO: implement your ALU control here
    // For testbench verifying, Do not modify input and output pin
    // Hint: using ALUOp, funct7, funct3 to select exact operation
	always @(*) begin
		if (ALUOp == 2'b00) 	 // load, store, jalr
			ALUCtl = 4'b0010;
		else if (ALUOp == 2'b01) // branch
			ALUCtl = 4'b0110;
		else if (ALUOp == 2'b10) // R type
			case(funct)
				4'b0000: ALUCtl = 4'b0010; // add
				4'b1000: ALUCtl = 4'b0110; // sub
				4'b0111: ALUCtl = 4'b0000; // and
				4'b0110: ALUCtl = 4'b0001; // or
				4'b0010: ALUCtl = 4'b0100; // slt
				default: ALUCtl = 4'bxxxx;
			endcase
		else if (ALUOp == 2'b11) // I type
			case(funct[2:0])
				3'b000: ALUCtl = 4'b0010; // addi
				3'b111: ALUCtl = 4'b0000; // andi
				3'b110: ALUCtl = 4'b0001; // ori
				3'b010: ALUCtl = 4'b0100; // slti
				default: ALUCtl = 4'bxxxx;
			endcase
		else ALUCtl = 4'bxxxx;
	end

endmodule

