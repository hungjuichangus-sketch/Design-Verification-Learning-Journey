class coverage;

    mailbox #(reg_item) cov_mbx;

    reg_item tx;

    // Tell the covergroup to expect an argument.
    covergroup cg with function sample(reg_item tx_arg);
        option.per_instance = 1; // For EDA Playground coverage report

        cp_wr: coverpoint tx.wr{
            bins write = {1};
            bins read = {0};
        }
        cp_addr: coverpoint tx.addr{
            bins low = {[8'h00:8'h0F]};
            bins mid = {[8'h10:8'h1F]};
            bins high = {[8'h20:8'h32]};
        }
        cross_wr_addr: cross cp_wr, cp_addr;
    endgroup

    function new(mailbox #(reg_item) mbx_arg);
        cov_mbx = mbx_arg;

        cg = new();
    endfunction

    task run();
        forever begin
            cov_mbx.get(tx);
            cg.sample(tx);

            $display("[%0t] [Coverage] Sampled transaction!", $time);
        end
    endtask

endclass