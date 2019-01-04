module ram#(
	parameter data_width = 32,
	parameter addr_width = 32,
	parameter capacity = 1024,
	parameter offset = 32'h00400000
)(
	input [addr_width-1:0] addr,
	input [data_width-1:0] write_data,
	input enable, read_or_write,
	output reg [data_width-1:0] read_data,
	output reg ready
);

reg [data_width-1:0] mem[capacity-1:0];

initial
	ready = 0;

wire [31:0] data_offset;
assign data_offset = (addr - offset) >> 2;

always @ (posedge enable) begin
	ready = 0;
	if (read_or_write)
		mem[data_offset] = write_data;
	else
		read_data = mem[data_offset];
	#42;  // emulate a very slow memory
	ready = 1;
end

endmodule
