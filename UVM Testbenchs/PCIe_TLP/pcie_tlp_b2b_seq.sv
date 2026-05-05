class pcie_tlp_b2b_seq extends pcie_tlp_base_seq;
    `uvm_object_utils(pcie_tlp_b2b_seq)

    pcie_tlp_seq_item wrote_data[$];
    int ooo_index;
    function new(string name = "pcie_tlp_b2b_seq");
        super.new(name);
    endfunction

    task body();
        pcie_tlp_seq_item req;
        repeat(num_pkts)begin
            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {fmt == 3'b010;})
                `uvm_fatal("SEQ", "Write Randomization failed")
            wrote_data.push_back(req);
            finish_item(req);
        end
        for(int i = 0; i < num_pkts; i++)begin // Using tag == i to aviod repeated tag.
            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            ooo_index = $urandom_range(0, wrote_data.size() - 1);
            if(!req.randomize() with{
                fmt == 3'b000;
                addr == wrote_data[ooo_index].addr;
                length == wrote_data[ooo_index].length;
                tag == i;}) `uvm_fatal("SEQ", "Read Randomization failed")
            wrote_data.delete(ooo_index);
            finish_item(req);
        end
    endtask
endclass
