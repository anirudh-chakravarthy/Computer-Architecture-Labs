module d_ff(d, clk, reset, q);
	input d, clk, reset;
	output reg q;

	always @(posedge clk or negedge reset) begin
		if(!reset) q <= 0;
		else q <= d;
	end
endmodule

module reg_32bit(q, d, clk, reset);
	input[31:0] d;
	input clk, reset;
	output[31:0] q;

	generate
		genvar j;
		for (j = 0; j < 32; j = j + 1) begin: reg_loop
			d_ff dff1(d[j], clk, reset, q[j]);
		end
	endgenerate
endmodule

module mux4_1(regData, q1, q2, q3, q4, reg_no);
	input[31:0] q1, q2, q3, q4;
	input[1:0] reg_no;
	output[31:0] regData;
	reg[31:0] regData;

	always @(reg_no or q1 or q2 or q3 or q4) begin
		if (!reg_no[1]) begin
			if(!reg_no[0]) begin
				regData = q1;
			end
			else begin
				regData = q2;
			end
		end
		else begin
			if(!reg_no[0]) begin
				regData = q3;
			end
			else begin
				regData = q4;
			end
		end
	end
endmodule

module decoder_2to4(register, reg_no);
	input[1:0] reg_no;
	output[3:0] register;

	assign register[0] = ~reg_no[1] & ~reg_no[0];
	assign register[1] = ~reg_no[1] & reg_no[0];
	assign register[2] = reg_no[1] & ~reg_no[0];
	assign register[3] = reg_no[1] & reg_no[0];
endmodule

module RegFile(clk, reset, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2);
	input clk, reset, RegWrite;
	input[1:0] ReadReg1, ReadReg2, WriteReg;
	input[31:0] WriteData;
	output[31:0] ReadData1, ReadData2;

	wire[3:0] decoderop;
	decoder_2to4 d1(decoderop, WriteReg); // get register number as decoder o/p

	wire[3:0] regclk; // whether to write to reg or not
	assign regclk[0] = clk & RegWrite & decoderop[0];
	assign regclk[1] = clk & RegWrite & decoderop[1];
	assign regclk[2] = clk & RegWrite & decoderop[2];
	assign regclk[3] = clk & RegWrite & decoderop[3];

	wire[31:0] q1, q2, q3, q4; // outputs from all registers
	reg_32bit r1(q1, WriteData, regclk[0], reset);
	reg_32bit r2(q2, WriteData, regclk[1], reset);
	reg_32bit r3(q3, WriteData, regclk[2], reset);
	reg_32bit r4(q4, WriteData, regclk[3], reset);

	// read output from registers
	mux4_1 m1(ReadData1, q1, q2, q3, q4, ReadReg1);
	mux4_1 m2(ReadData2, q1, q2, q3, q4, ReadReg2);
endmodule

module tb;
	reg clk, reset, RegWrite;
	reg[1:0] ReadReg1, ReadReg2, WriteReg;
	reg[31:0] WriteData;
	wire[31:0] ReadData1, ReadData2;
	RegFile rf(clk, reset, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2);

	always #5 clk = ~clk;

	initial begin
		$monitor(,$time," clk=%b, Data1=%8h, Data2=%8h", clk, ReadData1, ReadData2);
		#0  clk = 1'b0; reset = 1'b0; RegWrite = 1'b1;
		#20 reset = 1'b1;
		#20 WriteReg = 2'b00; WriteData=32'hFFFFFFFF; 
		#20 ReadReg1 = 2'b00; ReadReg2 = 2'b11;
		#20 WriteReg = 2'b10; WriteData=32'hAAAAAAAA;
		#20 RegWrite = 1'b0;
		#20 ReadReg1 = 2'b00; ReadReg2 = 2'b10;
		#20 $finish;
	end
endmodule