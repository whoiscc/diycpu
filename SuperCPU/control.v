module main_decoder(
	input [5:0] opcode,
	output mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, load_imm,
	output [1:0] alu_op
);

reg [9:0] ctl_bus;
assign reg_write = ctl_bus[8];
assign reg_dst = ctl_bus[7];
assign alu_src = ctl_bus[6];
assign branch = ctl_bus[5];
assign mem_write = ctl_bus[4];
assign mem_to_reg = ctl_bus[3];
assign alu_op = ctl_bus[2:1];
assign jump = ctl_bus[0];

assign load_imm = ctl_bus[9];

always @ (opcode)
	case (opcode)
	6'h00:
		ctl_bus = 10'b0110000100;
	6'h23:
		ctl_bus = 10'b0101001000;
	6'h2b:
		ctl_bus = 10'b0001010000;
	6'h04:
		ctl_bus = 10'b0000100010;
	6'h09:
		ctl_bus = 10'b0101000000;
	6'h02:
		ctl_bus = 10'b0000000001;
	6'h0F:
		ctl_bus = 10'b1100000000;
	endcase

endmodule			

module alu_decoder(
	input [1:0] alu_op,
	input [5:0] funct,
	output reg [2:0] alu_ctl
);

always @ (*)
	if (alu_op == 2'b00)
		alu_ctl = 3'b010;
	else if (alu_op[0] == 1)
		alu_ctl = 3'b110;
	else
		case(funct)
		6'd33:
			alu_ctl = 3'b010;
		6'd35:
			alu_ctl = 3'b110;
		6'd36:
			alu_ctl = 3'b000;
		6'd37:
			alu_ctl = 3'b001;
		6'd43:
			alu_ctl = 3'b111;
		endcase

endmodule

module control(
	input [5:0] opcode, funct,
	output mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, load_imm,
	output [2:0] alu_ctl
);

wire [1:0] alu_op;

main_decoder main(
	opcode, 
	mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write, jump, load_imm,
	alu_op
);

alu_decoder alu(
	alu_op, 
	funct,
	alu_ctl
);

endmodule