module single_reg#(
	parameter width = 32
)(
	input [width-1:0] next_value,
	input clock, update_value,
	output reg [width-1:0] value
);

always @ (negedge clock)
	if (update_value)
		value <= next_value;

endmodule
