class scoreboard;

    mailbox #(add_item) scb_mbx;
    event test_done;
    int num_tx;
    int items_checked = 0;


    function new(mailbox #(add_item) mbx_arg);
        scb_mbx = mbx_arg;
    endfunction

    task run();
        forever begin
            add_item act_tx;
            scb_mbx.get(act_tx);

            if(act_tx.a + act_tx.b == {act_tx.carry, act_tx.sum})
                $display("[Scoreboard] PASS! a=%0b b=%0b carry=%0b sum=%0b",
                        act_tx.a, act_tx.b, act_tx.carry, act_tx.sum);
            else
                $display("[Scoreboard] FAIL! a=%0b b=%0b carry=%0b sum=%0b",
                        act_tx.a, act_tx.b, act_tx.carry, act_tx.sum);

            items_checked++;
            if(items_checked == num_tx)begin
                -> test_done;
            end
        end
    endtask
endclass
