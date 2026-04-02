/*===================================================================
	NAME:	watchdog timer
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:

===================================================================*/

module watchdog_timer #(
	parameter MAX_CYCLE = 32'd100_000_000
)(
	input wire sys_clk,
	input wire sys_rstn,
	input wire feed_dog,
	output reg watchdog_rstn
);
	localparam CNT_WIDTH = $clog2(MAX_CYCLE);

	reg[CNT_WIDTH-1:0] wd_cnt;

	always @(posedge sys_clk or negedge sys_rstn)begin
		if(!sys_rstn)begin
			wd_cnt <= {(CNT_WIDTH){1'b0}};
			watchdog_rstn <= 1'b1;
		end else if (feed_dog) begin
			wd_cnt <= {(CNT_WIDTH){1'b0}};
			watchdog_rstn <= 1'b1;
		end else if ( wd_cnt >= MAX_CYCLE -1'b1 )begin
			watchdog_rstn <= 1'b0;
		end else begin
			wd_cnt <= wd_cnt + 1'b1;
			watchdog_rstn <= 1'b1;
		end
	end

endmodule