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

## Key Hardware Concepts Demonstrated
* **Repeated Start Implementation:** Accurately executes the precise I2C "Write-then-Read" sequence required to set a sensor's internal pointer and fetch data without releasing the bus.
* **Bus Free Time Management:** Includes dedicated FSM wait states to ensure physical pull-up resistors have time to stabilize the bus between STOP and START conditions.
* **Clock Domain & Latency Handling:** Successfully bridges the slow 100kHz I2C bus domain with the fast 50MHz FPGA fabric, utilizing state-driven pipeline alignment to prevent data skew.

## Hardware Requirements
* Terasic DE10-Lite Board (Intel MAX 10 FPGA: 10M50DAF484C7G)
* Quartus Prime (Lite/Standard Edition)

## How to Run
1. Open the project in Quartus Prime.
2. Compile the design and ensure pin assignments match the DE10-Lite user manual.
3. Program the FPGA via the onboard USB-Blaster.
4. Flip `SW[0]` UP to wake the ADXL345 sensor and begin the I2C transactions.
5. Tilt the board along its axes to watch the real-time gravity data change on the HEX displays.
