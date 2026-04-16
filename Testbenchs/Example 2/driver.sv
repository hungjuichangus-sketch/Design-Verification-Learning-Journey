class driver;

    virtual reg_if vif;

    mailbox #(reg_item) drv_mbx;

    function new(virtual reg_if vif_arg, mailbox #(reg_item) mbx_arg);
        vif = vif_arg;
        drv_mbx = mbx_arg;
    endfunction

    task reset_pins();
        vif.drv_cb.sel <= 0;
        vif.drv_cb.wr <= 0;
        vif.drv_cb.addr <= 0;
        vif.drv_cb.wdata <= 0;
    endtask

    task run();
        reset_pins();
        forever begin
            reg_item req;
            drv_mbx.get(req);
            $display("[%0t] [Driver] Received item from mailbox. Driving pins...", $time);

            @(vif.drv_cb); 
            vif.drv_cb.sel <= 1;
            vif.drv_cb.wr <= req.wr;
            vif.drv_cb.addr <= req.addr;
            
            if(req.wr) begin
                vif.drv_cb.wdata <= req.wdata;
            end

            @(vif.drv_cb);

            if (req.wr == 0) begin
                while (vif.ready == 0) begin
                    @(vif.drv_cb);
                end
            end

            vif.drv_cb.sel <= 0;
            vif.drv_cb.wr <= 0;
        end
    endtask

endclass
