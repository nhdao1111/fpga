module fix_add 
#(parameter N = 32)
	(
	input clk,    // Clock
	input [N:0] addend1,
	input [N:0] addend2,
	input rst_n,  // Asynchronous reset active low
	output logic [N+1:0]sum 
);
	always_ff @(posedge clk or negedge rst_n) begin : proc_add
		if(~rst_n) begin
			sum <= 0;
		end else begin
			// same sign
			 if (addend1[N] == addend2[N]) begin
			 	sum[N+1] <= addend1[N];
			 	sum[N:0] <= addend1[N-1:0] + addend2[N-1:0]; 
			 end
			 // diffirent sign
			 else if (addend1[N] == 0 && addend2[N] == 1) begin
			 	if (addend1[N-1:0] >= addend2[N-1:0]) begin
			 		sum[N+1] <= 0;
			 		sum[N:0] <= addend1[N-1:0] - addend2[N-1:0];
			 	end
			 	else begin
			 		sum[N:0] <= addend2[N-1:0] - addend1[N-1:0];
			 		if((addend2[N-1:0] - addend1[N-1:0]) ==0)
			 			sum[N+1] <= 0;
			 		else
			 			sum[N+1] <= 1;

			 	end
			 end

			 else begin
			 	if (addend1[N-1:0] >= addend2[N-1:0]) begin
			 		sum[N:0] <= addend1[N-1:0] - addend2[N-1:0];
			 		if((addend1[N-1:0] - addend2[N-1:0]) ==0)
			 			sum[N+1] <= 0;
			 		else
			 			sum[N+1] <= 1;
			 	end
			 	else begin
			 		sum[N+1] <= 0;
			 		sum[N:0] <= addend2[N-1:0] - addend1[N-1:0];
			 	end
			 end
		end
	end


endmodule : fix_add

module fix_add_tb;
	logic [32:0] addend1;
	logic [32:0] addend2;
	logic [33:0] sum;
	logic clk;
	logic rst_n;

fix_add fix_add(
	.clk    (clk),
	.rst_n (rst_n),
	.addend1(addend1),
	.addend2(addend2),
	.sum(sum)
	);

	always #1 clk =~clk;
	initial begin
		clk = 0;
		addend1 = 32'b0;
		addend2 = 32'b0;
		rst_n = 0;
	end
	initial begin
		#2 rst_n = 1;
		addend1 = 33'h100001234;
		addend2 = 33'h123;
		#5;
		addend1 = 33'hffffffff;
		addend2 = 33'hffffffff;
		#10 $finish;

	end

endmodule