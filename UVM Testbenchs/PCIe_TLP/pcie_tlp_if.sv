interface pcie_tlp_if(input logic clk, rst_n);
    logic [31:0] rx_data;
    logic rx_valid;
    logic rx_sop;
    logic rx_eop;

    logic [31:0] tx_data;
    logic tx_valid;
    logic tx_sop;
    logic tx_eop;

    clocking drv_cb @(posedge clk);
        input tx_data, tx_valid, tx_sop, tx_eop;
        output rx_data, rx_valid, rx_sop, rx_eop;
    endclocking

    clocking mon_cb @(posedge clk);
        input tx_data, tx_valid, tx_sop, tx_eop;
        input rx_data, rx_valid, rx_sop, rx_eop;
    endclocking

endinterface
