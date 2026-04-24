class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    uart_env env;
    uart_sequence tx_seq;
    uart_sequence rx_seq;
    int test_length = 50;

    function new(string name = "uart_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 200000);
        tx_seq = uart_sequence::type_id::create("tx_seq");
        rx_seq = uart_sequence::type_id::create("rx_seq");

        // Look for a flag called +PKTS= in the command line
        if ($value$plusargs("PKTS=%d", test_length)) begin
            `uvm_info("TEST", $sformatf("Command line override: Running %0d packets", test_length), UVM_NONE)
        end
        // 1. The Test decides the length! Override the soft constraint here.
        if (!tx_seq.randomize() with { num_pkts == test_length; })
            `uvm_fatal("TEST", "Failed to randomize tx_seq")

        if (!rx_seq.randomize() with { num_pkts == test_length; })
            `uvm_fatal("TEST", "Failed to randomize rx_seq")
        fork
            tx_seq.start(env.tx_agt.sqr);
            rx_seq.start(env.rx_agt.sqr);
        join
        phase.drop_objection(this);
    endtask

endclass
