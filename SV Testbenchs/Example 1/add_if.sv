interface add_if(
    input clk
);

    logic rstn;
    logic a;
    logic b;
    logic carry;
    logic sum;

    clocking drv_cb @(posedge clk);
        input carry, sum;
        output rstn, a, b;
    endclocking

    clocking mon_cb @(posedge clk);
        input rstn, a, b, carry, sum;
    endclocking
endinterface
