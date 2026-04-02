/*===================================================================
	NAME:	async_rst_sync_release
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:
===================================================================*/

module async_rst_sync_release (
	input wire	clk,
	input wire	rstn,
	output wire sync_rstn
);
	reg [1:0] rstn_sync_r;

	always@(posedge clk or negedge rstn) begin
		if(!rstn)
			rstn_sync_r <= 2'b00;
		else
			rstn_sync_r <= {rstn_sync_r[0],1'b1};
	end

	assign sycn_rstn = rstn_sync_r[1];

endmodule