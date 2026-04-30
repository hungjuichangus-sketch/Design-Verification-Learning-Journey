class axi_lite_env extends uvm_env;
    `uvm_component_utils(axi_lite_env)

    axi_lite_agent agt;
    axi_lite_scoreboard scb;
    axi_lite_coverage cov;

    function new(string name = "axi_lite_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = axi_lite_agent::type_id::create("agt", this);
        scb = axi_lite_scoreboard::type_id::create("scb", this);
        cov = axi_lite_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.ap.connect(scb.item_fifo.analysis_export);
        agt.ap.connect(cov.analysis_export);
    endfunction
endclass
