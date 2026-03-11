# DE10-Lite ADXL345 I2C Accelerometer Controller

## Overview
This repository contains a complete, bare-metal Verilog implementation of an I2C controller designed for the Terasic DE10-Lite (Intel MAX 10 FPGA). It continuously reads X, Y, and Z-axis gravity data from the onboard ADXL345 accelerometer and displays the real-time values on the board's 7-segment HEX displays.

## System Architecture
The design is fundamentally split into control path and datapath modules, handling everything from the physical open-drain bus to synchronous memory routing:

* **Top-Level Manager:** A Finite State Machine (FSM) that orchestrates the boot-up configuration of the ADXL345 and continuously polls the sensor's registers for axis data.
* **Custom I2C Controller:** A from-scratch I2C Master featuring a 50MHz to 100kHz clock divider, open-drain SDA line management, multi-byte payloads, and standard Write/Read/Repeated-Start sequences.
* **Synchronous FIFO Buffer:** An M9K memory block implementation that buffers the incoming 16-bit words retrieved by the I2C Worker.
* **Datapath Router (Demultiplexer):** A custom FSM that monitors the FIFO's `empty` flag, safely handles the 1-cycle synchronous read latency, and routes the packetized data stream into dedicated X, Y, and Z registers.
* **Axis Display Drivers:** Decodes the raw 16-bit axis data into human-readable formats on the physical 7-segment displays.

## Key Takeaways & Lessons Learned
* **I2C Protocol Implementation:** Deepened my understanding of the I2C specification by building a controller from absolute scratch. Successfully managed edge cases like Repeated Starts (for Write-then-Read operations), open-drain High-Z bus floating, and physical STOP condition requirements.
* **On-Chip Debugging with SignalTap:** Extensively utilized the Quartus SignalTap Logic Analyzer to debug state machine routing and waveform timing. Gained practical experience distinguishing between Pre-Synthesis logical simulations and Post-Fitting physical register inversions.
* **Data Rate Matching & Buffering:** Implemented a synchronous FIFO pipeline to safely manage the massive speed differential between the 50MHz FPGA fabric and the 100kHz I2C bus, ensuring no data was dropped or overwritten during sensor polling.
* **FSM Demultiplexing:** Designed a custom router state machine to read packetized (X, Y, Z) data from the FIFO, handling the inherent 1-clock-cycle read latency of synchronous M9K memory blocks without skewing the data.

## Hardware Requirements
* Terasic DE10-Lite Board (Intel MAX 10 FPGA: 10M50DAF484C7G)
* Quartus Prime (Lite/Standard Edition)

## How to Run
1. Open the project in Quartus Prime.
2. Compile the design and ensure pin assignments match the DE10-Lite user manual.
3. Program the FPGA via the onboard USB-Blaster.
4. Flip `SW[0]` UP to wake the ADXL345 sensor and begin the I2C transactions.
5. Tilt the board along its axes to watch the real-time gravity data change on the HEX displays.
