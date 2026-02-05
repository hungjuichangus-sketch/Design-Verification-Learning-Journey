FPGA Bulls & Cows (Number Guessing Game)

A fully functional "Bulls and Cows" number guessing game implemented in Verilog on the Terasic DE10-Lite (MAX10 FPGA). The system features a pseudo-random number generator, a history tracking system, and a custom state machine logic to handle user input and scoring.

🎮 Game Rules

The system generates a random 4-digit number (0-9) with no repeating digits.
The player attempts to guess the number. After every 4-digit guess, the system provides feedback:

A (Bulls): The digit is correct AND in the correct position.

B (Cows): The digit exists in the secret number but is in the wrong position.

Example:

Secret Answer: 1234

Player Guess: 1042

Result: 1A 2B (1 is 'A', 4 and 2 are 'B')

🛠 Hardware & Controls

This project is designed for the DE10-Lite board.

Inputs

Component

Function

KEY

$$0$$



System Reset (Active Low). Resets game, score, and history.

KEY

$$1$$



Enter / Confirm. Press to confirm the digit selected on the switches.

SW

$$3:0$$



Digit Input. Set binary value (0-9) for the current digit guess.

SW

$$7:4$$



History Select. View previous guesses (Index 0 = 1st guess, Index 1 = 2nd...).

SW

$$8$$



Debug Mode. Toggle ON to reveal the secret answer on the display.

SW

$$9$$



Clear. Toggle to clear the current input if you made a mistake typing.

Outputs

Component

Function

HEX 3-0

Displays the current 4-digit input OR the history playback.

HEX 5-4

Displays the Score. HEX5 = 'A' count, HEX4 = 'B' count.

LEDR

$$9:0$$



Game Progress. LEDs light up sequentially to track how many attempts used.

🏗 Technical Architecture

The design is modular, separating the logic, state management, and storage.

1. Pseudo-Random Number Generator (PRNG)

Uses a 16-bit free-running LFSR (Linear Feedback Shift Register).

Seeding is based on human timing uncertainty (the exact millisecond the player presses Start).

Rejection Sampling: The state machine ensures the generated 4-digit code contains no duplicate numbers and all digits are ≤ 9.

2. Main FSM (Finite State Machine)

The core controller manages the game states:

S_WAIT_ANS: Waits for valid random number generation.

S_WAIT_D0 - S_WAIT_D3: Input sequence for the 4 digits.

S_CHECK: Compares the input registers against the answer registers to calculate A and B scores using combinational logic.

S_FAIL / S_PASS: Updates game status and writes to memory.

3. Guess History (Memory)

Implemented as a Dual-Port RAM / Register File.

Allows the game to write the current result (Synchronous) while the player simultaneously reads past history using SW[7:4] (Asynchronous).

4. Debouncer

Filters mechanical noise from the push buttons (KEY) to prevent double-triggering inputs.

🚀 How to Run

Open the project in Intel Quartus Prime.

Assign pins according to the DE10-Lite User Manual (or import the .qsf file).

Compile the project.

Program the .sof file to the DE10-Lite board via USB-Blaster.

📸 Demo

(Add a photo or GIF of your board working here!)
