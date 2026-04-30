# UVM Verification Environment: AXI-Lite Slave & Protocol Checker

## Overview
This repository contains a complete, Object-Oriented Universal Verification Methodology (UVM) testbench designed to verify an Advanced eXtensible Interface (AXI-Lite) Slave IP. The environment is heavily focused on UVM Factory polymorphism, aggressive negative testing, and protocol compliance. The RTL features independent Read/Write state machines, while the verification suite leverages class inheritance to systematically stress hardware protection mechanisms, byte-level write strobes (`wstrb`), and unaligned access edge cases.

## Key Features
### 1. Complete UVM Architecture: Built a scalable, class-based environment from scratch utilizing Agents, Scoreboards, coverage subscribers, and TLM ports.

### 2. Polymorphic Test Matrix: Implemented 6 distinct test scenarios (Sanity, Read/Write Bursts, and Negative Tests) leveraging the UVM Factory to dynamically swap sequences without modifying the core environment.

### 3. Aggressive Negative Testing: Specifically targeted edge cases—such as unaligned addresses and out-of-bounds memory requests—verifying the hardware's ability to defend itself and correctly return SLVERR (2'b10).

### 4. Protocol-Aware "Smart" Scoreboard: Developed an advanced scoreboard featuring predictive error handling and bitwise for-loops to accurately track byte-level Write Strobe (wstrb) memory masks.

### 5. Dynamic Simulation Control: Integrated SystemVerilog +plusargs to allow users to scale transaction volume (e.g., +num_pkts=50) and select test scenarios directly from the command line, entirely bypassing recompilation.

### 6. Log Automation: Wrote a custom Python parsing script utilizing Regex to automatically scrape UVM simulation logs, extract error counts, and calculate final functional coverage metrics for regression triage.
## Architecture & File Structure

The project strictly separates the hardware protocol logic from the software verification environment using a parameterized SystemVerilog package.

### 1. RTL Design & Interface
* **`axi_lite_slave.sv`**: The hardware DUT. Implements dual FSMs for concurrent Read and Write channel processing. Features internal memory protection, responding with `SLVERR` (`2'b10`) for illegal or out-of-bounds address requests, and utilizes hardware `for` loops for `wstrb` byte-masking.
* **`axi_lite_if.sv`**: The SystemVerilog interface bundling the 5 AXI channels (AW, W, B, AR, R) and providing synchronous clocking blocks.

### 2. Stimulus & Sequences (Polymorphic Design)
* **`axi_lite_pkg.sv`**: Manages the strict top-down compilation order required for UVM inheritance.
* **`axi_lite_seq_item.sv`**: The transaction payload. Utilizes `soft` constraints to define default legal parameters (valid addresses, full strobes), allowing child sequences to cleanly override them for error injection.
* **`axi_lite_base_seq.sv`**: The parent sequence. Handles common setup tasks and dynamic command-line plusargs (`+num_pkts=`).
* **Child Sequences**: A library of highly targeted sequences (`read_burst`, `write_burst`, `illegal_addr`, `unaligned_addr`, `wstrb`) that extend the base sequence to inject specific protocol edge-cases.

### 3. Monitoring, Checking & Coverage
* **`axi_lite_monitor.sv`**: Utilizes `fork...join` blocks to independently and concurrently sample AXI channels, perfectly capturing zero-delay back-to-back handshakes without race conditions.
* **`axi_lite_scoreboard.sv`**: A "Smart Scoreboard" that mimics the RTL's defensive logic. It predicts hardware errors (expecting `SLVERR` for bad addresses) and applies bitwise masking to accurately track `wstrb` memory updates.
* **`axi_lite_coverage.sv`**: A UVM subscriber that measures functional coverage across operation types, specific register access, and payload distributions.

### 4. Tests & Factory Overrides
* **`axi_lite_base_test.sv`**: The parent test environment. Instantiates the topology and sets the default execution flow.
* **Child Tests**: A suite of tiny, modular test classes. Each uses the **UVM Factory** (`set_type_override`) to dynamically swap out the base sequence for a targeted scenario without altering the core environment.

### 5. Architecture Diagram
```text
        _________________________________________________________________
       |                           ENVIRONMENT                           |
       |  _________________                             ______________   |
       | |                 |                           |              |  |
       | |    axi_agent    |                           | Scoreboard   |  |
       | |  _____________  |       _____________       |______________|  |
       | | |             | |      |             |             ^          |
       | | |  Sequencer  | |      |  Coverage   |             |          |
       | | |_____________| |      |_____________|             |          |
       | |       |         |             ^                    |          |
       | |  _____V_______  |             |                    |          |
       | | |             | |             |                    |          |
       | | |   Driver    | |             |                    |          |
       | | |_____________| |             |                    |          |
       | |       |         |             |                    |          |
       | |  _____V_______  |  ___________|____________________|          |
       | | |             | | |                                           |
       | | |   Monitor   |-|-'                                           |
       | | |_____________| |                                             |
       | |_________________|                                             |
       |_________________________________________________________________|
                 | (AW, W, B, AR, R Channels)        ^
         ________V___________________________________|________
        |                                                     |
        |                  AXI-LITE SLAVE DUT                 |
        |_____________________________________________________|
```

## Verification Strategy & Coverage Matrix
The test suite is built to verify both positive protocol compliance and negative error handling. 

> **A Note on Functional Coverage:** In this architecture, functional coverage is evaluated on a *per-scenario* basis. Directed negative tests (e.g., Illegal Address) are intentionally constrained to hit invalid memory spaces, meaning they will not cover valid register bins. The ultimate goal for these negative scenarios is a clean Scoreboard pass (verifying the hardware's `SLVERR` defense), rather than 100% functional coverage on a single run. Total 100% coverage is achieved by merging the databases of the full regression suite.

| Test Name / Factory Override | Target Scenario | Scoreboard Status | Scenario Coverage |
| :--- | :--- | :--- | :--- |
| **`axi_lite_base_test`** | Basic Legal Read/Write pairs (Sanity). | PASS | **100.00%** |
| **`axi_lite_wstrb_test`** | Random byte-enables (`wstrb`). | PASS | **100.00%** |
| **`axi_lite_write_burst_test`** | 100% Write saturation to valid addresses. | PASS | 75.00% |
| **`axi_lite_read_burst_test`** | 100% Read saturation to valid addresses. | PASS | 58.33% |
| **`axi_lite_illegal_addr_test`**| Out-of-bounds memory requests. | PASS | 50.00% |
| **`axi_lite_unaligned_addr_test`**| Non-word-aligned addresses. | PASS | 50.00% |

## Python Log Automation & Regression Triage
This repository includes a custom Python parsing script (`parse_axi_lite_log.py`) to automate regression analysis. The script uses Regex to scan UVM simulator output, dynamically extracting `UVM_ERROR` counts, simulation time, and the final Coverage percentage to simulate industry-standard CI/CD regression triage.

**Execution:**
Save your simulator output to `sim_log.txt` and run the parser:
```bash
python parse_axi_lite_log.py
```

## Prerequisites & Execution
This project is designed for standard SystemVerilog commercial simulators (e.g., Aldec Riviera-PRO, Synopsys VCS, Cadence Xcelium) supporting UVM 1.2. 

**Live Simulation Environment:**
You can run this full testbench directly in your browser via EDA Playground:
* **Workspace URL:** [https://www.edaplayground.com/x/AYUD](https://www.edaplayground.com/x/AYUD)

**Command Line Controls:**
* Scale test lengths without recompiling: `+num_pkts=[integer]`
* Run specific tests from the matrix via the UVM Factory: `+UVM_TESTNAME=[test_class_name]`

---
**Author:** Hung Jui Chang
*ASIC / IC Design Verification Engineer*
