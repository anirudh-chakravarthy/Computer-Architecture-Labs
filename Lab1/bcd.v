// gate level model
module bcd(b, g);
	input [3:0]b;
	output [3:0]g;
	
	or o1(g[3], b[3], 0);
	or o2(g[2], b[2], b[3]);
	xor x1(g[1], b[1], b[2]);
	xor x2(g[0], b[1], b[0]);
endmodule


// dataflow model
module bcd_df(b, g);
	input [3:0]b;
	output [3:0]g;
	
	assign g[3] = b[3];
	assign g[2] = b[2] | b[3];
	assign g[1] = (~b[1]&b[2]) | (b[1]&~b[2]);
	assign g[0] = (~b[1]&b[0]) | (b[1]&~b[0]);
endmodule

module testbench;
	reg [3:0]a; // input variable
	wire [3:0]b; // output variable
	//bcd convertor(a, b);
	bcd_df convertor2(a, b);
	initial
		begin
			$monitor(,$time, " a=%4b, b=%4b",a,b);
			#0 a=4'b0000;
			repeat(9)
			#10 a=a+4'b0001; 
		end
endmodule
	