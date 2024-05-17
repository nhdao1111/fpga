module fix_div #(
	//Parameterized values
	parameter Q = 33,
	parameter N = 33
	)
	(
	input 	[N-1:0] i_dividend,
	input 	[N-1:0] i_divisor,
	input 	i_start,
	input 	clk,
	input   rst_n,
	output 	logic [N-1:0] o_quotient_out_int,
	output  logic [Q-1:0] o_quotient_out_frac,
	output 	logic o_complete

	);
 
	reg [2*N+Q-3:0]	reg_working_quotient;	
	reg [N+Q-1:0] 		reg_quotient;				
	reg [N-2+Q:0] 		reg_working_dividend;	
	reg [2*N+Q-3:0]	reg_working_divisor;		
 
	reg [N-1:0] 			reg_count; 		
													
										 
	reg					reg_done;			
	reg					reg_sign;			

 
	initial reg_done = 1'b1;				
	
	initial reg_sign = 1'b0;				

	initial reg_working_quotient = 0;	
	initial reg_quotient = 0;				
	initial reg_working_dividend = 0;	
	initial reg_working_divisor = 0;		
 	initial reg_count = 0; 		

 
	assign o_quotient_out_int[N-2:0] = reg_quotient[N+Q-2:Q];	
	assign o_quotient_out_frac[Q-1:0] = reg_quotient[Q-1:0];
	assign o_quotient_out_int[N-1] = reg_sign;						
	assign o_complete = reg_done;


	always_ff @(posedge clk or negedge rst_n) begin : proc_o_qiotient_out
		if(~rst_n) begin
			reg_done <= 1'b1;														
			reg_count <= N+Q-1;											
			reg_working_quotient <= 0;									
			reg_working_dividend <= 0;									
			reg_working_divisor <= 0;									

			reg_quotient <= 0;												
			reg_sign <= 0;

		end else begin
			if( reg_done && i_start ) begin										
			
			reg_done <= 1'b0;														
			reg_count <= N+Q-1;											
			reg_working_quotient <= 0;									
			reg_working_dividend <= 0;									
			reg_working_divisor <= 0;									

			reg_working_dividend[N+Q-2:Q] <= i_dividend[N-2:0];				
			reg_working_divisor[2*N+Q-3:N+Q-1] <= i_divisor[N-2:0];		

			reg_sign <= i_dividend[N-1] ^ i_divisor[N-1];		
			end 
		else if(!reg_done) begin
			reg_working_divisor <= reg_working_divisor >> 1;	
			reg_count <= reg_count - 1;								

			//	If the dividend is greater than the divisor
			if(reg_working_dividend >= reg_working_divisor) begin
				reg_working_quotient[reg_count] <= 1'b1;										
				reg_working_dividend <= reg_working_dividend - reg_working_divisor;	
				end
 
			//stop condition
			if(reg_count == 0) begin
				reg_done <= 1'b1;										
				reg_quotient <= reg_working_quotient;			
					end
			else
				reg_count <= reg_count - 1;	
			end
		end
	end
 
	
endmodule

module Test_Di;

	// Inputs
	reg [32:0] i_dividend;
	reg [32:0] i_divisor;
	reg i_start;
	reg i_clk;
	reg rst_n;

	// Outputs
	wire [32:0] o_quotient_out_int;
	wire [32:0] o_quotient_out_frac;
	wire o_complete;


	// Instantiate the Unit Under Test (UUT)
	fix_div uut (
		.i_dividend(i_dividend), 
		.i_divisor(i_divisor), 
		.i_start(i_start), 
		.clk(i_clk), 
		.o_quotient_out_int(o_quotient_out_int),
		.o_quotient_out_frac(o_quotient_out_frac), 
		.o_complete(o_complete), 
		.rst_n(rst_n)
	);

	reg [10:0]	count;

	initial begin
		// Initialize Inputs
		i_dividend = 1;
		i_divisor = 1;
		i_start = 0;
		i_clk = 0;
		
		count <= 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		forever #2 i_clk = ~i_clk;
	end
		initial begin
		#100;
		i_start = 1;
		i_dividend = 32'd1034;
		i_divisor =  31'd2345;

		end
        
		// always @(posedge i_clk) begin
		// 	if (count == 65) begin
		// 		count <= 0;
		// 		i_start <= 1'b1;
		// 		end
		// 	else begin				
		// 		count <= count + 1;
		// 		i_start <= 1'b0;
		// 		end
		// 	end

		// always @(count) begin
		// 	if (count == 65) begin
		// 		if ( i_divisor > 32'h1FFFFFFF ) begin
		// 			i_divisor <= 1;
		// 			i_dividend = (i_dividend << 1) + 3;
		// 			end
		// 		else
		// 			i_divisor = (i_divisor << 1) + 1;
		// 		end
		// 	end
			
		

endmodule