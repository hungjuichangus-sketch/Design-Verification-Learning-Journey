# UVM Verification Example: Synchronous Adder Testbench

## Overview
This directory contains a complete, class-based Universal Verification Methodology (UVM) testbench for verifying a synchronous adder design. The environment transitions from a custom layered architecture to a standard UVM architecture, utilizing UVM factory instantiation, phasing, reporting, TLM (Transaction Level Modeling) communication, and sequence-based stimulus generation. This highly scalable approach ensures robust verification, eliminates race conditions through clocking blocks, and aligns with modern Design Verification industry standards.

## Architecture & File Structure

The project is divided into the Design Under Test (DUT) and the UVM verification environment components.

### 1. RTL & Interface
* **`my_adder.sv`**: The RTL implementation of the hardware (Adder DUT) featuring synchronous reset and combinational addition logic.
* **`add_if.sv`**: The SystemVerilog interface that bundles the signals connecting the testbench to the DUT. It incorporates `clocking` blocks (`drv_cb` and `mon_cb`) to enforce strict setup and hold sampling times.

### 2. Stimulus & Driving
* **`add_item.sv`**: The UVM transaction class (`uvm_sequence_item`) that defines the data fields (e.g., operands `a`, `b`, `carry`, `sum`), registers with the UVM factory, and handles randomization for the arithmetic operations.
* **`add_sequence.sv`**: The UVM sequence (`uvm_sequence`) responsible for generating randomized `add_item` transactions and utilizing the UVM handshake (`start_item` / `finish_item`) to send them to the driver. 
* **`driver.sv`**: The UVM driver (`uvm_driver`) that retrieves high-level transactions from the sequencer via `seq_item_port.get_next_item()`, executes a dedicated reset phase, and translates the transactions into precise pin-level signaling on the `add_if` via clocking blocks.
* **`generator.sv`**: *(Transitional/Legacy)* A legacy generator component retained to demonstrate the structural migration from custom mailbox communication to UVM phasing and reporting.

### 3. Monitoring, Checking & Coverage
* **`monitor.sv`**: Passively observes the interface signals via clocking blocks, reconstructs them back into `add_item` transactions, and broadcasts them out via a `uvm_analysis_port`.
* **`scoreboard.sv`**: Receives the observed transactions through a `uvm_analysis_imp`, mathematically verifies the expected behavior (`a + b == {carry, sum}`), and triggers a `test_done` event to gracefully coordinate test termination.
* **`coverage.sv`**: Implements covergroups and coverpoints to measure the functional coverage of the test vectors through a `uvm_analysis_imp`, ensuring all possible boolean states of inputs `a` and `b` are fully exercised.

### 4. Top-Level & Execution
* **`env.sv`**: The UVM environment (`uvm_env`) that encapsulates and structurally connects the sequencer, driver, monitor, scoreboard, and coverage components using UVM TLM connections during the `connect_phase`.
* **`test.sv` / `tb_top` (Integrated)**: Contains the base UVM test (`base_test`) and extended tests (`test_long`) that instantiate the environment, configure the stimulus count, and manage UVM objections during the `run_phase`. The static `tb_top` module generates the clock, sets the virtual interface in the `uvm_config_db`, instantiates the DUT, and launches `run_test()`.

### 5. Architecture Diagram
```text
       _________________________________________________________________
      |                           ENVIRONMENT                           |
      |                                                                 |
      |     _______________                                             |
      |    |               |                                            |
      |    |  add_sequence |                                            |
      |    |_______________|                                            |
      |            |                                                    |
      |  __________V_______      ________________      ________________ |
      | |                  |    |                |    |                ||
      | |  uvm_sequencer   |    |   Scoreboard   |    |    Coverage    ||
      | |__________________|    |________________|    |________________||
      |            |                     ^                     ^        |
      | (seq_item_port/export)           | (ap_imp)            | (ap_imp|
      |            |                     |                     |        |
      |  __________V_______      ________|_____________________|_______ |
      | |                  |    |                                      ||
      | |      Driver      |    |               Monitor                ||
      | |__________________|    |______________________________________||
      |__________|_________________________________^____________________|
                 |                                 |
           ______V_________________________________|______
          |                                               |
          |                      DUT                      |
          |_______________________________________________|
```

## Test Strategy & Constraints
The environment utilizes **Constrained-Random Verification (CRV)** coupled with standard **UVM Phasing and Objections** to explore the design space efficiently. 

* **Operand Range**: The 1-bit inputs (`a` and `b`) are randomized within the `add_item` transaction to hit all possible binary states (0 and 1).
* **Test Flow & Termination**: The test (`base_test`) dictates execution length by raising a UVM objection, launching the `add_sequence` on the sequencer, waiting for the Scoreboard's `test_done` event, and finally dropping the objection to gracefully terminate the simulation. Factory overrides and test extensions (e.g., `test_long`) modify `test_num_tx` to scale transaction generation.

## Coverage Report Summary
The verification environment achieved **100.00% Functional Coverage** based on the cross-coverage model for the operands.

**CUMULATIVE SUMMARY**
| Coverage Type | Weight | Hits/Total | Percentage |
| :--- | :--- | :--- | :--- |
| **Covergroup Coverage** | 1 | 1 / 1 | **100.000%** |

#### Detailed Bin Analysis

| Coverpoint / Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| **c_a** (Input A) | | | **Covered** |
| - bin `one` | 25 | 1 | Covered |
| - bin `zero` | 25 | 1 | Covered |
| **c_b** (Input B) | | | **Covered** |
| - bin `one` | 25 | 1 | Covered |
| - bin `zero` | 25 | 1 | Covered |

**Cross Coverage (`x_a_b`)**: 

| Cross Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| - bin `<one,one>` | 13 | 1 | Covered |
| - bin `<one,zero>` | 12 | 1 | Covered |
| - bin `<zero,one>` | 12 | 1 | Covered |
| - bin `<zero,zero>`| 13 | 1 | Covered |

## Prerequisites & Execution
This project is configured to run on standard SystemVerilog commercial simulators supporting UVM 1.2 or IEEE 1800.2 (e.g., Siemens Questa, Synopsys VCS, Cadence Xcelium, Aldec Riviera-PRO). 

To execute the simulation directly via the browser:
1. Navigate to the EDA Playground Workspace: [https://www.edaplayground.com/x/tKrV](https://www.edaplayground.com/x/tKrV)
2. Select a UVM-compatible simulator (e.g., Aldec Riviera Pro) in the left-hand menu.
3. Verify that the UVM library (e.g., UVM 1.2) is enabled in the simulator options.
4. Click **Run** to compile the design and execute the testbench. Review the UVM reporting output (`UVM_INFO`, `UVM_ERROR`) in the console to verify the Scoreboard comparisons.
