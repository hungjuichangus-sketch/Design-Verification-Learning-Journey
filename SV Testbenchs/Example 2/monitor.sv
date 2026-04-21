class monitor;

    virtual reg_if vif;

    mailbox #(reg_item) scb_mbx;
    mailbox #(reg_item) cov_mbx;

    function new(virtual reg_if vif_arg, mailbox #(reg_item) drv_mbx_arg,
                mailbox #(reg_item) cov_mbx_arg);
        vif = vif_arg;
        scb_mbx = drv_mbx_arg;
        cov_mbx = cov_mbx_arg;
    endfunction

    task run();
        forever begin
            reg_item tx;

            @(vif.mon_cb);

            if(vif.mon_cb.sel == 1 && vif.mon_cb.ready == 1) begin
                tx = new();
                tx.wr = vif.mon_cb.wr;
                tx.addr = vif.mon_cb.addr;

                if (vif.mon_cb.wr == 1) begin
                    tx.wdata = vif.mon_cb.wdata;

                    $display("[%0t] [Monitor] Captured WRITE...", $time);
                    scb_mbx.put(tx);
                    cov_mbx.put(tx);
                end else begin
                    do begin
                        @(vif.mon_cb);
                    end while (vif.mon_cb.ready == 0);

                    tx.rdata = vif.mon_cb.rdata;
                    $display("[%0t] [Monitor] Captured READ...", $time);
                    scb_mbx.put(tx);
                    cov_mbx.put(tx);
                end
            end
        end
    endtask

endclass
