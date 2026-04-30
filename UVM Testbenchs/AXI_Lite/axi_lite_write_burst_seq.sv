class axi_lite_write_burst_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_write_burst_seq)

    function new(string name = "axi_lite_write_burst_seq");
        super.new(name);
    endfunction

    task body();
        repeat(num_pkts) begin
            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {req.op == axi_lite_seq_item::WRITE;})
                `uvm_fatal("SEQ", "Write Randomization failed")
            finish_item(req);
        end
    endtask
endclass
