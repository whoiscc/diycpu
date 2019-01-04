module alu(
	input [31:0] src_a, src_b,
	input [2:0] ctl,
	output reg zero,
	output reg [31:0] result
);

always @ (*)
	case (ctl)
	3'b000:
		result = src_a & src_b;
	3'b001:
		result = src_a | src_b;
	3'b010:
		result = src_a + src_b;
	3'b110: begin
		result = src_a - src_b;
		zero = result ? 0 : 1;
	end
	3'b111:
		result = src_a < src_b;
	endcase

endmodule
