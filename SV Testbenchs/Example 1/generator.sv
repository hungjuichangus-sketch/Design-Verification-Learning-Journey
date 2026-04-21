class generator;

    int num_tx = 10;

    mailbox #(add_item) drv_mbx;

    function new(mailbox #(add_item) mbx_arg);
        drv_mbx = mbx_arg;
    endfunction

    task run();
        for(int i = 0; i < num_tx; i++)begin
            add_item req = new();
            if(!req.randomize()) $display("[Generator] Randomization failed");
            else begin
                drv_mbx.put(req);
                $display("[Generator] Generate signals");
            end
        end
    endtask
endclass
