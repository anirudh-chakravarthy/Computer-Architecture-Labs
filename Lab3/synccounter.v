module jkff(j, k, clock, en, q);
	input j, k, clock, en;
	output q;
	reg q;
	
	always @ (posedge clock)
	begin
		if (!en) q <= 1'b0;
		else q <= (j & !q) | (!k & q);
	end
endmodule

module synccounter(clk, out);
	input clk;
	wire j3;
	output [3:0]out;
	
	jkff ffa(1'b1,1'b1,clk,1'b1,out[0]) ;
	jkff ffb(out[0],out[0],clk,1'b1,out[1]);
	jkff ffc(out[1],out[1],clk,1'b1,out[2]);
	and a(j3, out[0], out[1], out[2]);
	jkff ffd(out[2],out[2],clk,1'b1,out[3]);
endmodule

// to test counter
module testbench;
	reg clk;
	wire [3:0]out;
	synccounter c1(clk, out);
	
	always @ (posedge clk) begin
	$display($time," out=%4b, clk=%b\n",out,clk);
	end
	
	initial begin
	forever begin
		clk=0;
		#5 clk=1;
		#5 clk=0;
	end
	end
	
	initial begin 
	$dumpfile("synccounter.vcd");
	$dumpvars;
	end
endmodule
	

// to test JK Flipflop
/* module Testing;
	reg j,k,clk,en;
	wire q;
	jkff jk (j,k,clk,en,q);
	
	always @ (posedge clk) begin
	$display($time," j=%b, k=%b, clk=%b, en=%b, q=%b\n",j,k,clk,en,q);
	end
	
	initial begin
	forever begin
		clk=0;
		#5 clk=1;
		#5 clk=0;
	end
	end
	
	initial begin
	j=0;k=0;en=0;
	#12 en=1;
	#12 j=0;k=1;
	#12 j=1;k=0;
	#12 j=1;k=1;
	#12 en=0;
	end
	
	initial begin 
	$dumpfile("jkff.vcd");
	$dumpvars;
	end
endmodule */