module reg_file(
	input [4:0] a1, a2, a3,
	input [31:0] wd3,
	input clk, rst, we,
	output [31:0] rd1, rd2
);

reg [31:0] mem[31:0];

assign rd1 = mem[a1];
assign rd2 = mem[a2];

always @ (posedge clk) begin
	if (rst)
		mem[28] = 32'b0;
	if (we)
		mem[a3] <= wd3;
end

endmodule
