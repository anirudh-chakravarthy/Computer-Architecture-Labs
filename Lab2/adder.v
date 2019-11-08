module decoder(x,y,z,d);
	input x,y,z;
	output[7:0] d;
	wire nx,ny,nz;

	not n1(nx,x);
	not n2(ny,y);
	not n3(nz,z);

	and a0(d[0],nx,ny,nz);
	and a1(d[1],nx,ny,z);
	and a2(d[2],nx,y,nz);
	and a3(d[3],nx,y,z);
	and a4(d[4],x,ny,nz);
	and a5(d[5],x,ny,z);
	and a6(d[6],x,y,nz);
	and a7(d[7],x,y,z);
endmodule

module fadder(s,c,x,y,z);
	input x,y,z;
	wire[7:0] d;
	output s,c;
	decoder d1(x,y,z,d);

	assign s = d[1]|d[2]|d[4]|d[7];
	assign c = d[3]|d[5]|d[6]|d[7];
endmodule

module adder_8bit(s,c,x,y,z);
	input[7:0] x,y; // numbers
	input z; // carry-in
	output[7:0] s; 
	output c; // carry-out
	wire[6:0] c0; // intermediate carry
	
	fadder f0(s[0],c0[0],x[0],y[0],z);	
	fadder f1(s[1],c0[1],x[1],y[1],c0[0]);	
	fadder f2(s[2],c0[2],x[2],y[2],c0[1]);	
	fadder f3(s[3],c0[3],x[3],y[3],c0[2]);	
	fadder f4(s[4],c0[4],x[4],y[4],c0[3]);	
	fadder f5(s[5],c0[5],x[5],y[5],c0[4]);	
	fadder f6(s[6],c0[6],x[6],y[6],c0[5]);	
	fadder f7(s[7],c,x[7],y[7],c0[6]);	
endmodule

module adder_32bit(s,c,x,y,z);
	input[31:0] x,y;
	input z;
	output[31:0] s;
	output c;
	wire[2:0] c0; // intermediate carry

	adder_8bit a0(s[7:0],c0[0],x[7:0],y[7:0],z);
	adder_8bit a1(s[15:8],c0[1],x[15:8],y[15:8],c0[0]);
	adder_8bit a2(s[23:16],c0[2],x[23:16],y[23:16],c0[1]);
	adder_8bit a3(s[31:24],c,x[31:24],y[31:24],c0[2]);
endmodule

module fadder_beh(s,c,x,y,z);
	input x,y,z;
	output reg s,c;

	always @ (x or y or z)
	begin
		if (x == 0) begin
			if (y == 0) begin // 0 + 0 + z
				s = z;
				c = 0;
			end
			else begin // 0 + 1 + z
				s = 1^z;
				c = z;
			end
		end
		else begin
			if (y == 0) begin // 1 + 0 + z
				s = 1^z;
				c = z;
			end
			else begin // 1 + 1 + z
				s = z;
				c = 1;
			end
		end
	end
endmodule

module addsub(s,c,x,y,z,m,v);
	input[3:0] x,y;
	input m,z;
	output[3:0] s;
	output c,v;
	wire[2:0] c0; // intermediate carries
	reg[3:0] t; // temp value for y (if complement needed) 

	always @ (y) begin
		if (m == 0) t = y;
		else t = -y;
	end

	fadder_beh f0(s[0],c0[0],x[0],t[0],z);
	fadder_beh f1(s[1],c0[1],x[1],t[1],c0[0]);
	fadder_beh f2(s[2],c0[2],x[2],t[2],c0[1]);
	fadder_beh f3(s[3],c,x[3],t[3],c0[2]);
	assign v = c0[2] ^ c;
endmodule

module testbench;
	reg[3:0] x,y;
	reg z,m;
	wire[3:0] s;
	wire c,v;
	addsub a(s,c,x,y,z,m,v);
	initial begin
		$monitor(,$time," m=%b, x=%4b, y=%4b, z=%b, s=%4b, c=%b, v=%b",m,x,y,z,s,c,v);
		#0 m=0; x=4'b0; y=4'b0; z=1'b0;
		#5 x=4'b1001;
		#5 y=4'b0001;
		#5 m=1'b1;
		#5 $finish;
	end
endmodule