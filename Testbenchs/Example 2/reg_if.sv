interface reg_if #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 16
)(input bit clk);
    logic rstn;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic wr;
    logic sel;
    logic ready;

    clocking drv_cb @(posedge clk);
        output addr, wdata, wr, sel;
        input rdata, ready;
    endclocking

    clocking mon_cb @(posedge clk);
        input addr, wdata, rdata, wr, sel, ready;
    endclocking

endinterface
