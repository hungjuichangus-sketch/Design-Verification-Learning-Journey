# **5-Stage Pipelined RISC-V Processor (RV32IM)**

## **Overview**

This repository contains the RTL (Verilog) implementation of a custom 32-bit RISC-V processor. It features a full 5-stage pipeline, comprehensive hazard management (both data forwarding and pipeline stalling/flushing), and hardware support for the 'M' extension (hardware multiplier). The processor was designed and tested on the **Terasic DE10-Lite (Intel MAX 10 FPGA)**.

This CPU core serves as the foundational Intellectual Property (IP) for my Master's Thesis: *Hardware-in-the-Loop Acceleration for AI-Driven Traffic Control*.

## **Key Features**

* **Architecture:** RISC-V RV32IM (32-bit integer base \+ hardware multiplication).  
* **5-Stage Pipeline:** Instruction Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Writeback (WB).  
* **Hazard Management:** \* HazardUnit: Full forwarding paths to resolve Data Hazards without stalling.  
  * HazardDetectionUnit: Stall and flush logic to handle load-use delays and Control Hazards (branching).  
* **Memory-Mapped I/O:** \* Custom UART Transmitter (Tx) and Receiver (Rx) with status registers for serial communication.  
  * Hardware LED register decoding for physical debugging.  
* **Timing Performance:** Achieved Fmax \> 140 MHz via Quartus Static Timing Analysis (STA) on the Cyclone V / MAX 10 architecture.

## **Project Structure**

* DE10\_LITE\_Golden\_Top.v \- The Top-Level module integrating the CPU pipeline and Memory-Mapped I/O to the FPGA pins.  
* ALU.v / ControlUnit.v / Extend.v / Mux2.v \- Core execution, instruction decoding, and data routing logic.  
* HazardUnit.v / HazardDetectionUnit.v \- Pipeline dependency resolution (Forwarding, Stalls, and Flushes).  
* RegisterFile.v \- 32x32-bit CPU registers.  
* ProgramCounter.v / PCAdder.v / PCTarget.v \- Instruction fetching and branch calculation.  
* Pipe\_IF\_ID.v, Pipe\_ID\_EX.v, Pipe\_EX\_MEM.v, Pipe\_MEM\_WB.v \- Pipeline registers separating the 5 CPU stages.  
* UartTx.v / UartRx.v \- Serial communication hardware modules.  
* InstructionMemory.v / DataMemory.v \- ROM and RAM blocks.

## **Programming the CPU (Baseline Version)**

This baseline version of the processor operates via hand-coded machine language. There is no software toolchain attached to this specific repository. Instructions are manually translated into 32-bit Hex format and loaded directly into the InstructionMemory.v module, which initializes the ROM using the Verilog $readmemh function.

## **Future Roadmap**

This standalone CPU core is the first phase of a larger project. It will be instantiated as the central orchestrator in the upcoming NPBSC\_SoC (Network Priority-Based Signal Controller) project. The future SoC will feature a full GCC C-Compiler toolchain and integrate a custom INT8 Matrix-Vector Multiplication Hardware Accelerator onto the RISC-V memory bus to perform real-time neural network inference for urban traffic coordination.
