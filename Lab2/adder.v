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


// 1-bit adder testbench
/* module testbench;
	reg x,y,z;
	wire s,c;
	FADDER f1(x,y,z,s,c);
	initial
		$monitor(,$time,"x=%b,y=%b,z=%b,s=%b,c=%b",x,y,z,s,c);
	initial
		begin         
		#0 x=1'b0; y=1'b0; z=1'b0;
        #4 x=1'b0; y=1'b0; z=1'b1;
        #4 x=1'b0; y=1'b1; z=1'b0;
        #4 x=1'b0; y=1'b1; z=1'b1;
        #4 x=1'b1; y=1'b0; z=1'b0;
        #4 x=1'b1; y=1'b0; z=1'b1;
        #4 x=1'b1; y=1'b1; z=1'b0;
        #4 x=1'b1; y=1'b1; z=1'b1; 
		end
endmodule */

// 8-bit adder testbench
/* module testbench;
	reg [7:0]x,y;
	reg z;
	wire [7:0]s;
	wire c;
	
	ADDER_8bit a1(x,y,z,s,c);
	initial
		begin
		$monitor(,$time,"x=%8b,y=%8b,z=%b,s=%8b,c=%b",x,y,z,s,c);
		#0 x=8'b00000000; y=8'b00000000; z=1'b0;
		#4 x=8'b00000000; y=8'b00000000; z=1'b1;
		#4 x=8'b10000000; y=8'b01000000; z=1'b0;
		#4 x=8'b11111111; y=8'b11111111; z=1'b0;
		end
endmodule */


// 32-bit adder testbench
module testbench;
	reg [31:0]x,y;
	reg z;
	wire [31:0]s;
	wire c;
	
	ADDER_32bit a1(x,y,z,s,c);
	initial
		begin
		$monitor(,$time,"x=%32b,y=%32b,z=%b,s=%32b,c=%b",x,y,z,s,c);
		#0 x=32'b0; y=32'b0; z=1'b0;
		#4 x=32'b0; y=32'b0; z=1'b1;
		#4 x=32'b1; y=32'b1; z=1'b0;
		// #4 x=32'b11111111; y=32'b11111111; z=1'b0;
		end
endmodule