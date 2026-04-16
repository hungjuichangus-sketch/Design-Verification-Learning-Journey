class env;
    virtual add_if vif;
    driver drv;
    scoreboard scb;
    monitor mon;
    generator gen;
    coverage cov;

    mailbox #(add_item) drv_mbx;
    mailbox #(add_item) scb_mbx;
    mailbox #(add_item) cov_mbx;

    function new(virtual add_if vif_arg);
        vif = vif_arg;
        drv_mbx = new();
        scb_mbx = new();
        cov_mbx = new();
        drv = new(vif, drv_mbx);
        scb = new(scb_mbx);
        gen = new(drv_mbx);
        mon = new(vif, scb_mbx, cov_mbx);
        cov = new(cov_mbx);
    endfunction

    task run();
        drv.reset();
        scb.num_tx = gen.num_tx;
        fork : background_threads
            drv.run();
            scb.run();
            mon.run();
            cov.run();
            gen.run();
        join_none

        wait(scb.test_done.triggered);

        disable background_threads;
    endtask
endclass
