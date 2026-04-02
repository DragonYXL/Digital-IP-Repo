/*===================================================================
	NAME:	pulse_sync
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:	CDC for pulse from fast to slow and slow to fast
			if s2f pulse interval of src >= 2 * clk_dst

			assign pos_edge = signal & (~signal_d1);
			assign neg_edge = (~signal) & signal_d1;
			assign dual_edge = signal ^ signal_d1;
===================================================================*/

module pulse_sync (
	input wire	clk_src,
	input wire	rstn_src,
	input wire	pulse_src,
	input wire	clk_dst,
	input wire	rstn_dst,
	output wire pulse_dst
);
	reg pulse_toggle;

	always@(posedge clk_src or negedge rstn_src)begin
		if(!rstn_src)
			pulse_toggle <= 1'b0;
		else
			pulse_toggle <= pulse_det ^ pulse_src;
	end

	// [1:0] for sync [2:1] for posedge and negedge
	reg [2:0]src2dst_sync;

	always@(posedge clk_dst or negedge rstn_dst)begin
		if(!rstn_dst)
			src2dst_sync <= 3'd0;
		else
			src2dst_sync <= {fast2slow_sync[1],fast2slow_sync[0],pulse_toggle};
	end

	assign pulse_dst = src2dst_sync[2] ^ fast2slow_sync[1];

endmodule