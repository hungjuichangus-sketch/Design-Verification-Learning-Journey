module syn_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic write_en,
    input  logic read_en,
    input  logic [DATA_WIDTH-1:0] data_in,

    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

    // Use the system function $clog2 to automatically calculate required address bits (16 depth -> 4 bits)
    localparam ADDR_WIDTH = $clog2(DATA_DEPTH);

    // Memory array (SystemVerilog C-style declaration)
    logic [DATA_WIDTH-1:0] mem [DATA_DEPTH];
    
    // Pointers: Width is ADDR_WIDTH + 1 (includes an extra MSB for the wrap-around bit)
    // If ADDR_WIDTH is 4, the pointer width is [4:0] (5 bits total)
    logic [ADDR_WIDTH:0] w_ptr;
    logic [ADDR_WIDTH:0] r_ptr;

    //======================================
    // Pointer Control and Memory Read/Write Logic
    //======================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Only reset the pointers and output data. Never reset the memory array itself.
            w_ptr    <= 0;
            r_ptr    <= 0;
            data_out <= 0;
        end else begin
            // Write Logic (Push)
            if (write_en && !full) begin
                mem[w_ptr[ADDR_WIDTH-1:0]] <= data_in;
                w_ptr <= w_ptr + 1'b1;
            end
            
            // Read Logic (Pop)
            if (read_en && !empty) begin
                data_out <= mem[r_ptr[ADDR_WIDTH-1:0]];
                r_ptr <= r_ptr + 1'b1;
            end
        end
    end

    //======================================
    // Status Flag Logic (Combinational)
    //======================================
    // Empty: Read and Write pointers are exactly identical (including the MSB)
    assign empty = (w_ptr == r_ptr);

    // Full: Physical addresses match, but the wrap-around bits (MSB) are different
    assign full  = (w_ptr[ADDR_WIDTH] != r_ptr[ADDR_WIDTH]) && 
                   (w_ptr[ADDR_WIDTH-1:0] == r_ptr[ADDR_WIDTH-1:0]);

endmodule
