class driver;

    virtual add_if vif;
    mailbox #(add_item) drv_mbx;

    function new(virtual add_if vif_arg, mailbox #(add_item) mbx_arg);
        vif = vif_arg;
        drv_mbx = mbx_arg;
    endfunction

    task reset();
        vif.drv_cb.rstn <= 0;
        repeat(2) @(vif.drv_cb);
        vif.drv_cb.rstn <= 1;
    endtask

    task run();
        forever begin
            add_item req = new();
            drv_mbx.get(req);

            @(vif.drv_cb);
            vif.drv_cb.a <= req.a;
            vif.drv_cb.b <= req.b;
            $display("[%0t] [Driver] Driver drive the signal", $time);
        end
    endtask
endclass
