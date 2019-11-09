/*
NAME: ANIRUDH SRINIVASAN CHAKRAVARTHY
ID: 2017A7PS1195P
*/

module tff(t, clk, reset, q);
	input t, clk, reset; // active low reset pin
	output reg q;
	always @(posedge clk) begin
		if (!reset) q <= 0;
		else q <= t ^ q;
	end
endmodule

module d_ff(d, clk, reset, q);
	input d, clk, reset;
	output reg q;
	always @(posedge clk) begin
		if (!reset) q <= 0;
		else q <= d;
	end
endmodule

module counter_4bit(clk, reset, q);
	input clk, reset;
	output[3:0] q;

	tff ta(1'b1, clk, reset, q[0]);
	tff tb(q[0], clk, reset, q[1]);

	wire t2;
	assign t2 = q[0] & q[1];
	tff tc(t2, clk, reset, q[2]);

	wire t3;
	assign t3 = t2 & q[2];
	tff td(t3, clk, reset, q[3]);
endmodule

module ControlLogic(s, z, x, clk, t0, t1, t2);
	input s, z, x, clk;
	output t0, t1, t2;
	wire da, db, dc; // input to flip-flops

	assign t0 = 1'b1; // WRONG but can't figure out what else to do

	wire nots, notx ,notz;
	not ns(nots, s);
	not nx(notx, x);
	not nz(notz, z);

	// for first d flipflop
	wire p1, p2;
	and a0(p1, t0, nots);
	and a1(p2, t2, z);
	or o0(da, p1, p2);
	d_ff d0(da, clk, s, t0);

	// second d flipflop
	wire q1, q2, q3;
	and a2(q1, t0, s);
	and a3(q2, t2, notx, notz);
	and a4(q3, t1, notx);
	or o1(db, q1, q2, q3);
	d_ff d1(db, clk, s, t1);

	// third d flipflop
	wire r1, r2;
	and a5(r1, t1, x);
	and a6(r2, t2, notz, x);
	or o2(dc, r1, r2);
	d_ff d2(dc, clk, s, t2);
endmodule

module intg(s, clk, x, q, g);
	input s, clk, x;
	output g;
	output[3:0] q; // counter values
	wire t0, t1, t2;

	// for counter
	wire en, reset;
	wire counterclk; // for clock-gating
	assign en = (t1 & x) | (t2 & ~z & x);
	assign reset = t0 & s;
	assign counterclk = clk & en;
	counter_4bit c0(counterclk, reset, q);

	// for controller
	wire z; 
	assign z = q[3] & q[2] & q[1] & q[0];
	ControlLogic cl0(s, z, x, clk, t0, t1, t2);

	// for dff
	wire dg;
	assign dg = z & t2;
	d_ff df0(dg, clk, s, g);
endmodule
	
/* NOTE: counter Testbench - WORKING */
// module tb_counter;
// 	reg clk, reset;
// 	wire[3:0] q;
// 	wire g;
// 	counter_4bit c0(clk, reset, q);

// 	always #500000 clk = ~clk;

// 	initial begin
// 		$monitor(,$time," q=%4b", q);
// 		clk = 1'b0; reset = 1'b0; 
// 		#1000000 reset = 1'b1;
// 		#19000000 $finish;
// 	end 
// endmodule

module tb_g;
	reg clk, s, x;
	wire[3:0] q;
	wire g;
	intg ig0(s, clk, x, q, g);

	always #500000 clk = ~clk;

	initial begin
		clk = 1'b0; s = 1'b0;
		$monitor(,$time," q=%4b, g=%b", q, g);
		#1000000 s = 1'b1; x = 1'b1;
		#19000000 $finish;
	end

	initial begin
		$dumpfile("test.vcd");
		$dumpvars;
	end
endmodule