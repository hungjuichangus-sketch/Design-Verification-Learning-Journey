`include "reg_if.sv"
`include "reg_item.sv"


`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "generator.sv"
`include "coverage.sv"

`include "env.sv"
`include "test.sv"

// tb_top.sv
module tb_top;

    logic clk;
    logic rst_n;

    // 1. Declare the Kill Switch
    logic sim_done;

    // 2. The Clock Generation Block
    initial begin
        clk = 0;
        sim_done = 0; // Initialize the switch

        // The clock ONLY toggles while the simulation is NOT done
        while (sim_done == 0) begin
            #5 clk = ~clk;
        end
    end

    // Instantiate the physical interface
    reg_if intf(clk);

    // Instantiate the Target (DUT)
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

    // Instantiate the Test
    // base_test test;
    //test_write_only test;
    test_heavy_random test;

    // 2. Main Test & Reset Block
    initial begin
        // Hold reset low for 20ns.
        // This guarantees it overlaps with multiple positive clock edges!
        rst_n = 0;
        #20;
        rst_n = 1;

        // Start the test
        test = new(intf);
        test.run();

        // Kill the infinite clock thread so the simulation doesn't hang
        $display("=======================================");
        $display("   TEST FINISHED GRACEFULLY");
        $display("=======================================");

        sim_done = 1;
    end

endmodule
