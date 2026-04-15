// generator.sv
class generator;

    mailbox #(reg_item) mbx;
    int num_tx = 10;
    
    // NEW: A control knob for our tests to twist
    string test_type = "base";

    function new(mailbox #(reg_item) mbx_arg);
        mbx = mbx_arg;
    endfunction

    task run();
        for (int i = 0; i < num_tx; i++) begin
            reg_item req = new();

            // NEW: The Test Plan Routing
            if (test_type == "write_only") begin
                // Inline constraint: Forces 'wr' to be 1, ignoring the 50/50 rule in reg_item
                if (!req.randomize() with { wr == 1; }) $error("Rand failed");
            end 
            else if (test_type == "read_only") begin
                // Inline constraint: Forces 'wr' to be 0
                if (!req.randomize() with { wr == 0; }) $error("Rand failed");
            end 
            else begin
                // The default base test uses the normal 50/50 reg_item rules
                if (!req.randomize()) $error("Rand failed");
            end

            $display("[%0t] [Generator] Created and sent transaction #%0d", $time, i+1);
            mbx.put(req);
            #5;
        end
    endtask

endclass