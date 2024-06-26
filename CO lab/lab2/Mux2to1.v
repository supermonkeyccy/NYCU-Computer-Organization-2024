module Mux2to1 #(
    parameter size = 32
) 
(
    input sel,
    input signed [size-1:0] s0,
    input signed [size-1:0] s1,
    output reg signed [size-1:0] out
);
    // TODO: implement your 2to1 multiplexer here

    always @(*)
		case (sel)
			1'b1: out = s1;
			1'b0: out = s0;
			default: out = { 32{1'bx} };
		endcase

endmodule

