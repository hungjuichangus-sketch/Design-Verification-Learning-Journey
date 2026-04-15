class driver;
    virtual reg_if vif;

    mailbox #(reg_item) drv_mbx;

    function new(virtual reg_if vif_arg, mailbox #(reg_item) mbx_arg);
        vif = vif_arg;
        drv_mbx = mbx_arg;
    endfunction

    task reset_pins();
        vif.sel <= 0;
        vif.wr <= 0;
        vif.addr <= 0;
        vif.wdata <= 0;
    endtask
    
    task run();
        reset_pins();
        forever begin

            reg_item req;
            drv_mbx.get(req);

            $display("[%0t] [Driver] Received item from mailbox. Driving pins...", $time);

            @(posedge vif.clk);
            vif.sel <= 1;
            vif.wr <= req.wr;
            vif.addr <= req.addr;

            if(req.wr)begin
                vif.wdata <= req.wdata;
            end

            do begin
                @(posedge vif.clk);
                #1;
            end while(vif.ready == 0);

            vif.sel <= 0;
            vif.wr <= 0;
        end
    endtask

endclass
