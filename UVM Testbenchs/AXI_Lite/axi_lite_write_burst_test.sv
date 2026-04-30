class axi_lite_write_burst_test extends axi_lite_base_test;
    `uvm_component_utils(axi_lite_write_burst_test)

    function new(string name = "axi_lite_write_burst_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_lite_base_seq::type_id::set_type_override(axi_lite_write_burst_seq::get_type());
    endfunction
endclass
