`include "regfile.v"
`include "alu.v"

module reg_5bit(q, d, clk, reset);
	input[4:0] d;
	input clk, reset;
	output[4:0] q;

	generate
		genvar j;
		for (j = 0; j < 5; j = j + 1) begin: reg_loop
			d_ff dff1(d[j], clk, reset, q[j]);
		end
	endgenerate
endmodule

// initializing instruction memory with R format instruction: add $0, $1, $2
module IM_Rformat(memory);
	output[31:0][31:0] memory; // instruction memory

	generate
		genvar i, j;
		for (i = 0; i < 32; i = i + 1) begin
			for(j = 0; j < 32; j = j + 1) begin
				assign memory[i][j] = 32'h00220020;
			end
		end
	endgenerate
endmodule

// initializing data memory with 0
module DM_load(memory);
	output[31:0][31:0] memory; // instruction memory

	generate
		genvar i, j;
		for (i = 0; i < 32; i = i + 1) begin
			for(j = 0; j < 32; j = j + 1) begin
				assign memory[i][j] = 32'b0;
			end
		end
	endgenerate
endmodule

// read from address pointed to by PC
module read_memory(memory, PC, word);
	input[31:0][31:0] memory;
	input[4:0] PC;
	output[31:0] word;

	assign word = memory[PC];

endmodule


module SCDataPath(ALU_output, PC, reset, clk);
	input[4:0] PC;
	input reset, clk;
	reg_5bit pc_rf(PC, 32'b0, clk, reset);

	wire[31:0][31:0] instr_mem;
	IM_Rformat im0(instr_mem);

	// instruction fetch
	wire[31:0] instruction;
	read_memory(instr_mem, PC, instruction);

	// generate control signals
	wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;
	AND_array ar0(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2, instruction[31:27]);

	// read from RF
	wire[31:0] ReadData1, ReadData2;
	RegFile rf_read(clk, reset, instruction[26:22], instruction[21:17], 0, 0, 0, ReadData1, ReadData2)

	// ALU operation
	wire ALUOp, cout;
	wire[2:0] Op;
	assign ALUOp = {ALUOp2, ALUOp1};
	ALUControl ac0(Op, ALUOp, instruction[5:0])
	ALU alu0(ReadData1, ReadData2, 0, 0, Op, cout, ALU_output);

	RegFile rf_write(clk, reset, instruction[26:22], instruction[21:17], ALU_output, instruction[16:12], RegWrite, ReadData1, ReadData2);
endmodule
	