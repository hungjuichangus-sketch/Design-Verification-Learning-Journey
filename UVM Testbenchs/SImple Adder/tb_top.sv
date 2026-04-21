import uvm_pkg::*;
`include "uvm_macros.svh"

`include "add_if.sv"
`include "add_item.sv"

`include "add_sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"

`include "env.sv"
`include "test.sv"

module tb_top;

    logic clk;
    logic sim_done = 0;

    add_if intf(clk);
    initial begin
        clk = 0;
        while(sim_done == 0)begin
            #5 clk = ~clk;
        end
    end

    my_adder dut(
        .rstn(intf.rstn),
        .a(intf.a),
        .b(intf.b),
        .carry(intf.carry),
        .sum(intf.sum)
    );

    initial begin
        uvm_config_db#(virtual add_if)::set(null, "*", "vif", intf);

        run_test();

        sim_done = 1;
    end
endmodule
