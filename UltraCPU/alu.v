module alu#(
	parameter width = 32
)(
	input [width-1:0] src_a, src_b,
	input [3:0] control,
	output reg [width-1:0] result, result2,
	output zero
);

reg [2*width-1:0] temp;

always @ (*)
	case(control)
		0:
			result <= src_a + src_b;
		1:
			result <= src_a - src_b;
		2:
			result <= src_a & src_b;
		3:
			result <= src_a | src_b;
		4:
			result <= src_a ^ src_b;
		5:
			result <= ~ (src_a | src_b);
		6: begin
			temp = src_a * src_b;
			result = temp[width-1:0];
			result2 = temp[2*width-1:width];
		end
		7: begin
			temp = $signed(src_a) * $signed(src_b);
			result = temp[width-1:0];
			result2 = temp[2*width-1:width];
		end
		8: begin
			result <= src_a / src_b;
			result2 <= src_a % src_b;
		end
		9: begin
			result <= $signed(src_a) / $signed(src_b);
			result2 <= $signed(src_a) % $signed(src_b);
		end
		10:
			result <= src_b << src_a[4:0];
		11:
			result <= src_b >> src_a[4:0];
		12:
			result <= $signed(src_b) >> src_a[4:0];
		13:
			result <= src_a < src_b;
		14:
			result <= $signed(src_a) < $signed(src_b);
	endcase

assign zero = src_a == src_b;

endmodule
