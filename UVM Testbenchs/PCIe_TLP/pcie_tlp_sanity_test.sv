class pcie_tlp_sanity_test extends pcie_tlp_base_test;
    `uvm_component_utils(pcie_tlp_sanity_test)

    function new(string name = "pcie_tlp_sanity_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        pcie_tlp_base_seq::type_id::set_type_override(pcie_tlp_sanity_seq::get_type());
    endfunction
endclass
