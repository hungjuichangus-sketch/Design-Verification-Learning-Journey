class tx_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(tx_driver)

    virtual uart_if vif;
    uvm_analysis_port #(uart_seq_item) ap;

    function new(string name = "tx_driver", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("TX_DRV", "Could not get the virtual interface from Config DB")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            ap.write(req);
            drive_tx(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_tx(uart_seq_item req);
        repeat(req.transmit_delay)
            @(vif.cb);

        wait(vif.cb.tx_full == 1'b0);

        vif.cb.tx_data_in <= req.payload;
        vif.cb.tx_write_en <= 1'b1;
        @(vif.cb);
        vif.cb.tx_write_en <= 1'b0;
    endtask
endclass
