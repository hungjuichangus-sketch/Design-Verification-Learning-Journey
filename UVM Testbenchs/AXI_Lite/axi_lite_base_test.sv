class axi_lite_base_test extends uvm_test;
    `uvm_component_utils(axi_lite_base_test)

    axi_lite_env env;
    axi_lite_base_seq seq;
    uvm_objection objection;
    function new(string name = "axi_lite_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_lite_env::type_id::create("env", this);
        axi_lite_base_seq::type_id::set_type_override(axi_lite_sequence::get_type());
    endfunction

    task run_phase(uvm_phase phase);
        seq = axi_lite_base_seq::type_id::create("seq");

        objection = phase.get_objection();
        objection.set_drain_time(this, 200ns);

        phase.raise_objection(this);

        seq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask
endclass
