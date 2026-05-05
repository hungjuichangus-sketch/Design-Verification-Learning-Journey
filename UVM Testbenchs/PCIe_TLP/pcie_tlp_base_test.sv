class pcie_tlp_base_test extends uvm_test;
    `uvm_component_utils(pcie_tlp_base_test)

    pcie_tlp_env env;
    pcie_tlp_base_seq seq;
    uvm_objection objection;

    function new(string name = "pcie_tlp_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = pcie_tlp_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        seq = pcie_tlp_base_seq::type_id::create("seq");
        objection = phase.get_objection();
        objection.set_drain_time(this, 2000ns);

        phase.raise_objection(this);

        seq.start(env.agt.sqr);
        wait(env.scb.pending_reads.size() == 0);

        phase.drop_objection(this);
    endtask
endclass
