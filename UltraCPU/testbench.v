module testbench();

reg clock, reset;

initial begin
	reset <= 1;
	clock <= 0;
	forever
		#10 clock <= ~clock;
end

initial
	#20 reset <= 0;

wire [31:0] addr, read_data, write_data;
wire mem_enable, read_or_write, mem_ready;

cpu cpu(
	.clock(clock), .reset(reset),
	.addr(addr), .read_data(read_data), .write_data(write_data),
	.mem_enable(mem_enable), .read_or_write(read_or_write), .mem_ready(mem_ready)
);

ram ram(
	.addr(addr), .read_data(read_data), .write_data(write_data),
	.enable(mem_enable), .read_or_write(read_or_write), .ready(mem_ready)
);

initial begin
	$readmemb("code/demo.txt", ram.mem);
end

always @ (posedge clock)
	if (cpu.instr == 32'b0)
		$stop;

endmodule
