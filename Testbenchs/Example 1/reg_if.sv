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

endinterface
