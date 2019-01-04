module cpu(
	input clk, rst
);

wire [31:0] pc1, pc;
wire [31:0] instr;
wire mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, load_imm;
wire [2:0] alu_ctl;
wire [31:0] src_a, src_b;
wire [31:0] alu_result;
wire zero;
wire pc_src;
wire [31:0] pc_jump, pc_plus4, pc_branch;
wire [31:0] write_data, read_data, result;
wire [4:0] write_reg;
wire [31:0] sign_imm;

counter aCounter(
	clk, rst,
	pc1,
	pc
);

rom aRom(
	pc,
	instr
);

reg_file aRegFile(
	instr[25:21], instr[20:16], write_reg,
	result,
	clk, rst, reg_write,
	src_a, write_data
);

alu aAlu(
	src_a, src_b,
	alu_ctl,
	zero, alu_result
);

ram aRam(
	alu_result,
	write_data,
	mem_write,
	clk,
	read_data
);

sign_extend aSignExtend(
	instr[15:0],
	sign_imm
);

control aControl(
	instr[31:26], instr[5:0],
	mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, load_imm,
	alu_ctl
);

assign pc_src = branch & zero;

adder Adder1(
	pc, 4,
	pc_plus4
);

adder Adder2(
	sign_imm << 2, pc_plus4,
	pc_branch
);

wire [31:0] t1;

mux2 Mux2_1(
	pc_plus4, pc_branch,
	pc_src,
	t1
);

mux2 Mux2_2(
	t1, {pc_plus4[31:28], instr[25:0], 2'b0},
	jump,
	pc1
);

mux2 #(5) Mux2_3(
	instr[20:16], instr[15:11],
	reg_dst,
	write_reg
);

mux2 Mux2_4(
	write_data, sign_imm,
	alu_src,
	src_b
);

wire [31:0] memory_in;

mux2 Mux2_5(
	memory_in, read_data,
	mem_to_reg,
	result
);

mux2 Mux2_6(
	alu_result, {instr[15:0], 16'b0},
	load_imm,
	memory_in
);

endmodule
