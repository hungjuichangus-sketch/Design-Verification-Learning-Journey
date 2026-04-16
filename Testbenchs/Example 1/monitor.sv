class monitor;

    virtual add_if vif;
    mailbox #(add_item) scb_mbx;
    mailbox #(add_item) cov_mbx;

    function new(virtual add_if vif_arg, mailbox #(add_item) scb_mbx_arg, mailbox #(add_item) cov_mbx_arg);
        vif = vif_arg;
        scb_mbx = scb_mbx_arg;
        cov_mbx = cov_mbx_arg;
    endfunction

    task run();
        forever begin
            add_item act_tx;
            @(vif.mon_cb);
            act_tx = new();
            act_tx.rstn = vif.mon_cb.rstn;
            act_tx.a = vif.mon_cb.a;
            act_tx.b = vif.mon_cb.b;
            act_tx.carry = vif.mon_cb.carry;
            act_tx.sum = vif.mon_cb.sum;
            scb_mbx.put(act_tx);
            cov_mbx.put(act_tx);
            $display("[%0t] [Monitor] Monitor put data",$time);
        end
    endtask
endclass
