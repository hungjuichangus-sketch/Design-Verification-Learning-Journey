class rx_monitor extends uvm_monitor;
    `uvm_component_utils(rx_monitor)

    virtual uart_if vif;
    uart_seq_item item;

    uvm_analysis_port#(uart_seq_item) ap;

    function new(string name = "rx_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("RX_MON", "Could not get the virtual interface from Config DB")
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            wait(vif.cb.rx_read_en == 1'b1);
            item = uart_seq_item::type_id::create("item");
            @(vif.cb);
            item.payload = vif.cb.rx_data_out;
            ap.write(item);
        end
    endtask

endclass
