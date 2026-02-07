module ControlUnit(
    input [6:0] Opcode,		// Instr[6:0]
    input [2:0] Funct3,		// Instr[14:12]
    input Funct7b5,   		// Instr[30]
    input Zero,       		// From ALU
    output PCSrc,      		// 0: PC+4, 1: PCTarget
    output reg ResultSrc,  // 0: ALU, 1: Memory
    output reg MemWrite,   // Data Memory Write Enable
    output reg ALUSrc,     // 0: RegB, 1: Imm
    output reg[1:0] ImmSrc,// 00:I, 01:S, 10:B, 11:J
    output reg RegWrite,   // Register File Write Enable
    output reg[2:0] ALUControl
);
	reg [1:0] ALUOp; // Internal: 00=Add(lw/sw), 01=Sub(beq), 10=R-type
	reg       Branch; // Internal: 1 if it's a branch instruction
	
   // ========================================================================
   // 1. MAIN DECODER
   //    Sets the "Policy" for the instruction type.
	// ========================================================================
	always @(*)begin
		// Defaults to prevent latches
		RegWrite = 0; ImmSrc = 0; ALUSrc = 0; MemWrite = 0; 
      ResultSrc = 0; Branch = 0; ALUOp = 0;
		
		case(Opcode)
			// lw (Load Word) I-Type
			7'b0000011: begin
				RegWrite  = 1'b1;      // Write data back to register
				ImmSrc    = 2'b00;     // I-Type Immediate
				ALUSrc    = 1'b1;      // Operand B comes from Immediate
				MemWrite  = 1'b0;      // Not writing to memory
				ResultSrc = 1'b1;      // Result comes from Memory
				Branch    = 1'b0;      // Not a branch
				ALUOp     = 2'b00;     // ALUOp 00 forces ADD (Address calc)
			end
			// sw (Store Word) S-Type
			7'b0100011: begin
				RegWrite  = 1'b0;      // Stores don't write to Register File
				ImmSrc    = 2'b01;     // S-Type Immediate (Split immediate)
				ALUSrc    = 1'b1;      // Address = Reg + Imm
				MemWrite  = 1'b1;      // Write to Data Memory
				ResultSrc = 1'bx;      // Don't care (not writing back)
				Branch    = 1'b0;      // Not a branch
				ALUOp     = 2'b00;     // ALUOp 00 forces ADD (Address calc)
			end
			// R-Type (add, sub, and, or, slt)
			7'b0110011: begin
				RegWrite  = 1'b1;      // Write result to register
				ImmSrc    = 2'bxx;     // No immediate used
				ALUSrc    = 1'b0;      // Operand B is Reg (RD2)
				MemWrite  = 1'b0;      // No memory write
				ResultSrc = 1'b0;      // Result comes from ALU
				Branch    = 1'b0;      // Not a branch
				ALUOp     = 2'b10;     // Look at Funct fields
			end
			// beq (Branch Equal)
			7'b1100011: begin
				RegWrite  = 1'b0;      // Branches don't write to registers
				ImmSrc    = 2'b10;     // B-Type Immediate (Branch offset)
				ALUSrc    = 1'b0;      // ALU compares RegA vs RegB
				MemWrite  = 1'b0;      // No memory write
				ResultSrc = 1'bx;      // Don't care (not writing back)
				Branch    = 1'b1;      // This IS a branch
				ALUOp     = 2'b01;     // Force SUB for comparison
			end	
			// I-Type ALU (addi)
			7'b0010011: begin
				RegWrite = 1'b1;
				ImmSrc = 2'b00;
				ALUSrc = 1'b1;
				MemWrite = 1'b0;
				ResultSrc = 1'b0;
				Branch = 1'b0;
				// If it is 'addi' (Funct3 = 000), we MUST force ALUOp to 00 (ADD).
				// Otherwise, the negative immediate's Bit 30 will accidentally trigger SUB.
				if (Funct3 == 3'b000) 
				  ALUOp = 2'b00; // Force ADD for addi
				else 
				  ALUOp = 2'b10; // Use Function bits for slti, andi, etc.
			end
			default: ; // Do nothing (keep defaults)
		 endcase
	end
	
	// ========================================================================
	// 2. ALU DECODER
	//    Decides the specific math operation based on ALUOp and Funct fields.
	// ========================================================================
	always @(*) begin
		case(ALUOp)
			// ALUOp 00: LW/SW -> Always ADD
			2'b00: ALUControl = 3'b010; 
			// ALUOp 01: BEQ -> Always SUB
			2'b01: ALUControl = 3'b110; 
			// ALUOp 10: R-Type or I-Type -> Look at Funct3 & Funct7
			2'b10: begin
				case(Funct3)
					// ADD / SUB (000)
					3'b000: begin
						if(Funct7b5) ALUControl = 3'b110; // SUB
						else         ALUControl = 3'b010; // ADD
					end
					// SLT (010)
					3'b010: ALUControl = 3'b111; // SLT
					// OR (110)
					3'b110: ALUControl = 3'b001; // OR
					// AND (111)
					3'b111: ALUControl = 3'b000; // AND
					default: ALUControl = 3'bxxx;
				endcase
			end
			default: ALUControl = 3'bxxx;
		endcase
	end
	// ========================================================================
	// 3. PC SRC LOGIC
	// ========================================================================
	assign PCSrc = Branch & Zero;
	
endmodule