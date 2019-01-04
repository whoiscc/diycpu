module testbench();

reg clk, rst;

cpu aCpu(clk, rst);

initial begin
	clk = 0;
	rst = 1;
	forever begin
		#10 clk = ~clk;
	end
end

initial begin
	#20 rst = 0;
end

initial begin
	$readmemb("code/mips5.txt", aCpu.aRom.mem);
end

endmodule
