`include "axi_lite_pkg.sv"
import axi_lite_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi_lite_if.sv"

module axi_lite_top();

    logic clk;
    logic rst_n;

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

    axi_lite_if intf(clk, rst_n);

    axi_lite_slave DUT(
        .bus(intf)
    );

    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "*", "vif", intf);
        run_test();
    end

endmodule
