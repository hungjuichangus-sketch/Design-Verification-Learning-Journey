class monitor;

    // 1. Declare the virtual interface.
    // The monitor needs to look at the pins, just like the driver.
    virtual reg_if vif;

    // 2. Declare a parameterized mailbox.
    // This mailbox will be used to send the observed data to the Scoreboard later.
    mailbox #(reg_item) scb_mbx;
    mailbox #(reg_item) cov_mbx;

    // 3. The constructor.
    // Pass the virtual interface and the mailbox in as arguments, just like you did for the driver.
    function new(virtual reg_if vif_arg, mailbox #(reg_item) drv_mbx_arg,
                mailbox #(reg_item) cov_mbx_arg);
        vif = vif_arg;
        scb_mbx = drv_mbx_arg;
        cov_mbx = cov_mbx_arg;
    endfunction

    // 4. The main run task.
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
                        // Writes complete instantly. Capture data now!
                        tx.wdata = vif.wdata;

                        $display("[%0t] [Monitor] Captured WRITE...", $time);
                        scb_mbx.put(tx);
                        cov_mbx.put(tx);
                    end else begin
                        // Reads take extra cycles!
                        // We must wait for the DUT to finish working and assert ready AGAIN.
                        do begin
                            @(posedge vif.clk);
                            #1;
                        end while (vif.ready == 0);

                        // NOW the data on the wire is valid!
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
