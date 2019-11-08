module comp(a,b,gt,eq,lt);
	input[3:0] a,b;
	output reg gt,lt,eq;

	always @ (a or b) begin
		if (a[3] < b[3]) begin 
			gt = 0; 
			lt = 1; 
			eq = 0;
		end
		else if (a[3] > b[3]) begin 
			gt = 1; 
			lt = 0; 
			eq = 0;
		end
		else begin 
			if (a[2] < b[2]) begin 
				gt = 0; 
				lt = 1; 
				eq = 0;
			end
			else if (a[2] > b[2]) begin 
				gt = 1; 
				lt = 0; 
				eq = 0;
			end
			else begin
				if (a[1] < b[1]) begin
					gt = 0; 
					lt = 1; 
					eq = 0;
				end
				else if (a[1] > b[1] ) begin
					gt = 1; 
					lt = 0; 
					eq = 0;
				end
				else begin
					if (a[0] < b[0]) begin
						gt = 0; 
						lt = 1; 
						eq = 0;
					end
					else if (a[0] > b[0]) begin 
						gt = 1; 
						lt = 0; 
						eq = 0;
					end
					else begin
						gt = 0; 
						lt = 0;
						eq = 1;
					end
				end
			end
		end
	end
endmodule

module testbench;
	reg[3:0] a,b;
	wire gt,lt,eq;
	comp c(a,b,gt,eq,lt);
	initial begin
		$monitor(,$time," a=%4b, b=%4b, eq=%b, gt=%b, lt=%b",a,b,eq,gt,lt);
		#0 a=4'b1111; b=4'b1111;
		#5 a=4'b1000;
		#5 b=4'b0000;
		#5 $finish;
	end
endmodule