# UVM Verification Environment: PCIe Transaction Layer & Protocol Checker

## Overview
This repository contains a complete, Object-Oriented Universal Verification Methodology (UVM) testbench designed to verify a mock PCI Express (PCIe) Endpoint. The environment is heavily focused on UVM Factory polymorphism, advanced protocol compliance, and handling split-transaction architectures. The RTL features decoupled Read/Write state machines utilizing a Hardware FIFO (Pending Request Table) to simulate out-of-order completions, while the verification suite leverages class inheritance to systematically stress back-to-back traffic, byte enables, and tag-matching.

## Key Features
* Complete UVM Architecture: Built a scalable, class-based environment from scratch utilizing Agents, Scoreboards, coverage subscribers, and TLM ports.

* Out-of-Order "Smart" Scoreboard: Developed an advanced scoreboard featuring $O(1)$ associative array lookups to track in-flight PCIe Tags. It correctly matches randomized, out-of-order Completion data back to the original Host Requests.

* Decoupled RX/TX Hardware Engines: The RTL models a true split-transaction endpoint with independent `always_ff` blocks for RX and TX, communicating via a struct-based SystemVerilog queue to prevent Head-of-Line (HOL) blocking.

* Protocol-Aware Sequence Items: Transactions utilize `post_randomize()` to accurately bit-pack PCIe TLP headers (Format, Type, Length, Tag, Byte Enables) according to the PCIe specification.

* Dual-Lens Clocking Blocks: Implemented strict physical hardware rules using separate `drv_cb` (outputs) and `mon_cb` (inputs) within the interface to prevent testbench race conditions.

* Dynamic Simulation Control: Integrated SystemVerilog +plusargs to allow users to scale transaction volume (e.g., `+num_pkts=50`) and select test scenarios directly from the command line, entirely bypassing recompilation.

### Architecture & File Structure

The project strictly separates the hardware protocol logic from the software verification environment using a parameterized SystemVerilog package and proper compilation ordering.

### 1. RTL Design & Interface
* **`mock_pcie_ep.sv`**: The hardware DUT. Implements decoupled FSMs for concurrent Read and Write channel processing. Utilizes a Pending Request Table (PRT) to randomly pop and serve Read requests, accurately simulating out-of-order memory retrieval. 
* **`pcie_tlp_if.sv`**: The SystemVerilog interface bundling the PCIe TX and RX channels (`data`, `valid`, `sop`, `eop`) and providing synchronous clocking blocks for active driving and passive monitoring.

### 2. Stimulus & Sequences (Polymorphic Design)
* **`pcie_tlp_pkg.sv`**: Manages the strict top-down compilation order required for UVM inheritance.
* **`pcie_tlp_seq_item.sv`**: The transaction payload. Utilizes `soft` constraints to define default legal parameters for 3-DW Header TLPs (Memory Read, Memory Write).
* **`pcie_tlp_base_seq.sv`**: The parent sequence. Handles common setup tasks and dynamic command-line plusargs (`+num_pkts=`).
* **Child Sequences**: A library of targeted sequences (e.g., `pcie_tlp_sanity_seq`, `pcie_tlp_b2b_seq`) that extend the base sequence to inject specific protocol behaviors and traffic stress.

### 3. Monitoring, Checking & Coverage
* **`pcie_tlp_monitor.sv`**: Utilizes `fork...join_none` blocks to independently and concurrently sample RX and TX channels, perfectly rebuilding TLPs from the raw bus wires using the `mon_cb`.
* **`pcie_tlp_scoreboard.sv`**: A reference model that mimics the host memory. It captures Write payloads into a shadow memory, queues Read tags, and verifies incoming TX Completions against the expected shadow data.
* **`pcie_tlp_coverage.sv`**: A UVM subscriber that measures functional coverage across TLP formats, burst lengths, and byte enable crosses.

### 4. Tests & Factory Overrides
* **`pcie_tlp_base_test.sv`**: The parent test environment. Instantiates the topology and sets the default execution drain times.
* **Child Tests**: A suite of modular test classes. Each uses the **UVM Factory** (`set_type_override`) to dynamically swap out the base sequence for a targeted scenario without altering the core environment.

### 5. Architecture Diagram
```text
         ___________________________________________________________________
        |                            ENVIRONMENT                            |
        |  _______________________________________           _____________  |
        | |               pcie_agent              |         |             | |
        | |  _____________          _____________ |  cpl_ap | Scoreboard  | |
        | | |             |        |             ||-------->|_____________| |
        | | |  Sequencer  |        |   Monitor   ||  req_ap        ^        |
        | | |_____________|        |_____________||--------.       |        |
        | |       |                      ^        |        |   ____|______  |
        | |  _____V_______               |        |        `->|           | |
        | | |             |              |        |           |  Coverage | |
        | | |   Driver    |              |        |           |___________| |
        | | |_____________|              |        |                         |
        | |_______|______________________|________|                         |
        |_________|______________________|__________________________________|
                  | Drives               | Samples both
                  | rx_* wires           | rx_* and tx_* wires
         _________V______________________|__________________________________
        |                                                                   |
        |                    pcie_tlp_if (Virtual Interface)                |
        |___________________________________________________________________|
                                          ^
         _________________________________|_________________________________
        |                                                                   |
        |                        mock_pcie_ep (DUT)                         |
        |___________________________________________________________________|
```

## Comprehensive Test Plan & Coverage Matrix
The test suite is built to verify positive protocol compliance, aggressive traffic stress, edge-case architectural boundaries, and negative hardware error handling.

> **A Note on Functional Coverage:** Functional coverage is evaluated on a *per-scenario* basis. Total coverage is achieved by merging the databases of the full regression suite.

### Phase 1: Traffic & Throughput Stress
| Test Name / Factory Override | Target Scenario | Scoreboard Status | Scenario Coverage |
| :--- | :--- | :--- | :--- |
| **`pcie_tlp_sanity_test`** | Basic Legal Read/Write initialization pairs. | PASS | |
| **`pcie_tlp_b2b_test`** | Back-to-Back traffic (No idle cycles between TLPs). | | |
| **`pcie_tlp_ooo_avalanche_test`** | Rapid burst of 256 Reads using all available tags to stress the hardware PRT (FIFO). | | |
| **`pcie_tlp_walking_pattern_test`** | Writes hostile bit patterns (`0xFFFF`, `0xAAAA`, walking 1s) to test datapath integrity. | | |

### Phase 2: Architectural Corner Cases
| Test Name / Factory Override | Target Scenario | Scoreboard Status | Scenario Coverage |
| :--- | :--- | :--- | :--- |
| **`pcie_tlp_max_payload_test`** | Sends Maximum Payload Size (MPS) and Minimum (1 DW) transactions. | | |
| **`pcie_tlp_unaligned_addr_test`** | Aligned addresses with randomized `first_dw_be` / `last_dw_be`. Verifies 7-bit Lower Address calculation in Completions. | | |
| **`pcie_tlp_zero_length_read_test`**| Length = 1, Byte Enables = `0000`. Verifies endpoint returns successful completion with 0 data payload. | | |

### Phase 3: Negative & Protocol Error Tests
| Test Name / Factory Override | Target Scenario | Scoreboard Status | Scenario Coverage |
| :--- | :--- | :--- | :--- |
| **`pcie_tlp_ur_test`** | Unsupported Requests (e.g., I/O Read, Message TLP). Expects UR (`001`) status in Completion. | | |
| **`pcie_tlp_malformed_tlp_test`** | Injects length mismatches (e.g., Header says 10 DW, but `rx_eop` asserts at 5 DW). | | |
| **`pcie_tlp_out_of_bounds_test`** | Reads/Writes to addresses outside the 4KB (1024 word) physical memory space. | | |

## Prerequisites & Execution
This project is designed for standard SystemVerilog commercial simulators supporting UVM 1.2. 

**Live Simulation Environment:**
You can run this full testbench directly in your browser via EDA Playground:
* **Workspace URL:** [https://www.edaplayground.com/x/MzPs](https://www.edaplayground.com/x/MzPs)

**Command Line Controls:**
* Scale test lengths without recompiling: `+num_pkts=[integer]`
* Run specific tests from the matrix via the UVM Factory: `+UVM_TESTNAME=[test_class_name]`

---
**Author:** Hung Jui Chang