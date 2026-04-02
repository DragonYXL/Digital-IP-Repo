/*===================================================================
	NAME:	sync_fifo
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:	FIFO_DEPTH must be 2^n!
			otherwise fifo_margin != FIFO_DEPTH-(wr_ptr - rd_ptr);
===================================================================*/

module sync_fifo #(
	parameter integer FIFO_DEPTH = 128,
	parameter integer DATA_WIDTH = 32
)(
	input 								fifo_clk,
	input 								fifo_rstn,
	input	[DATA_WIDTH-1:0]			data_wr,
	input								wr_en,
	input								rd_en,
	output reg [DATA_WIDTH-1:0]			data_rd,
	output [$clog2(FIFO_DEPTH):0]		fifo_margin,
	output								fifo_full,
	output								fifo_empty
);
	reg [DATA_WIDTH-1:0] fifo_ram [FIFO_DEPTH-1:0];

	reg [$clog2(FIFO_DEPTH):0] wr_ptr;
	reg [$clog2(FIFO_DEPTH):0] rd_ptr;

	// MAX(wr_ptr - rd_ptr) = FIFO_DEPTH
	assign fifo_margin = FIFO_DEPTH-(wr_ptr - rd_ptr);
	assign fifo_full = (wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]) && (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]);
	assign fifo_empty = (wr_ptr == rd_ptr);

	always@(posedge fifo_clk or negedge fifo_rstn)begin
		if(!fifo_rstn)
			wr_ptr <= 'd0;
		else if (wr_en & !fifo_full)
			wr_ptr <= wr_ptr + 'd1;
	end

	always@(posedge fifo_clk)begin
		if(wr_en & !fifo_full)
			fifo_ram[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= data_wr;
	end

	always@(posedge fifo_clk or negedge fifo_rstn)begin
		if(!fifo_rstn)
			rd_ptr <= 'd0;
		else if (rd_en && !fifo_empty)
			rd_ptr <= rd_ptr + 'd1;
	end

	always@(posedge fifo_clk or negedge fifo_rstn)begin
		if(!fifo_rstn)
			data_rd <= 'd0;
		else if (rd_en & !fifo_empty)
			data_rd <= fifo_ram[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
	end

endmodule