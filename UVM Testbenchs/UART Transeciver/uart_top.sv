import uvm_pkg::*;
`include "uvm_macros.svh"

module uart_top;

    logic clk;
    logic rst_n;

    uart_if intf(clk, rst_n);

    // Internal Wires (The Bridge between FIFO and DUT)
    logic [7:0] tx_fifo_to_dut_data;
    logic       tx_fifo_empty;
    logic       tx_dut_read_en;

    // Rx Path Wires
    logic [7:0] rx_dut_to_fifo_data;
    logic       rx_dut_write_en;
    logic       rx_fifo_full;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // TX HARDWARE PATH
    logic tx_dut_read_en_prev;
    logic tx_dut_read_pulse;

    always_ff @(posedge clk) begin
        if (!rst_n) tx_dut_read_en_prev <= 0;
        else        tx_dut_read_en_prev <= tx_dut_read_en;
    end
    // This creates a 1-clock pulse even if the DUT holds it high!
    assign tx_dut_read_pulse = tx_dut_read_en && !tx_dut_read_en_prev;

    // TX FIFO: UVM writes in, Tx DUT reads out
    fifo #(.DATA_WIDTH(8), .FIFO_DEPTH(16)) tx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .write_en(intf.tx_write_en),  // Driven by UVM Tx Driver
        .data_in(intf.tx_data_in),    // Driven by UVM Tx Driver
        .full(intf.tx_full),          // Read by UVM Tx Driver

        .read_en(tx_dut_read_pulse),     // Driven by Tx DUT
        .data_out(tx_fifo_to_dut_data), // Read by Tx DUT
        .empty(tx_fifo_empty)         // Read by Tx DUT
    );

    // TX DUT: Pulls from Tx FIFO, outputs to serial line
    tx tx_dut (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_empty(tx_fifo_empty),
        .fifo_data(tx_fifo_to_dut_data),
        .fifo_read_en(tx_dut_read_en),
        .tx_out(intf.tx_out),
        .tx_busy()
    );

    // RX HARDWARE PATH
    // RX DUT: Reads serial line, pushes to Rx FIFO
    rx rx_dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_in(intf.rx_in),
        .fifo_full(rx_fifo_full),
        .fifo_write_en(rx_dut_write_en),
        .fifo_data_out(rx_dut_to_fifo_data),
        .parity_error(intf.parity_error),
        .framing_error(intf.framing_error)
    );

    // RX FIFO: Rx DUT writes in, UVM reads out
    fifo #(.DATA_WIDTH(8), .FIFO_DEPTH(16)) rx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .write_en(rx_dut_write_en),   // Driven by Rx DUT
        .data_in(rx_dut_to_fifo_data),// Driven by Rx DUT
        .full(rx_fifo_full),          // Read by Rx DUT

        .read_en(intf.rx_read_en),    // Driven by UVM (Scoreboard/CPU)
        .data_out(intf.rx_data_out),  // Read by UVM Rx Monitor
        .empty(intf.rx_empty)         // Read by UVM (Scoreboard/CPU)
    );

    // UVM BOOT SEQUENCE
    initial begin
        uvm_config_db#(virtual uart_if)::set(null, "*", "vif", intf);
        run_test("uart_base_test");
    end

endmodule
