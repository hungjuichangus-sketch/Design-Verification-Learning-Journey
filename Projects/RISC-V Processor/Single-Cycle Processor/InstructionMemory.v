module InstructionMemory(
    input  [31:0] A,      // Address (PC)
    output [31:0] RD      // Read Data (Instruction)
);

    reg [31:0] RAM [63:0];

    initial begin
        // ----------------------------------------------------------------
        // CASE SWAPPING ECHO SERVER (CORRECTED HEX)
        // A -> a, a -> A
        // ----------------------------------------------------------------
        
        // 0. Poll Status (Addr 92)
        // lw x2, 92(x0)
        RAM[0] = 32'h05c02103; 

        // 1. Wait Loop
        // beq x2, x0, -4
        RAM[1] = 32'hfe010ce3;

        // 2. Read Data (Addr 88) -> x1
        // lw x1, 88(x0)
        RAM[2] = 32'h05802083; 

        // 3. Check if Uppercase (Is x1 < 97?)
        // slti x2, x1, 97
        RAM[3] = 32'h0610A113;

        // 4. Branch Logic
        // If x2 == 0 (It is NOT < 97, so it is Lower), Jump to LOWER logic.
        // beq x2, x0, 12 -> Correct Hex: 00010663
        RAM[4] = 32'h00010663;

        // 5. UPPER Logic (It was < 97)
        // Convert to Lower: Add 32
        // addi x1, x1, 32
        RAM[5] = 32'h02008093;

        // 6. Jump to SEND (Skip LOWER logic)
        // beq x0, x0, 8 -> FIXED HEX (Was 00800063)
        RAM[6] = 32'h00000463;

        // 7. LOWER Logic (It was >= 97)
        // Convert to Upper: Add -32
        // addi x1, x1, -32
        RAM[7] = 32'hFE008093;

        // 8. SEND (Addr 84)
        // sw x1, 84(x0)
        RAM[8] = 32'h04102A23; 

        // 9. Loop back to start
        // beq x0, x0, -36 -> FIXED HEX (Was DC000EE3)
        RAM[9] = 32'hFD000EE3;
        
        // Padding
        RAM[10] = 32'h00000013;
    end

    // Read Logic (Word Aligned)
    assign RD = RAM[A[31:2]];

endmodule