class axi_lite_unaligned_addr_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_unaligned_addr_seq)

    function new(string name = "axi_lite_unaligned_addr_seq");
        super.new(name);
    endfunction

    task body();
        repeat(num_pkts)begin
            req = axi_lite_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {req.addr[1:0] != 2'b00; })
                `uvm_fatal("SEQ","Unaligned Address Randomization failed")
            finish_item(req);
        end
    endtask
endclass
