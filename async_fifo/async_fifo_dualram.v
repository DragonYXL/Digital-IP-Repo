module async_fifo_dualram #(
	parameter integer DATA_WIDTH = 32,
	parameter integer FIFO_DEPTH = 128
)(
	input							clk_a,
	input							we_a,
	input [$clog2(FIFO_DEPTH)-1:0]	addr_a,
	input [DATA_WIDTH-1:0]			din_a,

	output reg [DATA_WIDTH-1:0]		dout_a,
	input 							clk_b,
	input 							we_b,
	input [$clog2(FIFO_DEPTH)-1:0] 	addr_b,
	input [DATA_WIDTH-1:0]			din_b,
	output reg [DATA_WIDTH-1:0]		dout_b
);
	reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

	always@(posedge clk_a)begin
		if(we_a)
			mem[addr_a]<=din_a;
		else
			dout_a <= mem[addr_a];
	end

	always@(posedge clk_b )begin
		if(we_b)
			mem[addr_b]<=din_b;
		else
			dout_b <= mem[addr_b];
	end

endmodule