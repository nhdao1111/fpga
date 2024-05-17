
module PWLCM_map (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [31:0] xp,
	input [30:0] pp,
	input start,
	output logic [31:0] xpn
);
	wire [32:0] xp_in;
	wire [32:0] pp_in;
	assign xp_in ={0,xp};
	assign pp_in = {00,pp};
	logic [32:0] pre_result_1;
	logic pre_finish_1;
	logic pre_finish_2;
	logic  [33:0] sum_of_add2;
	logic [33:0] pre_result_2;

	fix_div div1 (
			.clk                (clk),
			.rst_n              (rst_n),
			.i_dividend         (xp_in),
			.i_divisor          (pp_in),
			.i_start            (start),
			.o_complete         (pre_finish_1),
			.o_quotient_out_frac(pre_result_1)
			);

	fix_add add2 (
			.clk(clk),
			.rst_n(rst_n),
			.addend1(xp_in),
			.addend2({10,pp}),
			.sum(sum_of_add2)
		)

	always_ff @(posedge clk or negedge rst_n) begin : proc_xpn
		if(~rst_n) begin//
			xpn <= 0;
		end //
		else begin///
			if((xp >= 32'b0) && (xp < {0,pp}) ) begin//
		
				if (pre_finish_1 == 1) begin				
					xpn <= pre_result_1[32:1];
				end
				else 
					xpn <= xpn;

				end//

			else if (xp >= pp  && xp < 32'h80000000) begin

		
			end 
			else if (xp >= 32'h80000000 && xp < (33'h1000000 - {00,pp} ) ) begin
	
			end
			else begin
			
			end
	
	end///

end


endmodule : PWLCM_map

module PWLCM_map_tb ;
	logic clk;    // Clock
	logic rst_n;  // Asynchronous reset active low
	logic [31:0] xp;
	logic [30:0] pp;
	logic [31:0] xpn;
	logic i_start;
	PWLCM_map PWLCM_map(
		.clk(clk),
		.rst_n(rst_n),
		.xp(xp),
		.pp(pp),
		.xpn(xpn),
		.start(i_start)

		);
	always #1 clk =~clk;
	initial begin
		i_start = 0;
		clk = 0;
		xp = 0;
		pp = 0;
		rst_n = 0;

	end
	initial begin
		#10; 
		rst_n = 1;
		#1 
		i_start = 1;
		xp = 32'd1034;
		pp =  31'd2345;
		#100;
		#50 $finish;
	end

endmodule : PWLCM_map_tb