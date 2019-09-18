module d_ff(q,d,clk,reset);
	input d, clk, reset;
	output q;
	reg q;
	
	always @ (posedge clk)
	begin
		if (!reset) q <= 1'b0;
		else q <= d;
	end
endmodule

module reg_32bit(q,d,clk,reset);
	input[31:0] d;
	input clk, reset;
	output[31:0] q;
	genvar j;
	
	generate for(j=0;j<32;j=j+1)
	begin: reg_loop
		d_ff d1(q[j],d[j],clk,reset);
	end
	endgenerate
endmodule

/*	
module tb32reg;
	reg[31:0] d;
	reg clk,reset;
	wire[31:0] q;
	reg_32bit R(q,d,clk,reset);
	always @ (clk)
		#5 clk <= ~clk;
	
	initial
	begin
		$monitor(,$time," d=%8h, q=%8h, reset=%1b",d,q,reset);
		clk=1'b1;
		reset=1'b0;
		#20 reset=1'b1;
		#20 d=32'hAFAFAFAF;
		#200 $finish;
	end
endmodule
*/

module mux4_1(regData,q1,q2,q3,q4,reg_no);
	input[31:0] q1,q2,q3,q4;
	input[1:0] reg_no;
	output reg[31:0] regData;
	
	always @ (q1 or q2 or q3 or q4 or reg_no)
	begin
		if (~reg_no[1])
		begin
			if(~reg_no[0])
				regData = q1;
			else
				regData = q2;
		end
		else
		begin
			if(~reg_no[0])
				regData = q3;
			else
				regData = q4;
		end
	end
endmodule

module decoder2_4(register,reg_no);
	input[1:0] reg_no;
	output[3:0] register;
	wire[1:0] nreg_no;
	
	assign {nreg_no} = ~reg_no;
	
	and a0(register[0], nreg_no[1], nreg_no[0]);
	and a1(register[1], nreg_no[1], reg_no[0]);
	and a2(register[2], reg_no[1], nreg_no[0]);
	and a3(register[3], reg_no[1], reg_no[0]);
endmodule

module RegFile(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
	input clk,reset,RegWrite;
	input[1:0] WriteReg,ReadReg1,ReadReg2;
	output[31:0] WriteData,ReadData1,ReadData2;
	wire[3:0] DecoderOp,regClk;
	wire[31:0] q1,q2,q3,q4;
	genvar i,j;
	
	decoder2_4 d1(DecoderOp,WriteReg);
	
	generate for(i=0;i<4;i=i+1)
	begin: clk_loop
		and a0(regClk[i],RegWrite,DecoderOp[i],clk);
	end
	endgenerate

	reg_32bit r1(q1,WriteData,regClk[0],reset);
	reg_32bit r2(q2,WriteData,regClk[1],reset);
	reg_32bit r3(q3,WriteData,regClk[2],reset);
	reg_32bit r4(q4,WriteData,regClk[3],reset);
	
	mux4_1 m1(ReadData1,q1,q2,q3,q4,ReadReg1);
	mux4_1 m2(ReadData2,q1,q2,q3,q4,ReadReg2);
endmodule