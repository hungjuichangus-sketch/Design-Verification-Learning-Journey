class axi_lite_coverage extends uvm_subscriber #(axi_lite_seq_item);
    `uvm_component_utils(axi_lite_coverage)

    // Pro-Tip: Pass the enum type directly to avoid casting issues from 'bit'
    covergroup cg with function sample(axi_lite_seq_item item);
        option.per_instance = 1;

        // SystemVerilog automatically creates bins for enums! 
        cp_op: coverpoint item.op;

        cp_addr: coverpoint item.addr {
            bins reg0 = {32'h0};
            bins reg1 = {32'h4};
            bins reg2 = {32'h8};
            bins reg3 = {32'hC};
        }

        cp_wdata: coverpoint item.wdata {
            bins zeros = {32'h0000_0000};
            bins rest  = {[32'h0000_0001:32'hFFFF_FFFE]};
            bins ones  = {32'hFFFF_FFFF};
        }

        // The DV Superpower: Ensure every address is BOTH read and written
        cross_op_addr: cross cp_op, cp_addr;

    endgroup

    function new(string name = "axi_lite_coverage", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write(axi_lite_seq_item t);
        // Sample the data
        cg.sample(t);
        // Print the current coverage percentage
        `uvm_info("COV", $sformatf("Current Coverage: %0.2f%%", cg.get_inst_coverage()), UVM_HIGH);
    endfunction
endclass
