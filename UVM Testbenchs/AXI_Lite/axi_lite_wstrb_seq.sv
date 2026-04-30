class axi_lite_wstrb_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_wstrb_seq)

    function new(string name = "axi_lite_wstrb_seq");
        super.new(name);
    endfunction

    task body();
        logic [31:0] target_addr;
        repeat(num_pkts)begin
            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {
                req.op == axi_lite_seq_item::WRITE;
                req.wstrb inside{[4'b0000:4'b1111]};
            })
                `uvm_fatal("SEQ", "WRITE & Wstrb Randomization failed")
            target_addr = req.addr;
            finish_item(req);

            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {
                req.op == axi_lite_seq_item::READ;
                req.addr == target_addr;
            })
                `uvm_fatal("SEQ", "READ & Address Randomization failed")
            finish_item(req);
        end
    endtask
endclass
