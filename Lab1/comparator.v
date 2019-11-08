module comparator_beh(a,b,x,y,z);
	input[3:0] a,b;
	output reg x,y,z;
	always @ (a or b) 
	begin
		if(a == b) 
		begin
			x=0;y=0;z=1;
		end
		else if (a < b)
		begin
			x=1;y=0;z=0;
		end
		else 
		begin
			x=0;y=1;z=0;
		end
	end
endmodule

module comparator_df(a,b,x,y,z);
	input[3:0] a,b;
	output x,y,z;
	wire[3:0] p; // to store xnor comparisons

	assign p = ~(a^b); 
	assign z = p[3]&p[2]&p[1]&p[0];
	assign x = (~a[3]&b[3]) | (p[3]&~a[2]&b[2]) | (p[3]&p[2]&~a[1]&b[1]) | (p[3]&p[2]&p[1]&~a[0]&b[0]);
	assign y = (~b[3]&a[3]) | (p[3]&~b[2]&a[2]) | (p[3]&p[2]&~b[1]&a[1]) | (p[3]&p[2]&p[1]&~b[0]&a[0]);
endmodule

module comparator_gate(a,b,x,y,z);
	input[3:0] a,b;
	output x,y,z;
	wire[3:0] na,nb;
	wire x3,x2,x1,x0; // as per diagram
	wire d0,d1,d2,d3,d4,d5,d6,d7; // input to x
	wire e1,e2,e3,e4,e5,e6,e7; // input to x

	not na0(na[0],a[0]);
	not na1(na[1],a[1]);
	not na2(na[2],a[2]);
	not na3(na[3],a[3]);

	not nb0(nb[0],b[0]);
	not nb1(nb[1],b[1]);
	not nb2(nb[2],b[2]);
	not nb3(nb[3],b[3]);

	xnor xn3(x3,a[3],b[3]);
	xnor xn2(x2,a[2],b[2]);
	xnor xn1(x1,a[1],b[1]);
	xnor xn0(x0,a[0],b[0]);

	and a7(d7,na[3],b3);
	and a6(d6,a[3],nb[3]);
	and a5(d5,na[2],b2);
	and a4(d4,a[2],nb[2]);	
	and a3(d3,na[1],b1);
	and a2(d2,a[1],nb[1]);	
	and a1(d1,na[0],b0);
	and a0(d0,a[0],nb[0]);

	and b7(e7,x3,d5);
	and b6(e6,x3,d4);
	and b5(e5,x3,x2,d3);
	and b4(e4,x3,x2,d2);
	and b3(e3,x3,x2,x1,d1);
	and b2(e2,x3,x2,x1,d0);
	and b2(e1,x3,x2,x1,x0);

	and i1(z,e1,e1);
	or o1(x,d7,e7,e5,e3);
	or o2(y,d6,e6,e4,e2);
endmodule

module testbench;
	reg[3:0] a,b;
	wire x,y,z;
	// comparator_beh c1(a,b,x,y,z);
	comparator_df c1(a,b,x,y,z);
	// comparator_gate c1(a,b,x,y,z);
	initial begin
		$monitor(,$time," a=%4b, b=%4b, x=%b, y=%b, z=%b",a,b,x,y,z);
		a=4'b0000; 
		#10 b=4'b0000;
		#20 b=4'b1110;
		#20 a=4'b1111;
		#50 $finish;
	end
endmodule