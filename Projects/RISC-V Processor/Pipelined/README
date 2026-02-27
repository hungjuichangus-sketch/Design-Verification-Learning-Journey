# **5-Stage Pipelined RISC-V Processor (RV32IM)**

## **Overview**

This repository contains the RTL (Verilog) implementation of a custom 32-bit RISC-V processor. It features a full 5-stage pipeline, a custom Hazard Unit for data forwarding and stall management, and hardware support for the 'M' extension (hardware multiplier). The processor was designed and tested on the **Terasic DE10-Lite (Intel MAX 10 FPGA)**.

This CPU core serves as the foundational Intellectual Property (IP) for my Master's Thesis: *Hardware-in-the-Loop Acceleration for AI-Driven Traffic Control*.

## **Key Features**

* **Architecture:** RISC-V RV32IM (32-bit integer base \+ hardware multiplication).  
* **5-Stage Pipeline:** Instruction Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Writeback (WB).  
* **Hazard Management:** Full forwarding paths to resolve Data Hazards and stalling logic to handle load-use delays and Control Hazards (branching).  
* **Memory-Mapped I/O:** \* Custom UART Transmitter (Tx) and Receiver (Rx) with status registers.  
  * Hardware LED register decoding.  
* **Timing Performance:** Achieved Fmax \> 140 MHz via Quartus Static Timing Analysis (STA) on the Cyclone V / MAX 10 architecture.  
* **Software Toolchain:** Fully capable of executing bare-metal C code compiled via riscv64-unknown-elf-gcc.

## **Project Structure**

* ALU.v / ControlUnit.v \- Core execution and instruction decoding logic.  
* HazardUnit.v \- Pipeline dependency resolution (Forwarding and Stalls).  
* RegisterFile.v \- 32x32-bit CPU registers.  
* ProgramCounter.v / PCAdder.v / PCTarget.v \- Instruction fetching and branch calculation.  
* Pipe\_\*.v \- Pipeline registers separating the 5 CPU stages.  
* UartTx.v / UartRx.v \- Serial communication hardware modules.  
* InstructionMemory.v / DataMemory.v \- ROM and RAM blocks.  
* Top.v \- The Top-Level module integrating the CPU and Memory-Mapped I/O to the FPGA pins.

## **Toolchain & Compilation**

This processor does not require hand-written assembly; it runs standard C firmware. The workflow utilizes a bare-metal GCC toolchain:

1. **main.c**: The application logic (utilizing volatile pointers for memory-mapped I/O).  
2. **boot.s**: Assembly bootloader to initialize the Stack Pointer (sp) and jump to main().  
3. **link.ld**: Linker script mapping instructions to ROM and variables to RAM.  
4. **convert.py**: Python script to convert the compiled .bin into the 32-bit Hex format required by Verilog's $readmemh.

## **Future Roadmap**

This standalone CPU core is the first phase of a larger project. It will be instantiated as the central orchestrator in the upcoming NPBSC\_SoC (Network Priority-Based Signal Controller) project. The future SoC will integrate a custom INT8 Matrix-Vector Multiplication Hardware Accelerator onto the RISC-V memory bus to perform real-time neural network inference for urban traffic coordination.
