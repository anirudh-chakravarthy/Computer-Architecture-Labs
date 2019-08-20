module mux(a, b, s, f);
	input a, b, s;
	output f;
	wire c, d, e;
	
	not n1(c, s);
	and a1(d, c, a);
	and a2(e, s, b);
	or o1(f, d, e);
endmodule


module testbench;
	reg a, b, s; // input variable
	wire f; // output variable
	mux mux_gate(a,b,s,f);
	initial
		begin
			$monitor(,$time, " a=%b, b=%b, s=%b, f=%b",a,b,s,f);
			#0 a=1'b0;b=1'b1; // 1'b == 1 bit binary value (followed by 0/1)
			#2 s=1'b1; // # == time stamp
			#5 s=1'b0;
			#10 a=1'b1;b=1'b0;
			#15 s=1'b1;
			#20 s=1'b0;
			#100 $finish;
		end
endmodule