`include "mips.v"
`include "adder.v"

module ALU(a,b,cin,binvert,op,cout,result);
	input[31:0] a, b;
	input cin, binvert;
	input[1:0] op;
	output cout;
	output[31:0] result;

	wire[31:0] nb, p;
	assign nb = ~b;
	bit32_mux2to1 m0(b,nb,binvert,p);

	wire[31:0] and_res, or_res, add_res;
	bit32AND a0(a,p,and_res);
	bit32OR o0(a,p,or_res);
	adder_32bit ad0(add_res,cout,a,p,cin);

	bit32_mux4to1 m1(and_res,or_res,add_res,0,op,result);
endmodule

// module tbALU;
// 	reg binvert, cin;
// 	reg [1:0] op;
// 	reg [31:0] a,b;
// 	wire [31:0] result;
// 	wire cout;
// 	ALU al(a,b,cin,binvert,op,cout,result);

// 	initial begin
// 		$monitor(,$time," a=%8h, b=%8h, cin=%b, binv=%b, op=%2b, cout=%b, result=%8h",a,b,cin,binvert,op,cout,result);
// 		a=32'ha5a5a5a5; b=32'h5a5a5a5a;
// 		op=2'b00;
// 		binvert=1'b0;
// 		cin=1'b0; //must perform AND resulting in zero
// 		#100 op=2'b01; //OR
// 		#100 op=2'b10; //ADD
// 		#100 binvert=1'b1;//SUB
// 		#200 $finish;
// 	end
// endmodule

module ANDarray(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2, Op);
	input[5:0] Op;
	output RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;
	wire Rformat, lw, sw, beq;

	assign Rformat = (~Op[0]) & (~Op[1]) & (~Op[2]) & (~Op[3]) & (~Op[4]) & (~Op[5]);
	assign lw = Op[0] & Op[1] & (~Op[2]) & (~Op[3]) & (~Op[4]) & Op[5];
	assign sw = Op[0] & Op[1] & (~Op[2]) & Op[3] & (~Op[4]) & Op[5];
	assign beq = (~Op[0]) & (~Op[1]) & Op[2] & (~Op[3]) & (~Op[4]) & (~Op[5]);

	assign RegDst = Rformat;
	assign ALUSrc = lw | sw;
	assign MemtoReg = lw;
	assign RegWrite = Rformat | lw;
	assign MemRead = lw;
	assign MemWrite = sw;
	assign Branch = beq;
	assign ALUOp1 = Rformat;
	assign ALUOp2 = beq;
endmodule

//  module tb_ANDArray;
// 	reg [5:0]Op;
// 	wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;
// 	ANDarray a0(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2, Op);
	
// 	initial
// 	begin
// 		$monitor(,$time," RegDst=%1b, ALUSrc=%1b, MemtoReg=%1b, RegWrite=%1b, MemRead=%1b, MemWrite=%1b, Branch=%1b, ALUOp1=%1b, ALUOp2=%1b",RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2);
// 		#0 Op=6'b0;
// 		#10 Op=6'b100011;
// 		#10 Op=6'b101011;
// 		#10 Op=6'b000100;
// 		#20 $finish;
// 	end
// endmodule 

module ALUControl(Op, ALUOp, FuncField);
	input[1:0] ALUOp;
	input[5:0] FuncField;
	output[2:0] Op;

	wire na, nf;
	assign na = ~ALUOp[1];
	assign nf = ~FuncField[2];

	wire p1,p2,p3;
	assign p1 = FuncField[3] | FuncField[0];
	assign p2 = ALUOp[1] & FuncField[1];
	assign p3 = ALUOp[1] & p1;

	assign Op[2] = ALUOp[0] | p2;
	assign Op[1] = na | nf;
	assign Op[0] = p3;
endmodule

module tbALUControl;
	reg[1:0] ALUOp;
	reg[5:0] FuncField;
	wire[2:0] Op;
	ALUControl ac(Op, ALUOp, FuncField);

	initial begin
		$monitor(,$time," ALUOp=%2b, FuncField=%6b, Op=%3b", ALUOp, FuncField, Op);
		#0 ALUOp = 2'b00; 
		#5 ALUOp = 2'b01;
		#5 ALUOp = 2'b10; FuncField=6'b0;
		#5 FuncField = 6'b000010;
		#5 FuncField = 6'b000100;
		#5 FuncField = 6'b000101;
		#5 FuncField = 6'b001010;
		#5 $finish;
	end
endmodule
