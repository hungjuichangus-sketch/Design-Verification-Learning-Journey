class uart_coverage extends uvm_subscriber #(uart_seq_item);
    `uvm_component_utils(uart_coverage)

    covergroup cg with function sample(bit [7:0] payload, int unsigned transmit_delay);
        option.per_instance = 1;

        cp_delay: coverpoint transmit_delay {
            bins low  = {0};
            bins mid  = {[1:10]};
            bins high = {[11:50]};
        }

        cp_payload: coverpoint payload {
            bins zeros = {0};
            bins rest  = {[8'h01:8'hFE]};
            bins ones  = {8'hFF};
        }
    endgroup

    function new(string name = "uart_coverage", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write(uart_seq_item t);
        cg.sample(t.payload, t.transmit_delay);
        `uvm_info("COV", $sformatf("Sampled payload=%0h, delay=%0d",
                                    t.payload, t.transmit_delay), UVM_HIGH)
    endfunction

endclass
