# UVM Verification Example: Full-Duplex UART Transceiver Testbench

## Overview
This directory contains a complete, class-based Universal Verification Methodology (UVM) testbench for verifying a UART (Universal Asynchronous Receiver-Transmitter) system. The environment features a highly modular architecture, completely decoupling the software testbench from the hardware DUT using synchronous FIFOs and edge-detection synchronization. It utilizes UVM factory instantiation, advanced TLM (Transaction Level Modeling) routing for split coverage, and distribution-weighted constrained-random stimulus to aggressively stress hardware corner cases in a full-duplex configuration.

## Architecture & File Structure

The project is divided into the hardware models (DUTs/FIFOs) and the UVM verification environment components, strictly managed via a SystemVerilog package.

### 1. RTL & Interface
* **`uart_top.sv`**: The static hardware top module. It instantiates the UVM interface, clock/reset generators, the physical `tx`/`rx` hardware, and the bridging `fifo` modules. It also implements edge-detection logic to prevent hardware from over-consuming fast-clocked FIFO data.
* **`tx.sv` & `rx.sv`**: The RTL implementation of the UART transmitter and receiver state machines.
* **`fifo.sv`**: A parameterized synchronous FIFO module utilizing `$clog2` pointer width scaling to accurately track `full` and `empty` states.
* **`uart_if.sv`**: The SystemVerilog interface bundling the physical signals and utilizing a `clocking` block for synchronous setup/hold enforcement.

### 2. Stimulus & Driving
* **`uart_pkg.sv`**: The SystemVerilog package that imports the UVM library and dictates the strict top-down compilation order for all software classes.
* **`uart_seq_item.sv`**: The transaction class defining the 8-bit `payload` and the `transmit_delay`. It includes advanced `dist` constraints to force heavy traffic on absolute zero delays and critical payload corner cases (0x00 and 0xFF).
* **`uart_sequence.sv`**: Dynamic stimulus generator featuring a `num_pkts` knob controlled via `soft` constraints and command-line plusargs (`+PKTS=`).
* **`tx_driver.sv` & `rx_driver.sv`**: Active components that pull transactions from the sequencer. The `tx_driver` includes a dedicated `uvm_analysis_port` to pass original stimulus constraints directly to the coverage collector.

### 3. Monitoring, Checking & Coverage
* **`tx_monitor.sv` & `rx_monitor.sv`**: Passive components that observe the physical serial lines and interface pins, reconstruct the 8-bit payloads according to UART protocol timing, and broadcast them out.
* **`uart_scoreboard.sv`**: Utilizes TLM analysis FIFOs to receive observed traffic from both monitors and strictly compares transmitted data against received data.
* **`uart_coverage.sv`**: An extension of `uvm_subscriber` containing covergroups that measure the functional coverage of payload states and stimulus injection delays.

### 4. Top-Level & Execution
* **`tx_agent.sv` & `rx_agent.sv`**: Structural containers for the drivers, sequencers, and monitors. The `tx_agent` explicitly exposes a `drv_ap` pass-through port to uphold OOP encapsulation rules.
* **`uart_env.sv`**: The primary environment wrapping the agents, scoreboard, and coverage, handling all TLM megaphone-to-mailbox wiring during the `connect_phase`.
* **`uart_base_test.sv`**: The top-level test orchestrator. It applies `set_drain_time` to prevent premature simulation death, instantiates parallel sequences inside a `fork...join` block for full-duplex stress testing, and processes command-line overrides.

### 5. Architecture Diagram
```text
        _______________________________________________________________________
       |                              ENVIRONMENT                              |
       |  _________________                        _________________           |
       | |                 |                      |                 |          |
       | |    tx_agent     |                      |    rx_agent     |          |
       | |  _____________  |     ___________      |  _____________  |          |
       | | |             | |    |           |     | |             | |          |
       | | |  Sequencer  | |    | Scoreboard|     | |  Sequencer  | |          |
       | | |___       ___| |    |___________|     | |___       ___| |          |
       | |     |     ^     |      ^       ^       |     |     ^     |          |
       | |  ___V_____|___  |      |       |       |  ___V_____|___  |          |
       | | |             | |      |       |       | |             | |          |
       | | |   Driver    |-|----. |       |       | |   Driver    | |          |
       | | |_____________| |    | |       |       | |_____________| |          |
       | |  _____________  |    | |       |       |  _____________  |          |
       | | |             | |    | |       |       | |             | |          |
       | | | Monitor (Tx)|-|----|-´       `-------|-| Monitor (Rx)| |          |
       | | |_____________| |    |                 | |_____________| |          |
       | |_________________|    |   __________    |_________________|          |
       |                        |  |          |                                |
       |                        `->| Coverage |                                |
       |                           |__________|                                |
       |_______________________________________________________________________|
               | (UVM writes)                          ^ (UVM reads)
         ______V_______                          ______|_______
        |              |                        |              |
        |   TX FIFO    |                        |   RX FIFO    |
        |______________|                        |______________|
               | (Tx DUT reads)                        ^ (Rx DUT writes)
         ______V_______                          ______|_______
        |              |      (Serial Line)     |              |
        |    TX DUT    |----------------------->|    RX DUT    |
        |______________|                        |______________|
```

## Test Strategy & Constraints
The environment is engineered for aggressive, full-duplex hardware verification.

* **Distribution Shaping (`dist`)**: 
  * `payload`: 20% of traffic is forced to `8'h00` and `8'hFF` to test edge-case bit streams (e.g., false start/stop bits). 80% is uniformly randomized.
  * `transmit_delay`: 60% of traffic uses exactly `0` delay to bombard the hardware and test FIFO back-pressure. 10% tests long idle states to ensure proper state machine recovery.
* **Full-Duplex Threading**: The `run_phase` simultaneously triggers both the Tx and Rx sequences to inject and recover data on both sides of the hardware simultaneously.
* **Split Coverage Routing**: Functional coverage (payloads) is drawn directly from the Monitor, while stimulus coverage (delays) is drawn straight from the Driver, solving the classic DV "Data Visibility" trap.

## Coverage Report Summary
The verification environment achieved **100.00% Coverage**, successfully hitting all weighted random bins for both the physical payloads and the software timing delays.

**CUMULATIVE SUMMARY**
| Coverage Type | Weight | Hits/Total | Percentage |
| :--- | :--- | :--- | :--- |
| **Covergroup Coverage** | 1 | 1 / 1 | **100.000%** |

#### Detailed Bin Analysis

| Coverpoint / Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| **cp_delay** (Transmission Idle Timing) | | | **Covered** |
| - bin `low` (0 delay, back-to-back) | 116 | 1 | Covered |
| - bin `mid` (1 to 10 delay) | 61 | 1 | Covered |
| - bin `high` (11 to 50 delay) | 23 | 1 | Covered |
| **cp_payload** (8-bit Data) | | | **Covered** |
| - bin `zeros` (8'h00) | 16 | 1 | Covered |
| - bin `rest` (8'h01 to 8'hFE) | 158 | 1 | Covered |
| - bin `ones` (8'hFF) | 26 | 1 | Covered |

*(Total simulated transaction elements: 200)*

## Prerequisites & Execution
This project is configured to run on standard SystemVerilog commercial simulators supporting UVM 1.2. 

To execute the simulation directly via the browser:
1. Navigate to the EDA Playground Workspace: [https://www.edaplayground.com/x/aW88](https://www.edaplayground.com/x/aW88)
2. Select a UVM-compatible simulator (e.g., Aldec Riviera-PRO).
3. Under *Run Options*, confirm the `run.do` script contains the `-acdb_file` flag to save the coverage database.
4. Add the plusarg `+PKTS=[number]` to the Run Options to dynamically scale the test length without recompiling.
5. Click **Run** and review the UVM reporting output and the printed ACDB coverage report in the console.
