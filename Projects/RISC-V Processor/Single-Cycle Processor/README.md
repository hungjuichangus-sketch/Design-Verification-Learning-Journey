# Single-Cycle RISC-V Processor (RV32I) on FPGA

A fully functional 32-bit Single-Cycle RISC-V processor implemented in Verilog on the **Terasic DE10-Lite (MAX10 FPGA)**. This core supports a subset of the RV32I instruction set and features a custom **Memory-Mapped UART** system for real-time bidirectional communication with a PC.

## 🧠 Architecture Overview

* **Type:** Single-Cycle (Harvard Architecture concepts with unified memory map simulation).
* **ISA:** RISC-V (RV32I Subset).
* **Clock Speed:** 50 MHz (System) / Manual Stepping (Debug).
* **I/O:** Memory-Mapped UART (Polling based).

## ⚡ Supported Instructions

The Control Unit and ALU currently support the following instructions:

| Type | Instructions | Description |
| :--- | :--- | :--- |
| **R-Type** | `add`, `sub`, `and`, `or`, `slt` | Arithmetic and Logic operations. |
| **I-Type** | `addi`, `slti`, `andi`, `ori` | Immediate arithmetic. |
| **Load** | `lw` | Load Word from Data Memory. |
| **Store** | `sw` | Store Word to Data Memory. |
| **Branch** | `beq` | Branch if Equal. |

## 🗺️ Memory Map & I/O

The processor interacts with the outside world using specific "Magic Addresses." Writing to or reading from these addresses triggers hardware events instead of RAM access.

| Address (Decimal) | Address (Hex) | Access | Function |
| :--- | :--- | :--- | :--- |
| **0 - 63** | `0x00` - `0x3F` | R/W | **Data RAM** (General Purpose Storage) |
| **84** | `0x54` | Write | **UART TX** (Send Char to PC) |
| **88** | `0x58` | Read | **UART RX** (Read Char from PC) |
| **92** | `0x5C` | Read | **UART Status Register** |

### Status Register (Address 92)
* **Bit 0:** `RX_READY` - 1 if a new character is waiting in the buffer. Clears automatically when Address 88 is read.

## 🛠 Hardware Setup

To use the UART features, an external USB-to-TTL adapter (or an Arduino in bypass mode) is required.

### Pin Mapping (DE10-Lite)
| Signal | FPGA Pin | Arduino Header Pin | Connection |
| :--- | :--- | :--- | :--- |
| **UART TX** | `PIN_AB5` | **IO[0]** | Connect to Adapter **RX** |
| **UART RX** | `PIN_AB6` | **IO[1]** | Connect to Adapter **TX** |
| **GND** | `GND` | **GND** | Common Ground |
| **CLK** | `PIN_P11` | N/A | 50MHz System Oscillator |
| **Reset** | `PIN_B8` | N/A | KEY[0] (Active Low) |
| **Step** | `PIN_A7` | N/A | KEY[1] (Manual CPU Clock - Optional) |

*(Note: If using an Arduino Uno as a bridge, connect RST to GND on the Arduino to bypass the Atmel chip.)*

## 💾 Demo Program: Case Swapping Echo Server

The included `InstructionMemory.v` contains a pre-loaded assembly program that demonstrates the I/O capabilities:

1.  **Polls** the Status Register (Addr 92) waiting for data.
2.  **Reads** a character from UART RX (Addr 88).
3.  **Checks** if the character is Lowercase ('a'-'z').
    * If Lowercase: Subtracts 32 to convert to Uppercase.
    * If Uppercase: Adds 32 to convert to Lowercase.
4.  **Writes** the result back to UART TX (Addr 84).

**To Run:**
1.  Open Serial Monitor (9600 Baud, No Line Ending).
2.  Type `A`. The FPGA responds `a`.
3.  Type `b`. The FPGA responds `B`.

## 🚀 Future Roadmap
* [ ] Pipeline the processor (5-Stage: IF, ID, EX, MEM, WB).
* [ ] Implement Hazard Detection and Forwarding Units.
* [ ] Add `jal` / `jalr` support for function calls.
* [ ] Integrate a custom Hardware Accelerator (Dot Product Engine).
