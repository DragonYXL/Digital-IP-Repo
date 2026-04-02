/*===================================================================
	NAME:	async_fifo
	DATE:	2025.12
	AUTHOR:	xlyan
	INFO:
	NOTE:	FIFO_DEPTH must be 2^n!
			otherwise fifo_margin != FIFO_DEPTH-(wr_ptr - rd_ptr);
===================================================================*/
module async_fifo_top #(
    parameter integer DATA_WIDTH = 32,
    parameter integer FIFO_DEPTH = 128
)(
    // Clock domain A (Write)
    input                       clk_wr,
    input                       rstn_wr,
    input                       wr_en,
    input  [DATA_WIDTH-1:0]     data_wr,
    output                      fifo_full,
    output [$clog2(FIFO_DEPTH):0] fifo_margin,

    // Clock domain B (Read)
    input                       clk_rd,
    input                       rstn_rd,
    input                       rd_en,
    output [DATA_WIDTH-1:0]     data_rd,
    output                      fifo_empty
);

    //================================================================//
    //                      Internal Signals                          //
    //================================================================//
    // Pointer Width: Address bits + 1 extra bit for wrap-around check
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH); 

    // Write Domain Signals
    wire [PTR_WIDTH-1:0]    wr_addr;
    wire [PTR_WIDTH:0]      wr_ptr_gray;
    wire [PTR_WIDTH:0]      rptr_gray_synced_to_wr;
    wire                    wr_full_int;

    // Read Domain Signals
    wire [PTR_WIDTH-1:0]    rd_addr;
    wire [PTR_WIDTH:0]      rd_ptr_gray;
    wire [PTR_WIDTH:0]      wptr_gray_synced_to_rd;
    wire                    rd_empty_int;

    // Output Assignments
    assign fifo_full  = wr_full_int;
    assign fifo_empty = rd_empty_int;

    //================================================================//
    //                        Sub-modules                             //
    //================================================================//

    //----------------------------------------------------------------//
    // 1. Dual Port RAM (Storage)
    //----------------------------------------------------------------//
    async_fifo_dualram #(
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) u_dualram (
        // Write Port (Clock A)
        .clk_a      (clk_wr),
        .we_a       (wr_en & ~wr_full_int),
		.addr_a     (wr_addr),
        .din_a      (data_wr),
        .dout_a     (),

        // Read Port (Clock B)
        .clk_b      (clk_rd),
        .we_b       (1'b0),
        .addr_b     (rd_addr),
        .din_b      ({DATA_WIDTH{1'b0}}),
        .dout_b     (data_rd)
    );

    //----------------------------------------------------------------//
    // 2. Write Pointer Handler
    //----------------------------------------------------------------//
    async_fifo_wrptr #(
        .DATA_WIDTH (DATA_WIDTH),
		.FIFO_DEPTH (FIFO_DEPTH)
    ) u_wrptr (
        .clk_wr         (clk_wr),
        .rstn_wr        (rstn_wr),
        .wr_en          (wr_en),
        .rd_ptr_synced  (rptr_gray_synced_to_wr),
		.wr_full        (wr_full_int),
        .wr_addr        (wr_addr),
        .wr_ptr_gray    (wr_ptr_gray),
		.fifo_margin    (fifo_margin)
    );

    //----------------------------------------------------------------//
    // 3. Read Pointer Handler
    //----------------------------------------------------------------//
    async_fifo_rdptr #(
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) u_rdptr (
        .clk_rd         (clk_rd),
        .rstn_rd        (rstn_rd),
        .rd_en          (rd_en),
        .wr_ptr_synced  (wptr_gray_synced_to_rd),
		.rd_empty       (rd_empty_int),
        .rd_addr        (rd_addr),
        .rd_ptr_gray    (rd_ptr_gray)
	);

    async_fifo_sync_unit #(
        .DATA_WIDTH (PTR_WIDTH + 1)
    ) u_sync_w2r (
        .target_clk     (clk_rd),
        .target_rstn    (rstn_rd),
        .din            (wr_ptr_gray),
        .synced_dout    (wptr_gray_synced_to_rd)
	);

    async_fifo_sync_unit #(
        .DATA_WIDTH (PTR_WIDTH + 1)
    ) u_sync_r2w (
        .target_clk     (clk_wr),
        .target_rstn    (rstn_wr),
        .din            (rd_ptr_gray),
		.synced_dout    (rptr_gray_synced_to_wr)
    );

endmodule