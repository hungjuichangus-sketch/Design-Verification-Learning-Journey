class uart_seq_item extends uvm_sequence_item;

    rand bit [7:0] payload;
    rand int unsigned transmit_delay;

    `uvm_object_utils_begin(uart_seq_item)

        // Register the data payload (compare this)
        `uvm_field_int(payload, UVM_DEFAULT)

        // Register the delay knob (NOT compare this)
        `uvm_field_int(transmit_delay, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint delay_c {
        transmit_delay dist{
            0 := 60,
            [1:10] :/ 30,
            [11:50] :/10
        };
    };

    constraint payload_c {
        payload dist{
            8'h00 := 10,
            8'hFF := 10,
            [8'h01:8'hFE] :/ 80
        };
    };

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction

endclass
