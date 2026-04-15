module reg_ctrl #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 256,
    parameter RESET_VAL = 16'h1234
)(
    input logic clk,
    input logic rstn,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic sel,
    input logic wr,
    input logic [DATA_WIDTH-1:0] wdata,

    output logic [DATA_WIDTH-1:0] rdata,
    output logic ready
);

    // Some memory element to store data for each addr
    logic [DATA_WIDTH-1:0] ctrl [DEPTH];

    logic  ready_dly;
    logic ready_pe;

    // If reset is asserted, clear the memory element
    // Else store data to addr for valid writes
    // For reads, provide read data back
    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (int i = 0; i < DEPTH; i += 1) begin
                ctrl[i] <= RESET_VAL;
            end
        end else begin
            if (sel & ready & wr) begin
                ctrl[addr] <= wdata;
            end

            if (sel & ready & !wr) begin
                rdata <= ctrl[addr];
            end
        end
    end

    // Ready is driven using this always block
    // During reset, drive ready as 1
    // Else drive ready low for a clock low
    // for a read until the data is given back
    always_ff @ (posedge clk) begin
        if (!rstn) begin
            ready <= 1;
        end else begin
            if (sel & ready_pe) begin
                ready <= 1;
            end
            if (sel & ready & !wr) begin
                ready <= 0;
            end
        end
    end

    // Drive internal signal accordingly
    always_ff @ (posedge clk) begin
        if (!rstn) ready_dly <= 1;
        else ready_dly <= ready;
    end

    assign ready_pe = ~ready & ready_dly;

endmodule
