module counter(
	input clk, rst, [31:0] x,
	output reg [31:0]y
);

always @ (posedge clk)
	y <= rst ? 32'h00400000 : x;	

endmodule
