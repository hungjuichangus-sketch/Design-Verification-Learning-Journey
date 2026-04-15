// scoreboard.sv
class scoreboard;

    mailbox #(reg_item) scb_mbx;

    // Create a reference memory to mimic the DUT
    logic [15:0] ref_mem [256];

    function new(mailbox #(reg_item) mbx_arg);
        scb_mbx = mbx_arg;
        foreach(ref_mem[i]) begin
            ref_mem[i] = 16'h1234;
        end
    endfunction

    task run();
        forever begin
            reg_item act_tx;
            scb_mbx.get(act_tx);


            if (act_tx.wr == 1) begin
                ref_mem[act_tx.addr] = act_tx.wdata;

                $display("[%0t] [Scoreboard] Saved WRITE at addr 0x%0h: data 0x%0h",
                         $time, act_tx.addr, act_tx.wdata);
            end 
            else begin
                if (act_tx.rdata == ref_mem[act_tx.addr]) begin
                    $display("[%0t] [Scoreboard] PASS! Read addr 0x%0h: expected 0x%0h, got 0x%0h",
                             $time, act_tx.addr, ref_mem[act_tx.addr], act_tx.rdata);
                end
                else begin
                    $error("[%0t] [Scoreboard] FAIL! Read addr 0x%0h: expected 0x%0h, got 0x%0h",
                           $time, act_tx.addr, ref_mem[act_tx.addr], act_tx.rdata);
                end
            end
        end
    endtask

endclass
