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
	output[31:0] ALU_output;
	reg_5bit pc_rf(PC, 32'b0, clk, reset);

	wire[31:0][31:0] instr_mem;
	IM_Rformat im0(instr_mem);

	// instruction fetch
	wire[31:0] instruction;
	read_memory rm0(instr_mem, PC, instruction);

	// generate control signals
	wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;
	wire[5:0] opcode;
	assign opcode = instruction[31:26];
	ANDarray ar0(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2, opcode);

	// read from RF
	wire[31:0] ReadData1, ReadData2;
	wire[4:0] ReadReg1, ReadReg2;
	assign ReadReg1 = instruction[26:22];
	assign ReadReg2 = instruction[21:17];
	RegFile rf_read(clk, reset, ReadReg1, ReadReg2, 0, 0, 0, ReadData1, ReadData2);

	// ALU operation
	wire ALUOp, cout;
	wire[2:0] Op;
	assign ALUOp = {ALUOp2, ALUOp1};
	ALUControl ac0(Op, ALUOp, instruction[5:0]);
	ALU alu0(ReadData1, ReadData2, 0, 0, Op, cout, ALU_output);

	// RF write back
	wire[4:0] WriteReg;
	assign WriteReg = instruction[16:12];
	RegFile rf_write(clk, reset, ReadReg1, ReadReg2, ALU_output, WriteReg, RegWrite, ReadData1, ReadData2);
endmodule

module TestBench;
    wire [31:0] ALU_output;
    reg [31:0] PC;
    reg reset,clk;
	SCDataPath SCDP(ALU_output,PC,reset,clk);
    initial begin
		$monitor("at time %0d IPC = %d, Reset = %d , CLK = %d , ALU Output = %d",$time,start_pc,rst,clk, ALU_output);
		#0 clk=0; PC=5; #120 reset = 1;
		#400 $stop;
	end
	always begin
        #20 clk = ~clk;
    end
endmodule
	