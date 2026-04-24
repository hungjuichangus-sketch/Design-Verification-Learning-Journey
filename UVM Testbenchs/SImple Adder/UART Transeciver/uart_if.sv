interface uart_if #(parameter DATA_WIDTH = 8)
(
    input logic clk,
    input logic rst_n
);
    logic tx_write_en;
    logic [DATA_WIDTH-1:0] tx_data_in;
    logic tx_full;

    logic rx_read_en;
    logic [DATA_WIDTH-1:0] rx_data_out;
    logic rx_empty;

    logic tx_out;
    logic rx_in;

    logic framing_error;
    logic parity_error;

    clocking cb@(posedge clk);
        output tx_write_en, rx_read_en, tx_data_in, rx_in;
        input tx_full, rx_empty, tx_out, framing_error, parity_error,  rx_data_out;
    endclocking
endinterface
