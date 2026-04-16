// generator.sv
class generator;

    mailbox #(reg_item) mbx;
    int num_tx = 10;
    
    // A control knob for our tests to twist
    string test_type = "base";

    function new(mailbox #(reg_item) mbx_arg);
        mbx = mbx_arg;
    endfunction

    task run();
        for (int i = 0; i < num_tx; i++) begin
            reg_item req = new();

            // The Test Plan Routing
            if (test_type == "write_only") begin
                if (!req.randomize() with { wr == 1; }) $error("Rand failed");
            end 
            else if (test_type == "read_only") begin
                if (!req.randomize() with { wr == 0; }) $error("Rand failed");
            end 
            else begin
                if (!req.randomize()) $error("Rand failed");
            end

            $display("[%0t] [Generator] Created and sent transaction #%0d", $time, i+1);
            mbx.put(req);
            #5;
        end
    endtask

endclass
