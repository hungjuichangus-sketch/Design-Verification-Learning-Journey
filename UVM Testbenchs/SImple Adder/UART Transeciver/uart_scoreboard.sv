class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_tlm_analysis_fifo #(uart_seq_item) tx_actual_fifo, rx_actual_fifo,
                                           tx_expected_fifo, rx_expected_fifo;

    function new(string name = "uart_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_actual_fifo = new("tx_actual_fifo", this);
        tx_expected_fifo = new("tx_expected_fifo", this);
        rx_actual_fifo = new("rx_actual_fifo", this);
        rx_expected_fifo = new("rx_expected_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
        fork
            check_tx_path();
            check_rx_path();
        join
    endtask

    task check_tx_path();
        uart_seq_item exp_item, act_item;
        forever begin
            tx_expected_fifo.get(exp_item);
            tx_actual_fifo.get(act_item);
            // Option 1
            if(exp_item.payload == act_item.payload)
                `uvm_info("SCR", "Tx path pass", UVM_HIGH)
            else
                `uvm_error("SCR", $sformatf("Tx path failed! Expected: %0h, Actual: %0h",
                                            exp_item.payload, act_item.payload))
        end
    endtask

    task check_rx_path();
        uart_seq_item exp_item, act_item;
        forever begin
            rx_expected_fifo.get(exp_item);
            rx_actual_fifo.get(act_item);
            // Option 2, because `uvm_object_utils_begin for uart_seq_item
            if(exp_item.compare(act_item))
                `uvm_info("SCR", "Rx path pass", UVM_HIGH)
            else
                `uvm_error("SCR", $sformatf("Rx path failed! Expected: %0h, Actual: %0h",
                                            exp_item.payload, act_item.payload))
        end
    endtask
endclass
