module ram(
	input [31:0] addr,
	input [31:0] w_data,
	input w_enable,
	input clk,
	output [31:0] r_data
);

reg [31:0] mem[1023:0];

assign r_data = mem[addr >> 2];

always @ (posedge clk)
	if (w_enable)
		mem[addr >> 2] = w_data;

endmodule
