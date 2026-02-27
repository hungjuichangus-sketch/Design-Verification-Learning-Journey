module InstructionMemory(
    input  [31:0] A,      // Address (PC)
    output [31:0] RD      // Read Data (Instruction)
);

    reg [31:0] RAM [63:0];

    initial begin
		// addi x1, x0, 5    (Load 5 into x1)
		RAM[0] = 32'h00500093; 
		
		// addi x2, x0, 7    (Load 7 into x2)
		RAM[1] = 32'h00700113; 
		
		// mul x3, x1, x2    (Multiply x1 * x2, store in x3)
		// 0000001_00010_00001_000_00011_0110011 = 022081B3
		RAM[2] = 32'h022081B3; 
	
		// beq x0, x0, 0     (Infinite Stop Loop)
		RAM[3] = 32'h00000063;
//		// ----------------------------------------------------------------
//        // CASE SWAPPING ECHO SERVER
//        // A -> a, a -> A
//        // ----------------------------------------------------------------
//		// 0. Poll Status (Addr 92) -> x2
//        RAM[0] = 32'h05c02103; 
//
//        // 1. NOP (Load-Use Delay)
//        // ESSENTIAL: Gives 'lw' time to reach Writeback stage so 'beq' gets real data.
//        RAM[1] = 32'h00000013; 
//
//        // 2. Branch if Empty (beq x2, x0, -8)
//        // Jump back to 0. Offset -8 bytes (skip NOP and lw).
//        // Hex: fe010ce3
//        RAM[2] = 32'hfe010ce3; 
//
//        // 3. Read Data (Addr 88) -> x1
//        RAM[3] = 32'h05802083; 
//
//        // 4. NOP (Load-Use Delay for x1)
//        RAM[4] = 32'h00000013;
//
//        // 5. Check if Uppercase (Is x1 < 97?)
//        // slti x2, x1, 97
//        RAM[5] = 32'h0610A113;
//
//        // 6. Branch Logic (beq x2, x0, 12) -> Jump to LOWER
//        RAM[6] = 32'h00010663;
//
//        // 7. UPPER Logic (addi x1, x1, 32)
//        RAM[7] = 32'h02008093;
//
//        // 8. Jump to SEND (beq x0, x0, 8)
//        RAM[8] = 32'h00000463;
//
//        // 9. LOWER Logic (addi x1, x1, -32)
//        RAM[9] = 32'hFE008093;
//
//        // 10. SEND (sw x1, 84(x0))
//        RAM[10] = 32'h04102A23; 
//
//        // 11. Loop back to start (beq x0, x0, -44)
//        // -44 decimal = 0xFFFFFFD4
//        // Imm[12|10:5|4:1|11] -> 1 | 111110 | 1010 | 1
//        // Hex: 1111 1101 0101 -> fd500ee3
//        RAM[11] = 32'hfc000ae3;
//        
//        // Padding
//        RAM[12] = 32'h00000013;
        
    end

    // Read Logic (Word Aligned)
    assign RD = RAM[A[31:2]];

endmodule