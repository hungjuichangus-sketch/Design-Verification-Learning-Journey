# Design Verification Example 1: Register Testbench

## Overview
This directory contains a complete class-based SystemVerilog testbench for verifying a register design. The environment is built using a layered architecture, separating stimulus generation, pin-level driving, monitoring, checking, and functional coverage into distinct components. This modular approach is highly scalable and establishes the foundational methodology used in modern Design Verification.

## Architecture & File Structure

The project is divided into the Design Under Test (DUT) and the verification environment components.

### 1. RTL & Interface
* **`reg_ctrl.sv`**: The RTL implementation of the hardware (Register DUT).
* **`reg_if.sv`**: The SystemVerilog interface that bundles the signals connecting the testbench to the DUT.

### 2. Stimulus & Driving
* **`reg_item.sv`**: The transaction class (sequence item) that defines the data fields (e.g., address, data, read/write control) and randomization constraints for register operations.
* **`generator.sv`**: Responsible for creating randomized `reg_item` transactions and passing them down to the driver.
* **`driver.sv`**: Receives high-level transactions from the generator and translates them into precise pin-level signaling on the `reg_if` to stimulate the DUT.

### 3. Monitoring, Checking & Coverage
* **`monitor.sv`**: Passively observes the interface signals, reconstructs them back into `reg_item` transactions, and broadcasts them for checking and coverage collection.
* **`scoreboard.sv`**: Receives the observed transactions from the monitor, tracks the expected behavior of the register, and compares actual DUT outputs against expected results to determine pass/fail status.
* **`coverage.sv`**: Implements covergroups and coverpoints to measure the functional coverage of the test vectors, ensuring all register states, addresses, and read/write operations are fully exercised.

### 4. Top-Level & Execution
* **`env.sv`**: The environment class that encapsulates and structurally connects the generator, driver, monitor, scoreboard, and coverage components.
* **`test.sv`**: The specific test scenario that instantiates the environment, configures the stimulus, and coordinates the execution flow.
* **`tb_top.sv`**: The top-level static module. It generates the clock and reset, instantiates the DUT and interface, and launches the class-based test.
* **`run.do`**: The Tcl execution script used to automate the compilation and simulation flow.
### 5. Architecture
       _________________________________________________________________
      |                          ENVIRONMENT                            |
      |   ________________      ________________      ________________  |
      |  |   Generator    |    |   Scoreboard   |    |    Coverage    | |
      |  |________________|    |________________|    |________________| |
      |          |                     ^                      ^         |
      |    (drv_mailbox)         (scb_mailbox)          (cov_mailbox)   |
      |          v                     |                      |         |
      |   ________________      ______________________________________  |
      |  |    Driver      |    |               Monitor                | |
      |  |________________|    |______________________________________| |
      |__________|_____________________________^________________________|
                 |                             |
           ______v_____________________________|______
          |                                           |
          |                    DUT                    |
          |___________________________________________|

### 6. Test Strategy & Constraints
The environment utilizes **Constrained-Random Verification (CRV)** to explore the design space efficiently. The `test_heavy_random` scenario executes **200 transactions** to ensure all bins in the coverage model are saturated.

* **Address Range**: Transactions are constrained to `[8'h00 : 8'h32]` to focus on specific register banks.
* **Transaction Mix**: A `dist` constraint ensures a 50/50 balance between Read and Write operations using `wr dist{0:=50, 1:=50}`.

### 7. Coverage Report Summary
The verification environment achieved **100.00% Functional Coverage** (simulated via Riviera-PRO). This confirms that every defined test scenario and cross-product was successfully exercised.

**CUMULATIVE SUMMARY**
| Coverage Type | Weight | Hits/Total | Percentage |
| :--- | :--- | :--- | :--- |
| **Covergroup Coverage** | 1 | 1 / 1 | **100.000%** |

#### Detailed Bin Analysis
| Coverpoint / Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| **cp_wr** (Read/Write) | | | **Covered** |
| - bin write | 97 | 1 | Covered |
| - bin read | 103 | 1 | Covered |
| **cp_addr** (Address) | | | **Covered** |
| - bin low [00:0F] | 53 | 1 | Covered |
| - bin mid [10:1F] | 67 | 1 | Covered |
| - bin high [20:32] | 80 | 1 | Covered |

**Cross Coverage (`cross_wr_addr`)**: 
Achieved 100% status by successfully hitting every combination of `{Read, Write}` across all address bins (`low`, `mid`, `high`), ensuring no operational state was left untested.

## Prerequisites & Execution
This project is configured to run on standard SystemVerilog simulators (such as Siemens Questa, Synopsys VCS, Cadence Xcelium, or Aldec Riviera Pro). 

To execute the simulation directly via the browser:
1. Navigate to the [EDA Playground Workspace](https://www.edaplayground.com/x/CuY8).
2. Ensure a SystemVerilog-compatible commercial simulator is selected in the left-hand menu.
3. Click **Run**. The platform will automatically compile the design and execute the testbench.
4. Review the console output upon completion to verify the Scoreboard comparisons and review the final functional coverage metrics.
