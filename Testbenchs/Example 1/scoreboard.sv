// scoreboard.sv
class scoreboard;

    mailbox #(reg_item) scb_mbx;

    // 1. Create a reference memory to mimic the DUT
    // We use the exact same depth (256) and data width (16) as the hardware.
    logic [15:0] ref_mem [256];

    function new(mailbox #(reg_item) mbx_arg);
        scb_mbx = mbx_arg;

        // 2. Initialize the reference memory to match the DUT's reset state
        // Your DUT resets all memory addresses to 16'h1234
        foreach(ref_mem[i]) begin
            ref_mem[i] = 16'h1234;
        end
    endfunction

    task run();
        forever begin
            reg_item act_tx;
            scb_mbx.get(act_tx);

            // 3. The Checking Logic
            if (act_tx.wr == 1) begin
                // It is a WRITE operation.
                // Update our reference memory with the new data so we remember it for later.
                ref_mem[act_tx.addr] = act_tx.wdata;

                $display("[%0t] [Scoreboard] Saved WRITE at addr 0x%0h: data 0x%0h",
                         $time, act_tx.addr, act_tx.wdata);
            end 
            else begin
                // It is a READ operation.
                // Compare the DUT's read data against what we have stored in our reference memory.
                if (act_tx.rdata == ref_mem[act_tx.addr]) begin
                    $display("[%0t] [Scoreboard] PASS! Read addr 0x%0h: expected 0x%0h, got 0x%0h",
                             $time, act_tx.addr, ref_mem[act_tx.addr], act_tx.rdata);
                end
                else begin
                    // If it doesn't match, we throw a SystemVerilog error!
                    $error("[%0t] [Scoreboard] FAIL! Read addr 0x%0h: expected 0x%0h, got 0x%0h",
                           $time, act_tx.addr, ref_mem[act_tx.addr], act_tx.rdata);
                end
            end
        end
    endtask

endclass