FPGA & Verilog Learning Journey (DE10-Lite)This repository documents my progress in learning FPGA development and Verilog HDL. All projects are implemented using the Terasic DE10-Lite (Intel MAX 10 FPGA) development board.🚀 Project Overview[Day 01] Clock Divider & BCD CounterObjective: Understand hardware parallelism and basic timing control.Key Concepts:Frequency division (50MHz to 1Hz).Non-blocking assignments (<=) for sequential logic.Cascaded BCD (Binary Coded Decimal) counter architecture (00-59).Hardware Used: On-board 50MHz Oscillator, 7-Segment Displays (HEX0-HEX1).[Day 02] FSM & Button DebouncingObjective: Manage complex system states and handle noisy external inputs.Key Concepts:3-Always Block FSM: Clean separation of State Register, Next State Logic, and Output/Datapath.Button Debouncer: Filtering mechanical "chatter" using a 20ms blanking window.Synchronous Edge Detection: Implementing a pulse generator to ensure single-cycle increments.Hardware Used: Push Buttons (KEY0-KEY1), 7-Segment Displays.🛠️ Development EnvironmentFPGA Hardware: Intel MAX 10 (10M50DAF484C7G)IDE: Intel Quartus Prime (Lite Edition)Language: Verilog HDLHardware Documentation: DE10-Lite User Manual📂 Repository Structure.
├── Day01/
│   ├── ClockDivider.v      # 50MHz to 1Hz divider
│   ├── Counter_00_59.v     # Dual-digit BCD counter logic
│   └── HexDigit.v          # 7-segment decoder (Shared module)
├── Day02/
│   ├── Debouncer.v         # Finite State Machine for debouncing
└── README.md
📈 Future Goals[ ] Day 03: UART Communication (Serial TX/RX)[ ] Day 04: VGA Controller (Video Signal Generation)[ ] Day 05: SPI/I2C Sensor Integration (Accelerometer)
