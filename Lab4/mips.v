// helper functions for ALU

module mux2to1(in1,in2,sel,out);
	input in1,in2,sel;
	output out;

	assign out = (~sel & in1) | (sel & in2);
endmodule

module bit32_mux2to1(in1,in2,sel,out);
	input[31:0] in1,in2;
	input sel;
	output[31:0] out;
	genvar j;

	generate for (j = 0; j < 32; j = j + 1)begin: mux_loop
		mux2to1 m1(in1[j],in2[j],sel,out[j]);
	end
	endgenerate
endmodule

module bit32_mux4to1(in1,in2,in3,in4,sel,out);
	input[31:0] in1,in2,in3,in4;
	input[1:0] sel;
	output[31:0] out;
	wire[31:0] p1,p2;

	bit32_mux2to1 m1(in1,in2,sel[0],p1);
	bit32_mux2to1 m2(in3,in4,sel[0],p2);
	bit32_mux2to1 m3(p1,p2,sel[1],out);
endmodule

module bit32AND(in1,in2,out);
	input[31:0] in1,in2;
	output[31:0] out;

	assign {out} = in1 & in2;
endmodule

module bit32OR(in1,in2,out);
	input[31:0] in1,in2;
	output[31:0] out;

	assign {out} = in1 | in2;
endmodule
