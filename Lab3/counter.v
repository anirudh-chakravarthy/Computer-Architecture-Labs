module jkff(j,k,clk,en,q);
	input j,k,clk,en;
	output q;
	reg q;

	always @ (posedge clk) begin
		if (!en) q <= 1'b0;
		else q <= (j & ~q) | (~k & q);
	end
endmodule

// jk flip flip testing
// module testbench;
// 	reg j,k,clk,en;
// 	wire q;
// 	jkff j0(j,k,clk,en,q);

// 	always #5 clk = ~clk;

// 	initial begin
// 		$monitor(,$time," j=%b, k=%b, clk=%b, q=%b",j,k,clk,q);
// 		en=1'b0; clk=1'b0;
// 		#12 en=1'b1; j=1'b0; k=1'b0; 
// 		#12 j=1'b0; k=1'b1;
// 		#12 j=1'b1;
// 		#12 k=1'b0;
// 		#12 $finish;
// 	end
// endmodule

module synccounter(clk,en,q);
	input clk,en;
	output[3:0] q;
	wire p0,p1;
	
	jkff j0(1'b1,1'b1,clk,en,q[0]);
	jkff j1(q[0],q[0],clk,en,q[1]);
	
	and a0(p0, q[0],q[1]);
	jkff j2(p0,p0,clk,en,q[2]);

	and a1(p1,p0,q[2]);
	jkff j3(p1,p1,clk,en,q[3]);
endmodule

module testbench;
	reg clk,en;
	wire[3:0] q;
	synccounter c(clk,en,q);

	always #5 clk = ~clk;

	initial begin
		$monitor(,$time," clk=%b, q=%4b",clk,q);
		clk=0; en=0;
		#12 en=1;
	end

	initial begin
		$dumpfile("counter.vcd");
		$dumpvars;
	end
endmodule