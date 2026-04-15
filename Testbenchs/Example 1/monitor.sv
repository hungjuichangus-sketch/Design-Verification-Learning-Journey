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

            @(posedge vif.clk);
            if(vif.sel == 1 && vif.ready == 1)begin
                tx = new();

                tx.wr = vif.wr;
                tx.addr = vif.addr;

                if (vif.sel == 1 && vif.ready == 1) begin
                    tx = new();
                    tx.wr   = vif.wr;
                    tx.addr = vif.addr;

                    if (vif.wr == 1) begin
                        tx.wdata = vif.wdata;

                        $display("[%0t] [Monitor] Captured WRITE...", $time);
                        scb_mbx.put(tx);
                        cov_mbx.put(tx);
                    end else begin
                        do begin
                            @(posedge vif.clk);
                            #1;
                        end while (vif.ready == 0);

                        tx.rdata = vif.rdata;

                        $display("[%0t] [Monitor] Captured READ...", $time);
                        scb_mbx.put(tx);
                        cov_mbx.put(tx);
                    end
                end
            end
        end
    endtask

endclass
