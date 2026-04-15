`include "reg_if.sv"
`include "reg_item.sv"


`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "generator.sv"
`include "coverage.sv"

`include "env.sv"
`include "test.sv"

module tb_top;

    logic clk;
    logic rst_n;

    logic sim_done;

    initial begin
        clk = 0;
        sim_done = 0;

        // The clock ONLY toggles while the simulation is NOT done
        while (sim_done == 0) begin
            #5 clk = ~clk;
        end
    end

    reg_if intf(clk);

    reg_ctrl dut (
        .clk(clk),
        .rstn(rst_n),
        .addr(intf.addr),
        .sel(intf.sel),
        .wr(intf.wr),
        .wdata(intf.wdata),
        .rdata(intf.rdata),
        .ready(intf.ready)
    );

    // base_test test;
    //test_write_only test;
    test_heavy_random test;


    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;

        test = new(intf);
        test.run();

        $display("=======================================");
        $display("   TEST FINISHED GRACEFULLY");
        $display("=======================================");

        sim_done = 1;
    end

endmodule
