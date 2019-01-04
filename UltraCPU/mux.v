module mux2#(
	parameter width = 32
)(
	input [width-1:0] x1, x2,
	input e,
	output [width-1:0] y
);

assign y = e ? x2 : x1;

endmodule

module mux4#(
	parameter width = 32
)(
	input [width-1:0] x1, x2, x3, x4,
	input [1:0]	e,
	output [width-1:0] y
);

wire [width-1:0] t1, t2;

mux2#(width) m1(x1, x2, e[0], t1);
mux2#(width) m2(x3, x4, e[0], t2);
mux2#(width) m3(t1, t2, e[1], y);

endmodule

module mux8#(
	parameter width = 32
)(
	input [width-1:0] x1, x2, x3, x4, x5, x6, x7, x8,
	input [2:0]	e,
	output [width-1:0] y
);

wire [width-1:0] t1, t2;

mux4#(width) m1(x1, x2, x3, x4, e[1:0], t1);
mux4#(width) m2(x5, x6, x7, x8, e[1:0], t2);
mux2#(width) m3(t1, t2, e[2], y);

endmodule