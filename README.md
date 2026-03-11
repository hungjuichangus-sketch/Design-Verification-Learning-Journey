# Welcome to My FPGA Portfolio! 👋

Hi there! I’m an aspiring hardware engineer, and this repository serves as a curated gallery of my **FPGA and Digital Logic Design** projects. My work focuses on RTL design using Verilog/SystemVerilog, hardware-software integration, and computer architecture.

Whether you are a recruiter or a fellow engineer, feel free to explore the source code, testbenches, and documentation for each project below.

---

## 🛠 Project Highlights

### 🚀 RISC-V Processor (Pipelined & Single-Cycle)
Developed two versions of a RISC-V (RV32I) processor to understand the trade-offs between architectural simplicity and throughput.
* **Single-Cycle:** Implemented the full data path and control logic to execute instructions in a single clock cycle.
* **Pipelined:** Designed a 5-stage pipeline (Fetch, Decode, Execute, Memory, Write-back) featuring hazard detection units and data forwarding logic to maximize frequency.



### 🛰 ADXL345 I2C Accelerometer Controller
A hardware-level controller designed to interface with the ADXL345 digital accelerometer via the I2C protocol.
* Implemented a custom **I2C Master Controller** state machine.
* Handles device initialization, register configuration, and real-time processing of X, Y, and Z-axis data.

### ⏱ Precision Reflex Timer
A high-accuracy digital timer designed to measure and display human reaction time.
* Uses high-frequency counters and debounced tactile switch inputs for millisecond precision.
* Features a state machine to manage "Wait," "Trigger," and "Result" states, displaying data on 7-segment displays.

### 🔢 Bulls and Cows (Logic Game)
A hardware implementation of the classic code-breaking game, emphasizing complex FSM design.
* Features a pseudo-random number generator (LFSR) to create a secret code.
* Includes comparison logic to calculate "Bulls" (correct digit/position) and "Cows" (correct digit/wrong position) in real-time.

### 🔒 Digital Combinational Lock
A secure entry system designed with robust input validation.
* Implements a multi-digit sequence detector using an FSM.
* Features programmable passkeys and a "lock-out" mechanism to handle incorrect attempts securely.

---

## ⚙️ Tools & Technologies
* **Languages:** Verilog, SystemVerilog
* **FPGA Hardware:** Intel DE10-Lite
* **EDA Tools:** Quartus Prime

## 📫 Contact Me
I am actively seeking opportunities in RTL Design and Hardware Engineering. 
* **LinkedIn:** https://www.linkedin.com/in/hung-jui-chang-5b755a312/
* **Email:** HungJuiChang.us@gmail.com

---
*Created with by Hung*