class coverage extends uvm_component;
    `uvm_component_utils(coverage)

    uvm_analysis_imp #(add_item, coverage) ap_imp;

    covergroup cg with function sample(bit a, bit b);
        option.per_instance = 1;
        c_a: coverpoint a { bins one = {1}; bins zero = {0}; }
        c_b: coverpoint b { bins one = {1}; bins zero = {0}; }
        x_a_b: cross c_a, c_b;
    endgroup

    function new(string name = "coverage", uvm_component parent = null);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.new(phase);
        ap_imp = build_phase("ap_imp", this);
    endfunction

    function void write(add_item t);
        cg.sample(t.a, t.b);
        `uvm_info("COV", $sformatf("Sampled transaction a=%0b, b=%0b", t.a, t.b), UVM_HIGH)
    endfunction
endclass
