class pcie_tlp_sanity_seq extends pcie_tlp_base_seq;
    `uvm_object_utils(pcie_tlp_sanity_seq)

    logic [31:0] target_addr;
    logic [9:0] target_length;
    logic [3:0]  target_first_be;
    logic [3:0]  target_last_be;

    function new(string name = "pcie_tlp_sanity_seq");
        super.new(name);
    endfunction

    task body();
        repeat(num_pkts) begin
            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {fmt == 3'b010;})
                `uvm_fatal("SEQ", "Sanity Write Randomization failed")
            target_addr     = req.addr;
            target_length   = req.length;
            target_first_be = req.first_dw_be;
            target_last_be  = req.last_dw_be;

            finish_item(req);

            req = pcie_tlp_seq_item::type_id::create("req");
            start_item(req);
            if(!req.randomize() with {
                fmt == 3'b000;
                addr == target_addr;
                length == target_length;
                first_dw_be == target_first_be;
                last_dw_be == target_last_be;
            })
                `uvm_fatal("SEQ", "Sanity Read Randomization failed")
            finish_item(req);
        end
    endtask
endclass
