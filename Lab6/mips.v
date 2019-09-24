`include "alu.v"
`include "regfile.v"

module RegFile_32(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
	input clk,reset,RegWrite;
	input[1:0] WriteReg,ReadReg1,ReadReg2;
	output[31:0] WriteData,ReadData1,ReadData2;
	wire[3:0] DecoderOp,regClk;
	wire[31:0] q[32];
	genvar i,j;
	
	decoder5_32 d1(DecoderOp,WriteReg);
	
	generate for(i=0;i<32;i=i+1)
	begin: clk_loop
		and a0(regClk[i],RegWrite,DecoderOp[i],clk);
	end
	endgenerate
	
	generate for(j=0;j<32;j=j+1)
	begin: reg_loop
		reg_32bit r1(q[j],WriteData,DecoderOp[j].);
	

module IM(PC, register);
	input [1:0]PC;
	output [3:0];
	
	

module SCDataPath();
	reg 