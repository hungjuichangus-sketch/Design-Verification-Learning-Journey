class rx_agent extends uvm_agent;
    `uvm_component_utils(rx_agent)

    rx_driver drv;
    rx_monitor mon;
    uvm_sequencer #(uart_seq_item) sqr;

    function new(string name = "rx_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = rx_monitor::type_id::create("mon", this);
        if(get_is_active() == UVM_ACTIVE)begin
            drv = rx_driver::type_id::create("drv", this);
            sqr = uvm_sequencer #(uart_seq_item)::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
