/*===================================================================
	NAME:	clock_gating
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:	Synthesis Friendly clock_gating
===================================================================*/
module clock_gating (
	input wire CK,
	input wire E,
	input wire SE,
	output wire ECK
);
	reg en_latch;

	always@(*)begin
		if(!CK) begin
			en_latch = SE | E ;
		end
	end

	assign ECK = CK & en_latch;

endmodule