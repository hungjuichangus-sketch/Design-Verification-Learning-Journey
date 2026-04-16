# Design Verification Example 1: Synchronous Adder Testbench

## Overview
This directory contains a complete class-based SystemVerilog testbench for verifying a synchronous adder design. The environment is built using a layered architecture, separating stimulus generation, pin-level driving, monitoring, checking, and functional coverage into distinct components. This modular approach is highly scalable, incorporates event-driven termination and clocking blocks to prevent race conditions, and establishes the foundational methodology used in modern Design Verification.

## Architecture & File Structure

The project is divided into the Design Under Test (DUT) and the verification environment components.

### 1. RTL & Interface
* **`my_adder.sv`**: The RTL implementation of the hardware (Adder DUT).
* **`add_if.sv`**: The SystemVerilog interface that bundles the signals connecting the testbench to the DUT. It incorporates `clocking` blocks to enforce strict setup and hold sampling times.

### 2. Stimulus & Driving
* **`add_item.sv`**: The transaction class (sequence item) that defines the data fields (e.g., operands `a`, `b`, `carry`, `sum`) and randomization constraints for the arithmetic operations.
* **`generator.sv`**: Responsible for creating randomized `add_item` transactions and passing them down to the driver.
* **`driver.sv`**: Receives high-level transactions, executes a dedicated active-low reset phase, and translates the transactions into precise pin-level signaling on the `add_if` via clocking blocks.

### 3. Monitoring, Checking & Coverage
* **`monitor.sv`**: Passively observes the interface signals via clocking blocks, reconstructs them back into `add_item` transactions, and broadcasts them for checking and coverage collection.
* **`scoreboard.sv`**: Receives the observed transactions from the monitor, mathematically verifies the expected behavior (`a + b == {carry, sum}`), and triggers an event to gracefully terminate the test once all transactions are processed.
* **`coverage.sv`**: Implements covergroups and coverpoints to measure the functional coverage of the test vectors, ensuring all possible boolean states of inputs `a` and `b` are fully exercised.

### 4. Top-Level & Execution
* **`env.sv`**: The environment class that encapsulates and structurally connects the generator, driver, monitor, scoreboard, and coverage components. It manages the distinct test phases (Reset, Background Threads, Generation).
* **`base_test.sv`**: The specific test scenario that instantiates the environment, configures the stimulus count, and coordinates the execution flow.
* **`tb_top.sv`**: The top-level static module. It generates the clock, instantiates the DUT and interface, and launches the class-based test.
* **`run.do`**: The Tcl execution script used to automate the compilation, simulation flow, and coverage reporting.

### 5. Architecture
       _________________________________________________________________
      |                            ENVIRONMENT                          |
      |  ________________      ________________      ________________   |
      | |   Generator    |    |   Scoreboard   |    |    Coverage    |  |
      | |________________|    |________________|    |________________|  |
      |         |                     ^                      ^          |
      |   (drv_mbx)               (scb_mbx)              (cov_mbx)      |
      |         v                     |                      |          |
      |  ________________      ______________________________________   |
      | |    Driver      |    |               Monitor                |  |
      | |________________|    |______________________________________|  |
      |__________|_____________________________^________________________|
                 |                             |
           ______v_____________________________|______
          |                                           |
          |                   DUT                     |
          |___________________________________________|

## Test Strategy & Constraints
The environment utilizes **Constrained-Random Verification (CRV)** coupled with an **Event-Driven Architecture** to explore the design space efficiently. The base test scenario generates sufficient transactions to ensure all bins in the cross-coverage model are thoroughly saturated.

* **Operand Range**: The 1-bit inputs (`a` and `b`) are randomized to hit all possible binary states (0 and 1).
* **Event Termination**: Hardcoded delays are eliminated. The testbench dynamically scales and terminates only when the Scoreboard triggers a `test_done` event after successfully evaluating all expected transactions.

## Coverage Report Summary
The verification environment achieved **100.00% Functional Coverage** (simulated via Riviera-PRO 2025.04). This confirms that every defined binary combination and cross-product was successfully exercised during the 170 ns simulation run.

**CUMULATIVE SUMMARY**
| Coverage Type | Weight | Hits/Total | Percentage |
| :--- | :--- | :--- | :--- |
| **Covergroup Coverage** | 1 | 1 / 1 | **100.000%** |

#### Detailed Bin Analysis
| Coverpoint / Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| **c_a** (Input A) | | | **Covered** |
| - bin one | 3 | 1 | Covered |
| - bin zero | 12 | 1 | Covered |
| **c_b** (Input B) | | | **Covered** |
| - bin one | 4 | 1 | Covered |
| - bin zero | 11 | 1 | Covered |

**Cross Coverage (`x_a_b`)**: 
Achieved 100% status by successfully hitting every mathematical combination of `{a, b}`, ensuring the complete arithmetic state space was tested.

| Cross Bin | Hits | Goal | Status |
| :--- | :--- | :--- | :--- |
| - bin `<one,one>` | 1 | 1 | Covered |
| - bin `<one,zero>` | 2 | 1 | Covered |
| - bin `<zero,one>` | 3 | 1 | Covered |
| - bin `<zero,zero>`| 9 | 1 | Covered |

## Prerequisites & Execution
This project is configured to run on standard SystemVerilog simulators (such as Siemens Questa, Synopsys VCS, Cadence Xcelium, or Aldec Riviera Pro). 

To execute the simulation directly via the browser:
1. Navigate to the [EDA Playground Workspace](https://www.edaplayground.com/x/L8PZ).
2. Ensure a SystemVerilog-compatible commercial simulator (e.g., Aldec Riviera Pro) is selected in the left-hand menu.
3. Click **Run**. The platform will automatically compile the design, execute the testbench, and gracefully terminate via the event trigger.
4. Review the console output upon completion to verify the Scoreboard pass/fail comparisons and review the final functional coverage metrics.
