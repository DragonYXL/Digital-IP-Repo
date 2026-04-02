module async_fifo_wrptr #(
	parameter integer DATA_WIDTH = 32,
	parameter integer FIFO_DEPTH = 128
)(
	input 								clk_wr,
	input 								rstn_wr,
	input								wr_en,
	input [$clog2(FIFO_DEPTH):0]		rd_ptr_synced,
	output reg							wr_full,
	output [$clog2(FIFO_DEPTH)-1:0]		wr_addr,
	output reg [$clog2(FIFO_DEPTH):0]	wr_ptr_gray,
	output reg [$clog2(FIFO_DEPTH):0]	fifo_margin
);
	reg [$clog2(FIFO_DEPTH):0] wr_ptr_bin;

	wire [$clog2(FIFO_DEPTH):0] wr_ptr_bin_next  = (wr_en & !wr_full)? (wr_ptr_bin + 1'b1) : wr_ptr_bin;
	// binary to gray
	wire [$clog2(FIFO_DEPTH):0] wr_ptr_gray_next = (wr_ptr_bin_next>>1) ^ wr_ptr_bin_next;

	assign wr_addr = wr_ptr_bin[$clog2(FIFO_DEPTH)-1:0];

	// gray to binary 
	wire [$clog2(FIFO_DEPTH):0] rd_ptr_bin;
	genvar i;
	generate
		for(i=0;i<=$clog2(FIFO_DEPTH);i=i+1)begin:g2b
			assign rd_ptr_bin[i] = ^rd_ptr_synced[$clog2(FIFO_DEPTH):i];
		end
	endgenerate

	//calculation is not precise and this is critical path
	always@(posedge clk_wr or negedge rstn_wr)begin
		if(!rstn_wr) begin
			fifo_margin <= FIFO_DEPTH;
		end else begin
			fifo_margin <= FIFO_DEPTH - (wr_ptr_bin_next - rd_ptr_bin);
		end
	end

	always@(posedge clk_wr or negedge rstn_wr)begin
		if(!rstn_wr) begin
			wr_ptr_gray <= 'd0;
			wr_ptr_bin <= 'd0;
		end else begin
			wr_ptr_gray <= wr_ptr_gray_next;
			wr_ptr_bin <= wr_ptr_bin_next;
		end
	end

	always@(posedge clk_wr or negedge rstn_wr)begin
		if(!rstn_wr)
			wr_full <= 1'b0;
		else if ( wr_ptr_gray_next == {~rd_ptr_synced[$clog2(FIFO_DEPTH):$clog2(FIFO_DEPTH)-1] , rd_ptr_synced[$clog2(FIFO_DEPTH)-2:0]})
			wr_full <= 1'b1;
		else
			wr_full <= 1'b0;
	end

endmodule