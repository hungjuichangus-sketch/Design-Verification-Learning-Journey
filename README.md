# Welcome to My Design Verification (DV) & RTL Portfolio! 👋

Hi there! I’m an aspiring **ASIC/IC Design Verification Engineer** with a strong foundation in digital logic and FPGA design. This repository serves as a curated gallery of my journey into the world of hardware verification. 

My current focus is on building robust testbenches using **SystemVerilog (OOP, Constraints, SVA)**, mastering **UVM** methodologies, and developing deep architectural intuition to verify complex digital systems.

---

## 🎯 Verification Projects (SystemVerilog & UVM)
*Currently building out pure SV and UVM environments to verify core hardware components.*

### 📦 Synchronous FIFO & Verification Environment
Designed and verified a parameterizable Synchronous FIFO, a critical component for data buffering and clock domain crossing mitigation.
* **RTL:** Implemented circular buffer logic with wrap-around bit (N+1 pointer) architecture for exact Full/Empty flag generation.
* **Verification:** Developed a SystemVerilog testbench focusing on constrained-random testing, concurrent read/write scenarios, and corner-case error injection (overflow/underflow).

### ⚖️ Round Robin Arbiter (Priority Masking)
Designed a hardware arbiter to manage shared bus access across multiple agents without starvation.
* **RTL:** Implemented the "Masking Trick" and Two's Complement fixed-priority engine (`req & -req`) for highly optimized, combinational round-robin rotation.

### ⏱️ High-Frequency Interview Modules & CDC
A collection of industry-standard whiteboarding modules used to solidify Clock Domain Crossing (CDC) and timing concepts.
* **Clock Dividers:** Implemented even and odd clock dividers, including a Divide-by-3 with a perfect **50% duty cycle** utilizing both `posedge` and `negedge` logic.
* **Sequence Detectors:** Designed overlapping Moore and Mealy FSMs to detect continuous serial streams (e.g., `1101`).

---

## 🛠 RTL Design & Architecture Foundations
*My previous FPGA projects that demonstrate my understanding of computer architecture and hardware-software integration—essential knowledge for any DV engineer.*

### 🚀 RISC-V Processor (Pipelined & Single-Cycle)
Developed two versions of a RISC-V (RV32I) processor to understand the trade-offs between architectural simplicity and throughput.
* **Single-Cycle:** Implemented the full data path and control logic to execute instructions in a single clock cycle.
* **Pipelined:** Designed a 5-stage pipeline (Fetch, Decode, Execute, Memory, Write-back) featuring hazard detection units and data forwarding logic to maximize frequency.

### 🛰 ADXL345 I2C Accelerometer Controller
A hardware-level controller designed to interface with the ADXL345 digital accelerometer via the I2C protocol.
* Implemented a custom **I2C Master Controller** state machine.
* Deepened protocol-level understanding, which is highly applicable to creating Verification IPs (VIPs).

### ⏱ Precision Reflex Timer & Digital Combinational Lock
* **Timer:** High-accuracy digital timer measuring human reaction time using debounced tactile switches and multi-state FSMs.
* **Digital Lock:** Secure entry system featuring multi-digit sequence detection and programmable passkeys.

---

## ⚙️ Skills & Technologies

* **Verification Languages:** SystemVerilog (OOP, Randomization, Coverage, SVA), UVM (In Progress)
* **Design Languages:** Verilog-2001, SystemVerilog
* **Core Concepts:** Object-Oriented Programming, Clock Domain Crossing (CDC), Setup/Hold Timing Analysis, Cache Coherency, AMBA Protocols (AXI/APB basics)
* **Software & Scripting:** C/C++, Python, Linux/Unix Command Line, Makefile
* **EDA Tools:** Metrics DSim, ModelSim / Questa, EDA Playground, Quartus Prime

---

## 📫 Contact Me
I am actively seeking full-time opportunities in **ASIC Design Verification** and **RTL Design**. Let's connect!

* **LinkedIn:** https://www.linkedin.com/in/hung-jui-chang-5b755a312/
* **Email:** HungJuiChang.us@gmail.com

---
*Created by Hung*
