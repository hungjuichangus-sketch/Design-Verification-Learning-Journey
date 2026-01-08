# FPGA-Learning-Journey
Verilog modules and FPGA projects developed on DE10-Lite board.
🚀 Project Overview
[Day 01] Clock Divider & BCD Counter
Objective: Understand hardware parallelism and basic timing control.

Key Concepts:

Frequency division (50MHz to 1Hz).

Non-blocking assignments (<=) for sequential logic.

Cascaded BCD (Binary Coded Decimal) counter architecture (00-59).

Hardware Used: On-board 50MHz Oscillator, 7-Segment Displays (HEX0-HEX1).

[Day 02] FSM & Button Debouncing
Objective: Manage complex system states and handle noisy external inputs.

Key Concepts:

3-Always Block FSM: Clean separation of State Register, Next State Logic, and Output/Datapath.

Button Debouncer: Filtering mechanical "chatter" using a 20ms blanking window.

Synchronous Edge Detection: Implementing a pulse generator to ensure single-cycle increments.

Hardware Used: Push Buttons (KEY0-KEY1), 7-Segment Displays.

🛠️ Development Environment
FPGA Hardware: Intel MAX 10 (10M50DAF484C7G)

IDE: Intel Quartus Prime (Lite Edition)

Language: Verilog HDL

Hardware Documentation: DE10-Lite User Manual
