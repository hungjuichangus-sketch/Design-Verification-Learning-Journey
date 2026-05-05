class pcie_tlp_ooo_avalanche_seq extends pcie_tlp_base_seq;
    `uvm_object_utils(pcie_tlp_ooo_avalanche_seq)

    pcie_tlp_seq_item wrote_data[$];
    logic ooo_index;
    function new(string name = "pcie_tlp_ooo_avalanche_seq");
        super.new(name);
    endfunction

    task body();
        pcie_tlp_seq_item req;
        repeat(256)begin
            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {fmt == 3'b010;})
                `uvm_fatal("SEQ", "Write Randomization failed")
            wrote_data.push_back(req);
            finish_item(req);
        end

        for(int i = 0; i < 256; i++)begin
            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            ooo_index = $urandom_range(0, wrote_data.size() - 1);
            if(!req.randomize() with{
                fmt == 3'b000;
                length == wrote_data[ooo_index].length;
                addr == wrote_data[ooo_index].addr;
                tag == i;
            }) `uvm_fatal("SEQ", "Read Randomization failed")
            wrote_data.delete(ooo_index);

            finish_item(req);
        end
    endtask
endclass
