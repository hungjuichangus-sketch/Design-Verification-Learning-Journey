class tx_monitor extends uvm_monitor;
    `uvm_component_utils(tx_monitor)

    virtual uart_if vif;
    uart_seq_item item;

    uvm_analysis_port #(uart_seq_item) ap;

    function new(string name = "tx_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("TX_MON", "Could not get the virtual interface from Config DB")
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect_serial_data();
        end
    endtask

    task collect_serial_data();
        logic [7:0] temp_data;

        // 1. Hunt for the falling edge
        while(vif.cb.tx_out == 1'b1) begin
            @(vif.cb);
        end

        // 2. Shift to the middle of start bit
        repeat (8) @(vif.cb);

        // 3. Noise Filter / Glitch Detection
        if (vif.cb.tx_out == 1'b1) begin
            // It was a glitch! Exit the task early and go back to hunting.
            return;
        end

        // 4. Sample the Data Bits
        for(int i = 0; i < 8; i++) begin
            // Shift entire bit to the middle of data
            repeat(16) @(vif.cb);
            temp_data[i] = vif.cb.tx_out;
        end

        // 5. Shift to the middle of stop bit
        repeat (16) @(vif.cb);

        // Optional DV Check: You could verify the stop bit is 1 here
        // if (vif.cb.tx_out == 1'b0) `uvm_error("MON", "Framing Error Detected!")

        // 6. Broadcast the Transaction
        item = uart_seq_item::type_id::create("item");
        item.payload = temp_data;
        ap.write(item);
    endtask
endclass
