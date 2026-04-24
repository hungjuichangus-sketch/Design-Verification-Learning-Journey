package uart_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Base Transaction
    `include "uart_seq_item.sv"

    // Sequences
    `include "uart_sequence.sv"

    // Low-Level Components
    `include "tx_driver.sv"
    `include "rx_driver.sv"
    `include "tx_monitor.sv"
    `include "rx_monitor.sv"

    // Checking & Coverage Components
    `include "uart_scoreboard.sv"
    `include "uart_coverage.sv"

    // Agents (Need the drivers, monitors, and items to exist first)
    `include "tx_agent.sv"
    `include "rx_agent.sv"

    // Environment (Needs the agents, scoreboard, and coverage to exist first)
    `include "uart_env.sv"

    // Base Test (Needs the env to exist first)
    `include "uart_base_test.sv"

endpackage
