`include "adder.v"

module bit32_4to1mux(out,s,in1,in2,in3,in4);
	input [31:0]in1, in2, in3, in4;
	input [1:0]s;	
	output [31:0]out;
	wire [31:0]a,b;
	
	bit32_2to1mux m0(a,s[0],in1,in2);
	bit32_2to1mux m1(b,s[0],in3,in4);
	bit32_2to1mux m2(out,s[1],a,b);
endmodule

module bit32AND(out,in1,in2);	
	input [31:0]in1,in2;
	output [31:0]out;
	assign {out} = in1 & in2;
endmodule

module bit32OR(out,in1,in2);
	input [31:0]in1,in2;
	output[31:0]out;
	assign {out} = in1 | in2;
endmodule	

module ALU(a,b,binvert,cin,op,result,cout);
	input [31:0]a,b;
	input [1:0]op;	
	input cin,binvert;
	output cout;
	output [31:0]result;
	
	wire [31:0]notb;
	assign notb = -b;
	
	wire [31:0]d;
	bit32_2to1mux m0(d,binvert,b,notb);
	
	wire [31:0]i1,i2,i3;
	bit32AND a1(i1,a,d);
	bit32OR o1(i2,a,d);
	ADDER_32bit add1(a,d,cin,i3,cout);
	
	bit32_4to1mux m1(result,op,i1,i2,i3,0);
endmodule

/* module tbALU;
	reg binvert,cin;
	reg [1:0]operation;
	reg [31:0]a,b;
	wire [31:0]result;
	wire cout;
	ALU a0(a,b,binvert,cin,operation,result,cout);
	
	initial
	begin
		a=32'ha5a5a5a5;
		b=32'h5a5a5a5a;
		operation=2'b00;
		binvert=1'b0;
		cin=1'b0; // must           
		
		$monitor(,$time," a=%8h, b=%8h, op=%2b, binv=%1b, cout=%1b, result=%8h",a,b,operation,binvert,cout,result);
		#100 operation=2'b01; //OR
		#100 operation=2'b10; //ADD
		#100 binvert=1'b1; //SUB
		#200 $finish;
	end
endmodule */

module ANDarray(RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2,Op);
	input [5:0]Op;
	output RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2;
	wire Rformat,lw,sw,beq;
	
	assign Rformat = (~Op[0])&(~Op[1])&(~Op[2])&(~Op[3])&(~Op[4])&(~Op[5]);
	assign lw = Op[0]&Op[1]&(~Op[2])&(~Op[3])&(~Op[4])&Op[5];
	assign sw = Op[0]&Op[1]&(~Op[2])&Op[3]&(~Op[4])&Op[5];
	assign beq = (~Op[0])&(~Op[1])&Op[2]&(~Op[3])&(~Op[4])&(~Op[5]);
	
	assign RegDst=Rformat;
	assign ALUSrc=lw|sw;
	assign MemtoReg=lw;
	assign RegWrite=Rformat|lw;
	assign MemRead=lw;
	assign MemWrite=sw;
	assign Branch=beq;
	assign ALUOp1=Rformat;
	assign ALUOp2=beq;
endmodule

/* module tb_ANDArray;
	reg [5:0]Op;
	wire RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2;
	ANDarray a0(RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2,Op);
	
	initial
	begin
		Op=6'b0;
		$monitor(,$time," RegDst=%1b, ALUSrc=%1b, MemtoReg=%1b, RegWrite=%1b, MemRead=%1b, MemWrite=%1b, Branch=%1b, ALUOp1=%1b, ALUOp2=%1b",RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp1,ALUOp2);
		
		#100 Op=6'b100011;
		#100 Op=6'b101011;
		#100 Op=6'b000100;
		#200 $finish;
	end
endmodule */

module ALUControl(ALUOp,FuncField,out);
	input [1:0]ALUOp;
	input [4:0]FuncField;
	output [2:0]out;
	wire a, b;
	wire nalu1, nf2;
	
	assign nalu1=~ALUOp[1];
	assign nf2=~FuncField[2];
	
	assign a=FuncField[0]|FuncField[3];
	assign b=FuncField[1]&ALUOp[1];
		
	assign out[2]=ALUOp[0]|b;
	assign out[1]=nf2|nalu1;
	assign out[0]=ALUOp[1]&a;
endmodule

module tb_ALUControl;
	reg [1:0]ALUOp;
	reg [4:0]FuncField;
	wire [2:0]out;
	ALUControl ac(ALUOp,FuncField,out);
	
	initial
	begin
		ALUOp=2'b0;
		$monitor(,$time," out=%3b",out);
		
		#100 ALUOp=2'b01;
		#100 ALUOp=2'b10; FuncField=6'b0;
		#100 FuncField=6'b000010;
		#100 FuncField=6'b000100;
		#100 FuncField=6'b000101;
		#100 FuncField=6'b001010;
		#200 $finish;
	end
endmodule