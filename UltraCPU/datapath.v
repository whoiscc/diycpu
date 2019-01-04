module datapath(
	input clock, reset,
	// to RAM
	output [31:0] addr,
	input [31:0] read_data,
	output [31:0] write_data,
	// control
	output [31:0] instr,
	input [3:0] alu_func,
	input write_reg, update_pc, update_ir, update_dr, pc_or_alu_result, 
	input [2:0] reg_write_data_select, 
	input [1:0] select_reg_write_addr,
	input update_mar, 
	input [2:0] select_alu_src_a, select_alu_src_b,
	input select_next_pc, 
	input update_result_reg, branch, select_branch_test, select_jump_addr,
	input update_lohi
);

wire [31:0] next_pc, pc;

pc counter(
	.clock(clock), .reset(reset), .update_pc(update_pc),
	.next_value(next_pc), .value(pc)
);

wire [4:0] reg_read_addr_a, reg_read_addr_b, reg_write_addr;
wire [31:0] reg_read_data_a, reg_read_data_b, reg_write_data;

reg_group registers(
	.clock(clock), .reset(reset), .write_enable(write_reg),
	.read_addr1(reg_read_addr_a), .read_addr2(reg_read_addr_b),
	.read_data1(reg_read_data_a), .read_data2(reg_read_data_b),
	.write_addr(reg_write_addr), .write_data(reg_write_data)
);

wire [31:0] alu_src_a, alu_src_b, alu_result, alu_result2;
wire alu_eq;

alu alu(
	.control(alu_func),
	.src_a(alu_src_a), .src_b(alu_src_b),
	.result(alu_result), .result2(alu_result2), .zero(alu_eq)
);

wire [31:0] lo, hi;
single_reg lo_reg(
	.clock(clock), .update_value(update_lohi),
	.next_value(alu_result),
	.value(lo)
);

single_reg hi_reg(
	.clock(clock), .update_value(update_lohi),
	.next_value(alu_result2),
	.value(hi)
);

wire [31:0] result;
wire result_eq;

single_reg#(.width(33)) alu_result_reg(
	.clock(clock), .update_value(update_result_reg),
	.next_value({alu_eq, alu_result}),
	.value({result_eq, result})
);

wire [31:0] data, ir_value;

single_reg ir(
	.clock(clock), .update_value(update_ir),
	.next_value(read_data), .value(ir_value)
);

assign instr = ir_value;

single_reg dr(
	.clock(clock), .update_value(update_dr),
	.next_value(read_data), .value(data)
);

assign reg_read_addr_a = instr[25:21];
assign reg_read_addr_b = instr[20:16];

mux8 alu_src_a_mux(
	reg_read_data_a, pc, result, 32'b0, {27'b0, instr[10:6]}, 32'b0, 32'b0, 32'b0,
	select_alu_src_a,
	alu_src_a
);

wire [31:0] sign_extended_imm, unsign_extended_imm, pc_offset;
assign sign_extended_imm = {{16{instr[15]}}, instr[15:0]};
assign unsign_extended_imm = {16'b0, instr[15:0]};
assign pc_offset = {14'b0, instr[15:0], 2'b0};
wire [31:0] jump_addr;
mux2 jump_addr_mux(
	{pc[31:28], instr[25:0], 2'b0}, reg_read_data_a,
	select_jump_addr,
	jump_addr
);

mux8 alu_src_b_mux(
	reg_read_data_b, sign_extended_imm, 32'd4, {31'b0, result_eq},
	unsign_extended_imm, 32'b0, pc_offset, 32'b0,
	select_alu_src_b,
	alu_src_b
);

wire [31:0] next_pc_t1, next_pc_t2;

mux2 next_pc_select_mux(
	alu_result, jump_addr,
	select_next_pc,
	next_pc_t1
);

wire branch_test;
mux2#(.width(1)) branch_test_mux(
	result[0], result_eq,
	select_branch_test,
	branch_test
);

mux2 next_pc_branch_test_mux(
	pc, next_pc_t1,
	branch_test,
	next_pc_t2
);

mux2 next_pc_branch_mux(
	next_pc_t1, next_pc_t2,
	branch,
	next_pc
);

wire [31:0] mar_next_value;

single_reg mar(
	.clock(clock), .update_value(update_mar),
	.next_value(mar_next_value),
	.value(addr)
);

mux2 select_memory_addr_mux(
	pc, alu_result,
	pc_or_alu_result,
	mar_next_value
);

wire [31:0] lui_imm;
assign lui_imm = {instr[15:0], 16'b0};
mux8 select_reg_write_data_mux(
	data, lui_imm, alu_result, pc, lo, hi, 32'b0, 32'b0,
	reg_write_data_select,
	reg_write_data
);

mux4#(.width(5)) reg_write_addr_mux(
	instr[20:16], instr[15:11], 5'd31, 5'b0,
	select_reg_write_addr,
	reg_write_addr
);

assign write_data = reg_read_data_b;

endmodule
