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

module mux32_1(regData, q, reg_no);
	input[31:0][31:0] q;
	input[4:0] reg_no;
	output[31:0] regData;

	integer reg_int;
	assign regData = q[reg_no][31:0];
endmodule

module decoder_5to32(address, data_address);
 	input[4:0] address;
 	output[31:0] data_address;

 	assign data_address[0] = ~address[4] & ~address[3] & ~address[2] & ~address[1] & ~address[0];
 	assign data_address[1] = ~address[4] & ~address[3] & ~address[2] & ~address[1] & address[0];
 	assign data_address[2] = ~address[4] & ~address[3] & ~address[2] & address[1] & ~address[0];
 	assign data_address[3] = ~address[4] & ~address[3] & ~address[2] & address[1] & address[0];
 	assign data_address[4] = ~address[4] & ~address[3] & address[2] & ~address[1] & ~address[0];
 	assign data_address[5] = ~address[4] & ~address[3] & address[2] & ~address[1] & address[0];
 	assign data_address[6] = ~address[4] & ~address[3] & address[2] & address[1] & ~address[0];
 	assign data_address[7] = ~address[4] & ~address[3] & address[2] & address[1] & address[0];
 	assign data_address[8] = ~address[4] & address[3] & ~address[2] & ~address[1] & ~address[0];
 	assign data_address[9] = ~address[4] & address[3] & ~address[2] & ~address[1] & address[0];
 	assign data_address[10] = ~address[4] & address[3] & ~address[2] & address[1] & ~address[0];
 	assign data_address[11] = ~address[4] & address[3] & ~address[2] & address[1] & address[0];
 	assign data_address[12] = ~address[4] & address[3] & address[2] & ~address[1] & ~address[0];
 	assign data_address[13] = ~address[4] & address[3] & address[2] & ~address[1] & address[0];
 	assign data_address[14] = ~address[4] & address[3] & address[2] & address[1] & ~address[0];
 	assign data_address[15] = address[4] & address[3] & address[2] & address[1] & address[0];
 	assign data_address[16] = address[4] & ~address[3] & ~address[2] & ~address[1] & ~address[0];
 	assign data_address[17] = address[4] & ~address[3] & ~address[2] & ~address[1] & address[0];
 	assign data_address[18] = address[4] & ~address[3] & ~address[2] & address[1] & ~address[0];
 	assign data_address[19] = address[4] & ~address[3] & ~address[2] & address[1] & address[0];
 	assign data_address[20] = address[4] & ~address[3] & address[2] & ~address[1] & ~address[0];
 	assign data_address[21] = address[4] & ~address[3] & address[2] & ~address[1] & address[0];
 	assign data_address[22] = address[4] & ~address[3] & address[2] & address[1] & ~address[0];
 	assign data_address[23] = address[4] & ~address[3] & address[2] & address[1] & address[0];
 	assign data_address[24] = address[4] & address[3] & ~address[2] & ~address[1] & ~address[0];
 	assign data_address[25] = address[4] & address[3] & ~address[2] & ~address[1] & address[0];
 	assign data_address[26] = address[4] & address[3] & ~address[2] & address[1] & ~address[0];
 	assign data_address[27] = address[4] & address[3] & ~address[2] & address[1] & address[0];
 	assign data_address[28] = address[4] & address[3] & address[2] & ~address[1] & ~address[0];
 	assign data_address[29] = address[4] & address[3] & address[2] & ~address[1] & address[0];
 	assign data_address[30] = address[4] & address[3] & address[2] & address[1] & ~address[0];
 	assign data_address[31] = address[4] & address[3] & address[2] & address[1] & address[0];
 endmodule

module RegFile(clk, reset, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2);
	input clk, reset, RegWrite;
	input[4:0] ReadReg1, ReadReg2, WriteReg;
	input[31:0] WriteData;
	output[31:0] ReadData1, ReadData2;

	wire[31:0] decoderop;
	decoder_5to32 d1(decoderop, WriteReg); // get register number as decoder o/p

	wire[31:0] regclk; // whether to write to reg or not
	generate
		genvar j;
		for (j = 0; j < 32; j = j + 1) begin
			assign regclk[j] = clk & RegWrite & decoderop[j];
		end
	endgenerate

	wire[31:0][31:0] q;
	generate
		genvar k;
		for (k = 0; k < 32; k = k + 1) begin
			reg_32bit r1(q[k][31:0], WriteData, regclk[k], reset);
		end
	endgenerate

	// read output from registers
	mux32_1 m1(ReadData1, q, ReadReg1);
	mux32_1 m2(ReadData2, q, ReadReg2);
endmodule