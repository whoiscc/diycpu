module rom(
	input [31:0] addr,
	output [31:0] data
);

reg [31:0] mem[1023:0];

assign data = mem[(addr - 32'h00400000) >> 2];

endmodule
