class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    tx_agent tx_agt;
    rx_agent rx_agt;
    uart_scoreboard scb;
    uart_coverage cov;

    function new(string name = "uart_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tx_agt = tx_agent::type_id::create("tx_agt", this);
        rx_agt = rx_agent::type_id::create("rx_agt", this);
        scb = uart_scoreboard::type_id::create("scb", this);
        cov = uart_coverage::type_id::create("cov", this);

        tx_agt.drv.ap.connect(cov.analysis_export);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        tx_agt.mon.ap.connect(scb.tx_actual_fifo.analysis_export);
        rx_agt.mon.ap.connect(scb.rx_actual_fifo.analysis_export);
        tx_agt.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
