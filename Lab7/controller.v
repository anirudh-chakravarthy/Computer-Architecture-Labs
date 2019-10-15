module controller(S,op,ns,PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWr,RegDst);
	input[3:0] S;
	input[5:0] op;
	output[3:0] ns;
	output PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,RegWr,RegDst,ALUSrcA;
	output[1:0] ALUOp,ALUSrcB,PCSrc;
	
	// control signals
	assign PCWrite = (~S[3]&~S[2]&~S[1]&~S[0]) | (S[3]&~S[2]&~S[1]&S[0]);
	assign PrWriteCond = S[3]&~S[2]&~S[1]&~S[0];
	assign IorD = (~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&~S[1]&S[0]);
	assign MemR = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&S[1]&S[0]);
	assign MemW = ~S[3]&S[2]&~S[1]&S[0];
	assign IRWrite = ~S[3]&~S[2]&~S[1]&~S[0];
	assign MemtoReg = ~S[3]&S[2]&~S[1]&~S[0];
	assign RegWr = (~S[3]&S[2]&~S[1]&~S[0]) | (~S[3]&S[2]&S[1]&S[0]);
	assign RegDst = ~S[3]&S[2]&S[1]&S[0];
	assign ALUSrcA = (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]) | (S[3]&~S[2]&~S[1]&~S[0]);
	
	assign ALUSrcB[1] = (~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&~S[2]&S[1]&~S[0]);
	assign ALUSrcB[0] = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]);
	
	assign ALUOp[1] = ~S[3]&S[2]&S[1]&~S[0];
	assign ALUOp[0] = S[3]&~S[2]&~S[1]&~S[0];
	
	assign PCSrc[1] = S[3]&~S[2]&~S[1]&S[0];
	assign PCSrc[0] = S[3]&~S[2]&~S[1]&~S[0];
	
	// next state
	assign ns[3] = (S[3]&~S[2]&~S[1]&~S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0]);
	assign ns[2] = (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]) | (~S[3]&~S[2]&S[1]&~S[0]&op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0]) | 
					(~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&S[1]&~S[0]);
	assign ns[1] = (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]) | (~S[3]&~S[2]&~S[1]&S[0]&op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]) | 
					(~S[3]&~S[2]&~S[1]&S[0]&op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0]) | (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]);
	assign ns[0] = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&S[2]&S[1]&S[0]);
endmodule


module testbench;
	reg[3:0] s;
	reg[5:0] op;
	wire[3:0] ns;
	wire PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,RegWr,RegDst,ALUSrcA;
	wire[1:0] ALUOp,ALUSrcB,PCSrc;
	controller c(s,op,ns,PCWrite,PrWriteCond,IorD,MemR,MemW,IRWrite,MemtoReg,PCSrc,ALUOp,ALUSrcA,ALUSrcB,RegWr,RegDst);
	
	initial
	begin
		s = 4'b0;
		op = 6'b100011;
		$monitor(,$time," Next State=%4b",ns);

		#5 s=4'b0001;
		#5 s=4'b0010;
		#5 s=4'b0011;
		#5 s=4'b0100;
		$finish;
	end
endmodule
		