module bcdtogray_gate(b,g);
	input[3:0] b;
	output[3:0] g;

	xor x1(g[0],b[0],b[1]);
	xor x2(g[1],b[1],b[2]);
	xor x3(g[2],b[2],b[3]);
	or o1(g[3],b[3],0);
endmodule


module bcdtogray_df(b,g);
	input[3:0] b;
	output[3:0] g;

	assign g[0]=b[0]^b[1];
	assign g[1]=b[1]^b[2];
	assign g[2]=b[2]^b[3];
	assign g[3]=b[3];
endmodule

module testbench;
	reg[3:0] b;
	wire[3:0] g;
	bcdtogray_gate g1(b,g);
	// bcdtogray_df g2(b,g);
	initial begin
		$monitor(,$time," b=%4b, g=%4b",b,g);
		#2 b=4'b0000;
		#2 b=4'b0001;
		#2 b=4'b0010;
		#2 b=4'b0011;
		#2 b=4'b0100;
		#2 b=4'b0101;
		#2 b=4'b0110;
		#2 b=4'b0111;
		#2 b=4'b1000;
		#2 b=4'b1001;
		#10 $finish;
	end
endmodule
