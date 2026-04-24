class tx_agent extends uvm_agent;
    `uvm_component_utils(tx_agent)

    tx_driver drv;
    tx_monitor mon;
    uvm_sequencer #(uart_seq_item) sqr;
    uvm_analysis_port #(uart_seq_item) ap;

    function new(string name = "tx_agent", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = tx_monitor::type_id::create("mon", this);
        if(get_is_active() == UVM_ACTIVE)begin
            drv = tx_driver::type_id::create("drv", this);
            sqr = uvm_sequencer #(uart_seq_item)::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
