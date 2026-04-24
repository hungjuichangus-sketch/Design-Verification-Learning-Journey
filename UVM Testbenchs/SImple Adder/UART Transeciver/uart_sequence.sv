class uart_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_sequence)

    // Declare the knob
    rand int unsigned num_pkts;

    // Set a safe default using a soft constraint
    constraint pkts_c { soft num_pkts == 50; }

    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    task body();
        repeat(num_pkts) begin
            req = uart_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize())
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(req);
        end
    endtask

endclass
