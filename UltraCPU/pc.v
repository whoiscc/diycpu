module pc#(
	parameter width = 32,
	parameter reset_value = 32'h00400000
)(
	input clock, reset,
	input update_pc,
	input [width-1:0] next_value,
	output [width-1:0] value
);

wire [width-1:0] t1;

single_reg#(.width(width)) counter(
	.clock(clock), .update_value(update_pc),
	.next_value(next_value), .value(t1)
);

assign value = t1;

always @ (negedge clock)
	if (reset)
		counter.value <= reset_value;

endmodule
