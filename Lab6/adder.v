module mux2to1(out,s,in1,in2);
	input in1, in2, s;
	output out;
	wire nots, a1, a2;
	not (nots,s);
	and (a1,s,in2);
	and (a2,nots,in1);
	or (out,a1,a2); 
endmodule

module bit32_2to1mux(out,s,in1,in2);
	input [31:0]in1, in2;
	input s;	
	output [31:0]out;
	genvar j;
	
	generate for (j=0; j<32; j=j+1) 
	begin: mux_loop
		mux2to1 m1(out[j],s,in1[j],in2[j]);
	end
	endgenerate
endmodule

// for 32-bit adder
module DECODER(x,y,z,d);
	input x,y,z;
	output [0:7]d;
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

module FADDER(x,y,z,s,c);
	input x,y,z;
	output s,c;
	wire [0:7]d;
	
	DECODER dec(x,y,z,d);
	assign s = d[1] | d[2] | d[4] | d[7],
		   c = d[3] | d[5] | d[6] | d[7];
endmodule

module ADDER_8bit(x,y,z,s,c);
	input [7:0]x,y;
	input z;
	output [7:0]s;
	output c;
	wire [0:6]cin;
	
	FADDER f0(x[0],y[0],z,s[0],cin[0]);
	FADDER f1(x[1],y[1],cin[0],s[1],cin[1]);
	FADDER f2(x[2],y[2],cin[1],s[2],cin[2]);
	FADDER f3(x[3],y[3],cin[2],s[3],cin[3]);
	FADDER f4(x[4],y[4],cin[3],s[4],cin[4]);
	FADDER f5(x[5],y[5],cin[4],s[5],cin[5]);
	FADDER f6(x[6],y[6],cin[5],s[6],cin[6]);
	FADDER f7(x[7],y[7],cin[6],s[7],c);
endmodule

module ADDER_32bit(x,y,z,s,c);
	input [31:0]x,y;
	input z;
	output [31:0]s;
	output c;
	wire [0:2]cin;
	
	ADDER_8bit a1(x[7:0],y[7:0],z,s[7:0],cin[0]);
	ADDER_8bit a2(x[15:8],y[15:8],cin[0],s[15:8],cin[1]);
	ADDER_8bit a3(x[23:16],y[23:16],cin[1],s[23:16],cin[2]);
	ADDER_8bit a4(x[31:24],y[31:24],cin[2],s[31:24],c);
endmodule