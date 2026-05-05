class pcie_tlp_base_seq extends uvm_sequence #(pcie_tlp_seq_item);
    `uvm_object_utils(pcie_tlp_base_seq)

    int num_pkts = 50;

    function new(string name = "pcie_tlp_base_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        if ($value$plusargs("num_pkts=%d", num_pkts)) begin
            `uvm_info("BASE_SEQ", $sformatf("Command line override: %0d packets.", num_pkts), UVM_LOW)
        end
    endtask

    virtual task body();
    endtask
endclass
