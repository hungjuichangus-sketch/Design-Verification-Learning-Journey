class axi_lite_sequence extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_sequence)

    function new(string name = "axi_lite_sequence");
        super.new(name);
    endfunction

    task body();
        bit [31:0] target_addr; // Variable to remember where we wrote
        repeat(num_pkts) begin
            // =========================================================
            // 1. The WRITE Transaction
            // =========================================================
            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);

            // Constrain this specific item to be a WRITE
            if(!req.randomize() with { op == axi_lite_seq_item::WRITE; })
                `uvm_fatal("SEQ", "Write Randomization failed")

            target_addr = req.addr; // Save the randomized address

            finish_item(req);

            // =========================================================
            // 2. The READ Transaction (to the same address)
            // =========================================================
            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);

            // Constrain this item to be a READ, and force the address to match
            if(!req.randomize() with {
                op == axi_lite_seq_item::READ;
                addr == target_addr;
            })
                `uvm_fatal("SEQ", "Read Randomization failed")

            finish_item(req);
        end
    endtask
endclass
