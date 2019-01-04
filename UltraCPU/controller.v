module main_decoder#(
	parameter control_bus_width, 
	parameter addr_width = 5,
	parameter instr_width = control_bus_width + 1 + 3 + 2
)(
	input clock, reset,
	input [31:0] instr,
	input ready,
	output reg [control_bus_width-1:0] control_bus, 
	output reg enable,
	output reg [2:0] alu_decoder_ctl
);

reg [addr_width-1:0] upc;
reg [instr_width-1:0] uir;

reg [instr_width-1:0] mem[2**addr_width-1:0];

initial
	$readmemb("microcode.txt", mem);

reg wait_for_ready;
reg [1:0] jump_type;
reg real_ready;

initial begin
	real_ready = 0;
	enable = 0;
end

always @ (negedge clock)
	if (ready) begin
		real_ready = 1;
		enable = 0;
	end

wire [addr_width-1:0] next_upc;
upc_trans#(addr_width) trans(upc, instr, next_upc);

always @ (posedge clock) begin
	if (reset)
		upc = 0;
	else if (!wait_for_ready || real_ready) begin
		case (jump_type)
		0:
			upc = 0;
		1:
			upc = upc + 1;
		2:
			upc = next_upc;
		3:
			upc = 13;
		endcase
		real_ready = 0;
	end

	uir = mem[upc];
	control_bus = uir[instr_width-1:6];
	enable = uir[5];
	alu_decoder_ctl = uir[4:2];
	wait_for_ready = enable;
	jump_type = uir[1:0];
end

endmodule

module upc_trans#(
	parameter addr_width
)(
	input [addr_width-1:0] upc,
	input [31:0] instr,
	output reg [addr_width-1:0] next_upc
);

wire [5:0] opcode, funct;
assign opcode = instr[31:26];
assign funct = instr[5:0];

always @ (*)
	case (upc)
	0001:
		casez (opcode)
		6'b001111:  // lui
			next_upc = 0005;
		6'b10?011:  // lw, sw
			next_upc = 0002;
		6'b001110:  // xori
			next_upc = 0007;
		6'b000010:  // j
			next_upc = 0008;
		6'b000000:
			casez (funct)
			6'b001000:  //  jr
				next_upc = 0020;
			6'b001001:  // jalr
				next_upc = 0031;
			6'b0110??:  // mult, multu, div, divu
				next_upc = 0021;
			6'b010000:  // mfhi
				next_upc = 0022;
			6'b010010:  // mflo
				next_upc = 0023;
			default:  // R-R, sll, srl, sra
				next_upc = instr[10:6] ? 0018 : 0009;
			endcase
		6'b00010?:  // beq, bne
			next_upc = 0010;
		6'b000001, 6'b0011?:  // bltz, blez, bgtz, bgez
			next_upc = 0011;
		6'b000011:  // jal
			next_upc = 0019;
		6'b001000:  // addi
			next_upc = 0025;
		6'b001001:  // addiu
			next_upc = 0024;
		6'b001100:  // andi
			next_upc = 0028;
		6'b001101:  // ori
			next_upc = 0029;
		6'b001010:  // slti
			next_upc = 0026;
		6'b001011:  // sltiu
			next_upc = 0027;
		6'b001110:  // xori
			next_upc = 0030;
		endcase
	0002:
		case (opcode)
		6'b100011:  // lw
			next_upc = 0003;
		6'b101011:  // sw
			next_upc = 0006;
		endcase
	0010:
		case (opcode)
		6'b000100:  // beq
			next_upc = 0012;
		6'b000101:  // bne
			next_upc = 0014;
		endcase
	0011:
		case ({opcode[2:0], instr[16]})
		4'b0010:  // bltz
			next_upc = 0013;
		4'b1100:  // blez
			next_upc = 0016;
		4'b1110:  // bgtz
			next_upc = 0017;
		4'b0011:  // bgez
			next_upc = 0015;
		endcase
	endcase
endmodule

module controller#(
	parameter control_bus_width
)(
	input clock, reset,
	input [31:0] instr,
	input ready,
	output [control_bus_width-1:0] control_bus
);

wire [2:0] alu_decoder_ctl;

main_decoder#(.control_bus_width(control_bus_width-5)) main(
	clock, reset,
	instr,
	ready,
	control_bus[control_bus_width-1:5], control_bus[4], alu_decoder_ctl
);

alu_decoder alu(
	instr[5:0], alu_decoder_ctl,
	control_bus[3:0]
);

endmodule

module alu_decoder(
	input [5:0] funct,
	input [2:0] control,
	output reg [3:0] alu_func
);

wire [3:0] lookup_table[8:0];
assign lookup_table[1] = 0;
assign lookup_table[2] = 2;
assign lookup_table[3] = 3;
assign lookup_table[4] = 4;
assign lookup_table[5] = 5;
assign lookup_table[6] = 14;
assign lookup_table[7] = 13;

always @ (*)
	if (control)
		alu_func <= lookup_table[control];
	else
		if (funct == 32 || funct == 33)
			alu_func <= 0;
		else if (funct == 34 || funct == 35)
			alu_func <= 1;
		else if (funct >= 36 && funct <= 39)
			alu_func <= funct - 34;
		else if (funct >= 24 && funct <= 27)
			alu_func <= funct - 18;
		else if (funct == 0 || funct == 4)
			alu_func <= 10;
		else if (funct == 1 || funct == 2 || funct == 6 || funct == 7)
			alu_func <= funct + 10;
		else if (funct == 42 || funct == 43)
			alu_func <= funct - 29;
		
endmodule