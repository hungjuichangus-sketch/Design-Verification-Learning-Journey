package axi_lite_pkg;

    // 1. Import UVM base library
    import uvm_pkg::*;

    // 2. Include UVM macros so all classes in this package can use `uvm_info, etc.
    `include "uvm_macros.svh"

    // ========================================================================
    // 3. Include Testbench Files (ORDER IS CRITICAL)
    // ========================================================================

    // Level 1: Transactions
    `include "axi_lite_seq_item.sv"

    // Level 2: Sequences (Depend on Transactions)
    // -> PARENT SEQUENCE FIRST
    `include "axi_lite_base_seq.sv"

    // -> CHILD SEQUENCES NEXT
    `include "axi_lite_sequence.sv" // Your original Sanity sequence
    `include "axi_lite_read_burst_seq.sv"
    `include "axi_lite_write_burst_seq.sv"
    `include "axi_lite_illegal_addr_seq.sv"
    `include "axi_lite_unaligned_addr_seq.sv"
    `include "axi_lite_wstrb_seq.sv"

    // Level 3: Agent Components (Depend on Transactions)
    `include "axi_lite_driver.sv"
    `include "axi_lite_monitor.sv"
    `include "axi_lite_coverage.sv" // Your subscriber

    // Level 4: The Agent (Depends on Driver, Monitor, Sequencer)
    `include "axi_lite_agent.sv"

    // Level 5: The Scoreboard (Depends on Transactions)
    `include "axi_lite_scoreboard.sv"

    // Level 6: The Environment (Depends on Agent, Scoreboard, Coverage)
    `include "axi_lite_env.sv"

    // Level 7: The Tests (Depend on Environment and Sequences)
    // -> PARENT TEST FIRST
    `include "axi_lite_base_test.sv"

    // -> CHILD TESTS NEXT (Add any specific test classes you create here)
    `include "axi_lite_write_burst_test.sv"
    `include "axi_lite_read_burst_test.sv"
    `include "axi_lite_illegal_addr_test.sv"
    `include "axi_lite_unaligned_addr_test.sv"
    `include "axi_lite_wstrb_test.sv"

endpackage
