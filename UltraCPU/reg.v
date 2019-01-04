module reg_group#(
	parameter addr_width = 5, 
	parameter data_width = 32,
	parameter gp = 28, data_segment = 32'h00400100,
	parameter sp = 29, stack_segment = 32'h00400fff
)(
	input clock, reset,
	input [addr_width-1:0] read_addr1, read_addr2,
	input [addr_width-1:0] write_addr, 
	input [data_width-1:0] write_data,
	input write_enable,
	output reg [data_width-1:0] read_data1, read_data2
);

reg [data_width-1:0] mem[2**addr_width-1:0];

always @ (negedge clock)
	if (reset) begin
		mem[gp] <= data_segment;
		mem[sp] <= stack_segment;
		// some other initialize
	end
	else
		if (write_enable)
			mem[write_addr] <= write_data;
		else begin
			read_data1 <= mem[read_addr1];
			read_data2 <= mem[read_addr2];
		end

endmodule
