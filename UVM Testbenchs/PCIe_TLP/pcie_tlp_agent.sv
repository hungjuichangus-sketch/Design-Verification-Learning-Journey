class pcie_tlp_agent extends uvm_agent;
    `uvm_component_utils(pcie_tlp_agent)

    pcie_tlp_driver drv;
    pcie_tlp_monitor mon;
    uvm_sequencer #(pcie_tlp_seq_item) sqr;
    uvm_analysis_port #(pcie_tlp_seq_item) req_ap, cpl_ap;

    function new(string name = "pcie_tlp_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = pcie_tlp_monitor::type_id::create("mon", this);
        req_ap = new("req_ap", this);
        cpl_ap = new("cpl_ap", this);
        if(get_is_active() == UVM_ACTIVE)begin
            drv = pcie_tlp_driver::type_id::create("drv", this);
            sqr = uvm_sequencer #(pcie_tlp_seq_item)::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.cpl_ap.connect(this.cpl_ap);
        mon.req_ap.connect(this.req_ap);
        if(get_is_active() == UVM_ACTIVE)begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass
