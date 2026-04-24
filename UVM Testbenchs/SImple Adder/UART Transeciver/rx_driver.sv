class rx_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(rx_driver)

    virtual uart_if vif;

    function new(string name = "rx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("RX_DRV", "Could not get the virtual interface from Config DB")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_rx(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_rx(uart_seq_item req);
        repeat(req.transmit_delay)
            @(vif.cb);
        vif.cb.rx_in <= 1'b0;
        repeat(16)
            @(vif.cb);
        for(int i = 0; i < 8; i++)begin
            vif.cb.rx_in <= req.payload[i];
            repeat(16)
                @(vif.cb);
        end
        vif.cb.rx_in <= 1'b1;
        repeat(16)
            @(vif.cb);
    endtask
endclass
