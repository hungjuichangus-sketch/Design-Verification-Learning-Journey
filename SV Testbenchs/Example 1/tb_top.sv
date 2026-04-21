`include "add_if.sv"
`include "add_item.sv"

`include "driver.sv"
`include "monitor.sv"
`include "generator.sv"
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
        .rstn(rstn),
        .a(intf.a),
        .b(intf.b),
        .carry(intf.carry),
        .sum(intf.sum)
    );

    base_test test;
    initial begin

        test = new(intf);
        test.run();

        $display("=======================================");
        $display("   TEST FINISHED GRACEFULLY");
        $display("=======================================");

        sim_done = 1;
    end
endmodule
