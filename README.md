# **Welcome to My Design Verification (DV) & RTL Portfolio\! 👋**

Hi there\! I’m an aspiring **ASIC/IC Design Verification Engineer** with a strong foundation in digital logic and FPGA design. This repository serves as a curated gallery of my journey into the world of hardware verification.

My current focus is on building robust testbenches using **SystemVerilog (OOP, Constraints, SVA)**, mastering **UVM** methodologies, and developing deep architectural intuition to verify complex digital systems.

## **🎯 Verification Projects (SystemVerilog & UVM)**

*Currently building out pure SV and UVM environments to verify core hardware components.*

### **💾 Register Space Verification Environment**

Designed a layered, class-based SystemVerilog verification environment for a register design, separating stimulus generation, pin-level driving, and monitoring into distinct, scalable components.

* **Key Features:** Utilized **Constrained-Random Verification (CRV)** with distribution constraints to balance read/write traffic. Successfully reconstructed physical pin-level signaling back into Transaction-Level Models (TLMs) in the monitor and achieved **100% Functional Coverage** across all targeted address banks and operation cross-products.

### **⚖️ Round Robin Arbiter (Priority Masking)**

Designed a hardware arbiter to manage shared bus access across multiple agents without starvation.

* **RTL:** Implemented the "Masking Trick" and Two's Complement fixed-priority engine (req & \-req) for highly optimized, combinational round-robin rotation.

### **⏱️ High-Frequency Interview Modules & CDC**

A collection of industry-standard whiteboarding modules used to solidify Clock Domain Crossing (CDC) and timing concepts.

* **Clock Dividers:** Implemented even and odd clock dividers, including a Divide-by-3 with a perfect **50% duty cycle**.  
* **Sequence Detectors:** Designed overlapping Moore and Mealy FSMs to detect serial streams (e.g., 1101).

## **🏗️ Featured UVM Testbenches**

### **1\. Synchronous Adder UVM Environment**

**Overview:** A complete, class-based UVM testbench transitioning from a custom layered architecture to a standard UVM factory-based environment.

#### **Architecture & File Structure**

* **my\_adder.sv**: RTL implementation with synchronous reset.  
* **add\_if.sv**: Interface with clocking blocks for strict setup/hold enforcement.  
* **add\_item.sv**: Transaction class (uvm\_sequence\_item) with arithmetic randomization.  
* **driver.sv**: Translates high-level transactions into pin-level signaling via seq\_item\_port.  
* **monitor.sv**: Passive component broadcasting reconstructed transactions via uvm\_analysis\_port.  
* **scoreboard.sv**: Mathematically verifies and coordinates termination.  
* **coverage.sv**: Implements covergroups ensuring 100% functional coverage of the arithmetic state space.

#### **Architecture Diagram**

         ___________________________________________________________________
       |                           ENVIRONMENT                              |
       |   _______________                                                  |
       |  |               |                                                 |
       |  |  add_sequence |                                                 |
       |  |_______________|                                                 |
       |            |                                                       |
       |  __________V_______       ________________      ________________   |
       | |                  |     |                |    |                |  |
       | |  uvm_sequencer   |     |  Scoreboard    |    |   Coverage     |  |
       | |__________________|     |________________|    |________________|  |
       |            |                      ^                      ^         |
       | (seq_item_port/export)            | (ap_imp)             | (ap_imp)|
       |  __________V_______       ________|______________________|_______  |
       | |                  |     |                                      |  |
       | |      Driver      |     |                Monitor               |  |
       | |__________________|     |______________________________________|  |
       |__________|_________________________________^_______________________|
                  |                                 |
            ______V_________________________________|______
           |                       DUT                     |
           |_______________________________________________|


#### **Coverage Report Summary**

* **Cumulative:** **100.00% Functional Coverage**  
* **Cross Coverage (x\_a\_b):** Successfully hit all combinations of 1-bit inputs a and b.

### **2\. Full-Duplex UART Transceiver UVM Environment**

**Overview:** A class-based UVM environment for a UART system, decoupling software TB from hardware using synchronous FIFOs and edge-detection synchronization.

#### **Architecture & File Structure**

* **uart\_top.sv**: Static top module instantiating the UVM interface and FIFO-bridged DUT.  
* **uart\_pkg.sv**: Manages strict top-down compilation of the UVM components.  
* **uart\_seq\_item.sv**: Defines 8-bit payload and transmit\_delay with weighted dist constraints.  
* **tx\_agent.sv & rx\_agent.sv**: Containers for drivers, sequencers, and monitors.  
* **uart\_scoreboard.sv**: Uses TLM analysis FIFOs to compare Tx vs. Rx traffic.  
* **uart\_coverage.sv**: Subscriber class tracking payload distribution and stimulus delays.

#### **Architecture Diagram**

       ___________________________________________________________________________
       |                               ENVIRONMENT                               |
       |  _________________                          _________________           |
       | |                 |                        |                 |          |
       | |    tx_agent     |                        |    rx_agent     |          |
       | |  _____________  |       ___________      |  _____________  |          |
       | | |             | |      |           |     | |             | |          |
       | | |  Sequencer  | |      | Scoreboard|     | |  Sequencer  | |          |
       | | |_____________| |      |___________|     | |_____________| |          |
       | |     |     ^     |        ^       ^       |     |     ^     |          |
       | |  ___V_____|___  |        |       |       |  ___V_____|___  |          |
       | | |             | |        |       |       | |             | |          |
       | | |   Driver    |-|----.   |       |       | |   Driver    | |          |
       | | |_____________| |    |   |       |       | |_____________| |          |
       | |  _____________  |    |   |       |       |  _____________  |          |
       | | |             | |    |   |       |       | |             | |          |
       | | | Monitor (Tx)|-|----|--´        `-------|-| Monitor (Rx)| |          |
       | | |_____________| |    |                   | |_____________| |          |
       | |_________________|    |    __________     |_________________|          |
       |                        |   |          |                                 |
       |                        `-->| Coverage |                                 |
       |                            |__________|                                 |
       |_________________________________________________________________________|
               | (UVM writes)                        ^ (UVM reads)
         ______V_______                        ______|_______
        |              |                      |              |
        |   TX FIFO    |                      |   RX FIFO    |
        |______________|                      |______________|

#### **Test Strategy & Constraints**

* **Distribution Shaping:** 20% of traffic forced to 8'h00 and 8'hFF. 60% uses 0 delay to test back-to-back FIFO pressure.  
* **Full-Duplex:** run\_phase triggers parallel Tx/Rx sequences in a fork...join block.  
* **Results:** Achieved **100.00% Coverage** across all payload and delay bins.

## **🛠 RTL Design & Architecture Foundations**

*Essential computer architecture knowledge for hardware engineering.*

### **🚀 RISC-V Processor (Pipelined & Single-Cycle)**

Developed two versions of a RISC-V (RV32I) processor to explore architectural trade-offs.

* **Single-Cycle:** Implemented full data path and control logic for single-cycle execution.  
* **Pipelined:** Designed a 5-stage pipeline featuring hazard detection units and data forwarding logic.

### **🛰️ ADXL345 I2C Accelerometer Controller**

* Implemented a custom **I2C Master Controller** state machine.  
* Deepened protocol-level understanding applicable to creating Verification IPs (VIPs).

## **⚙️ Skills & Technologies**

* **Verification:** SystemVerilog (OOP, Randomization, Coverage, SVA), UVM (Factory, Phasing, TLM, Sequences).  
* **Design:** Verilog-2001, SystemVerilog RTL, FSM Design.  
* **Core Concepts:** CDC, Setup/Hold Timing.  
* **Software:** C/C++, Python, Linux/Unix Shell, Makefile.  
* **EDA Tools:** Metrics DSim, ModelSim/Questa, EDA Playground, Vivado/Quartus.

## **📫 Contact Me**

I am actively seeking full-time opportunities in **ASIC Design Verification** and **RTL Design**.

* **LinkedIn:** [My Profile](https://www.linkedin.com/in/hung-jui-chang-5b755a312/)  
* **Email:** HungJuiChang.us@gmail.com

*Created by Hung*
