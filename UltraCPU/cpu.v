module cpu#(
	parameter control_bus_width = 23 + 4 + 2
)(
	input clock, reset,
	// mem
	output [31:0] addr, write_data,
	output mem_enable, read_or_write,
	input [31:0] read_data,
	input mem_ready
);

wire [control_bus_width-1:0] control_bus;
wire [31:0] instr;

controller#(
	.control_bus_width(control_bus_width)
) ctl(
	.clock(clock), .reset(reset),
	.instr(instr),
	.ready(mem_ready),
	.control_bus(control_bus)
);

wire [3:0] alu_func;
wire [1:0] select_reg_write_addr;
wire [2:0] reg_write_data_select, select_alu_src_a, select_alu_src_b;
assign alu_func = control_bus[3:0];
assign mem_enable = control_bus[4];
assign read_or_write = control_bus[5];
assign write_reg = control_bus[6];
assign update_pc = control_bus[7];
assign update_ir = control_bus[8];
assign update_dr = control_bus[9];
assign pc_or_alu_result = control_bus[10];
assign reg_write_data_select = control_bus[13:11];
assign update_mar = control_bus[14];
assign select_alu_src_b = control_bus[17:15];
assign select_alu_src_a = control_bus[20:18];
assign select_next_pc = control_bus[21];
assign select_reg_write_addr = control_bus[23:22];
assign update_result_reg = control_bus[24];
assign branch = control_bus[25];
assign select_branch_test = control_bus[26];
assign select_jump_addr = control_bus[27];
assign update_lohi = control_bus[28];

datapath dp(
	.clock(clock), .reset(reset),
	.addr(addr), .read_data(read_data), .write_data(write_data),
	.instr(instr),
	.alu_func(alu_func), .write_reg(write_reg), .update_pc(update_pc), .update_ir(update_ir),
	.update_dr(update_dr), .pc_or_alu_result(pc_or_alu_result), 
	.reg_write_data_select(reg_write_data_select), .update_mar(update_mar),
	.select_alu_src_a(select_alu_src_a), .select_alu_src_b(select_alu_src_b), 
	.select_next_pc(select_next_pc), .select_reg_write_addr(select_reg_write_addr),
	.update_result_reg(update_result_reg), .branch(branch), 
	.select_branch_test(select_branch_test), .select_jump_addr(select_jump_addr),
	.update_lohi(update_lohi)
);

endmodule
