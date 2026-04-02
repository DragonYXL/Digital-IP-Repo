module async_fifo_sync_unit #(
	parameter integer DATA_WIDTH = 32
)(
	input						target_clk,
	input						target_rstn,
	input [DATA_WIDTH-1:0]		din,
	output reg [DATA_WIDTH-1:0]	synced_dout
);

	reg [DATA_WIDTH-1:0] din_dly;

	always@(posedge target_clk or negedge target_rstn)begin
		if(!target_rstn)
			{synced_dout,din_dly} <= 'd0;
		else
			{synced_dout,din_dly} <= {din_dly,din};
	end

endmodule