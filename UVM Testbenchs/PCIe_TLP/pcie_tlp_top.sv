`include "pcie_tlp_pkg.sv"
import pcie_tlp_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

module pcie_tlp_top();

    logic clk, rst_n;
    pcie_tlp_if intf(clk, rst_n);

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    mock_pcie_ep DUT(.bus(intf));

    initial begin
        uvm_config_db #(virtual pcie_tlp_if)::set(null, "*", "vif", intf);
        run_test();
    end

endmodule
