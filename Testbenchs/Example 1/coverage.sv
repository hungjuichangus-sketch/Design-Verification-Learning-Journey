class coverage;

    mailbox #(add_item) cov_mbx;
    add_item tx;

    covergroup cg with function sample(bit a, bit b);
        option.per_instance = 1;
        c_a: coverpoint a {
            bins one = {1};
            bins zero = {0};
        }
        c_b: coverpoint b {
            bins one = {1};
            bins zero = {0};
        }
        x_a_b: cross c_a, c_b;
    endgroup

    function new(mailbox #(add_item) mbx_arg);
        cov_mbx = mbx_arg;
        cg = new();
    endfunction

    task run();
        forever begin
            cov_mbx.get(tx);
            cg.sample(tx.a, tx.b);
            $display("[Coverage] Sampled transaction a=%0b, b=%0b", tx.a, tx.b);
        end
    endtask
endclass
