module async_fifo_rdptr #(
	parameter integer DATA_WIDTH = 32,
	parameter integer FIFO_DEPTH = 128
)(
	input 								clk_rd,
	input 								rstn_rd,
	input								rd_en,
	input [$clog2(FIFO_DEPTH):0]		wr_ptr_synced,
	output reg							rd_empty,
	output [$clog2(FIFO_DEPTH)-1:0]		rd_addr,
	output reg [$clog2(FIFO_DEPTH):0]	rd_ptr_gray
);
	reg [$clog2(FIFO_DEPTH):0] rd_ptr_bin;

	assign rd_addr = rd_ptr_bin[$clog2(FIFO_DEPTH)-1:0];

	wire [$clog2(FIFO_DEPTH):0] rd_ptr_bin_next  = (rd_en & !rd_empty)? (rd_ptr_bin + 1'b1) : rd_ptr_bin;
	wire [$clog2(FIFO_DEPTH):0] rd_ptr_gray_next = (rd_ptr_bin_next>>1) ^ rd_ptr_bin_next;

	always@(posedge clk_rd or negedge rstn_rd)begin
		if(!rstn_rd) begin
			rd_ptr_gray <= 'd0;
			rd_ptr_bin <= 'd0;
		end else begin
			rd_ptr_gray <= rd_ptr_gray_next;
			rd_ptr_bin <= rd_ptr_bin_next;
		end
	end

	always@(posedge clk_rd or negedge rstn_rd)begin
		if(!rstn_rd)
			rd_empty <= 1'b1;
		else if(wr_ptr_synced==rd_ptr_gray_next)
			rd_empty <= 1'b1;
		else
			rd_empty <= 1'b0;
	end

endmodule