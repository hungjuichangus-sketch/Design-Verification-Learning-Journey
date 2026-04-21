class env extends uvm_env;

    `uvm_component_utils(env)

    driver drv;
    scoreboard scb;
    monitor mon;
    coverage cov;

    uvm_sequencer #(add_item) sqr;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv = driver::type_id::create("drv", this);
        scb = scoreboard::type_id::create("scb", this);
        mon = monitor::type_id::create("mon", this);
        cov = coverage::type_id::create("cov", this);

        sqr = uvm_sequencer#(add_item)::type_id::create("sqr", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        mon.ap.connect(scb.ap_imp);
        mon.ap.connect(cov.ap_imp);

        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
