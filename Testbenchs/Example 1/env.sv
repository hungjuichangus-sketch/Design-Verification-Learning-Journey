class env;

    virtual reg_if vif;
    driver drv;
    generator gen;
    mailbox #(reg_item) drv_mbx;

    monitor mon;
    scoreboard scb;
    mailbox #(reg_item) scb_mbx;

    coverage cov;
    mailbox #(reg_item) cov_mbx;

    function new(virtual reg_if vif_arg);
        vif = vif_arg;
        drv_mbx = new();
        scb_mbx = new();
        cov_mbx = new();

        gen = new(drv_mbx);
        drv = new(vif, drv_mbx);

        scb = new(scb_mbx);
        mon = new(vif, scb_mbx, cov_mbx);

        cov = new(cov_mbx);
    endfunction

    task run();
        reg_item req;

        fork
            drv.run();
            mon.run();
            scb.run();
            cov.run();
        join_none

        gen.run();

        while(drv_mbx.num() > 0) begin
            #10;
        end

        #100;
    endtask

endclass
