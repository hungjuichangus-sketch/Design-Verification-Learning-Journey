class axi_lite_seq_item extends uvm_sequence_item;

    // ------------------------------------------------------------------------
    // 1. Randomized Inputs (The "Intent")
    // ------------------------------------------------------------------------
    typedef enum bit {READ, WRITE} op_t;
    rand op_t        op;       // Are we reading or writing?
    rand bit [31:0]  addr;     // Where?
    rand bit [31:0]  wdata;    // What? (Only used if op == WRITE)
    rand bit [3:0]   wstrb;    // Byte enables (Usually 4'hF)

    // ------------------------------------------------------------------------
    // 2. Captured Outputs (Filled in by the Driver or Monitor)
    // ------------------------------------------------------------------------
    bit [31:0] rdata;          // Data read from the DUT
    bit [1:0]  resp;           // Response from DUT (bresp or rresp)

    // ------------------------------------------------------------------------
    // UVM Automation Macros
    // ------------------------------------------------------------------------
    `uvm_object_utils_begin(axi_lite_seq_item)
        `uvm_field_enum(op_t, op, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(wstrb, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
    `uvm_object_utils_end

    // ------------------------------------------------------------------------
    // Constraints (Your excellent logic)
    // ------------------------------------------------------------------------
    constraint wdata_c {
        wdata dist {
            32'h0000_0000 := 10,
            [32'h0000_0001 : 32'hFFFF_FFFE] :/ 80,
            32'hFFFF_FFFF := 10
        };
    }

    constraint addr_c {
        soft addr inside {0, 4, 8, 12};
    }

    constraint wstrb_c {
        soft wstrb == 4'hF; // Write all 32 bits for now
    }

    function new(string name = "axi_lite_seq_item");
        super.new(name);
    endfunction

endclass
