module FIFO #(
	parameter DATA_WIDTH = 16, 
	parameter ADDR_WIDTH = 5
)(
	input clk, rst_n,
	
	input [DATA_WIDTH - 1:0] wr_data,
	input wr_en,
	output full,
	
	input rd_en,
	output empty,
	output reg [DATA_WIDTH - 1:0] rd_data
);
	localparam DEPTH = 1 << ADDR_WIDTH;
	
	// Tell Quartus to use M9K for this array
	(* ramstyle = "M9K" *) reg [DATA_WIDTH - 1:0] mem[0: DEPTH - 1];
	
	// N-1 method
//	reg [ADDR_WIDTH - 1:0] wr_ptr, rd_ptr;
	
//	assign full = (wr_ptr + 1 == rd_ptr);
//	assign empty = (wr_ptr == rd_ptr);

	// Idustry standard, need one more bit for pointer
	// The MSB is the lap counter
	reg [ADDR_WIDTH:0] wr_ptr, rd_ptr;
	assign empty = (wr_ptr == rd_ptr);
	assign full = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) &&
				  (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
				  
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			wr_ptr <= 0;
			rd_ptr <= 0;
		end else begin
			if(wr_en && ~full) wr_ptr <= wr_ptr + 1'b1;
			if(rd_en && ~empty) rd_ptr <= rd_ptr + 1'b1;
		end
	end
	
	// Because M9K doesn't have asynchronous reset pin
	always @(posedge clk)begin
		if(wr_en && ~full) mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
		if(rd_en && ~empty) rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
	end
endmodule