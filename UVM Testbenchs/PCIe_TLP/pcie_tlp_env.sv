class pcie_tlp_env extends uvm_env;
    `uvm_component_utils(pcie_tlp_env)

    pcie_tlp_agent agt;
    pcie_tlp_scoreboard scb;
    pcie_tlp_coverage cov;

    function new(string name = "pcie_tlp_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = pcie_tlp_agent::type_id::create("agt", this);
        scb = pcie_tlp_scoreboard::type_id::create("scb", this);
        cov = pcie_tlp_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.req_ap.connect(scb.req_fifo.analysis_export);
        agt.cpl_ap.connect(scb.cpl_fifo.analysis_export);
        agt.req_ap.connect(cov.analysis_export);
    endfunction
endclass
