module Extend(
    input  [31:7] Instr,   // The instruction bits (excluding opcode)
    input  [1:0]  ImmSrc,  // Selector: 00=I, 01=S, 10=B, 11=J
    output reg [31:0] ImmExt
);

    always @(*) begin
        case(ImmSrc)
            // ---------------------------------------------------------
            // 2'b00: I-Type (e.g., addi, lw)
            // Immediate is 12 bits: Instr[31:20]
            // Logic: Sign-extend bit 31 for 20 bits, then append Instr[31:20]
            // ---------------------------------------------------------
            2'b00: 
					ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            // ---------------------------------------------------------
            // 2'b01: S-Type (e.g., sw)
            // Immediate is 12 bits split into two parts: 
            // - Top 7 bits are at Instr[31:25]
            // - Bottom 5 bits are at Instr[11:7]
            // ---------------------------------------------------------
            2'b01: 
					ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            // ---------------------------------------------------------
            // 2'b10: B-Type (e.g., beq)
            // Immediate is 13 bits (but LSB is always 0)
            // Bit packing order (MSB to LSB): 
            // [31], [7], [30:25], [11:8], and a hardcoded 0 at the end.
            // ---------------------------------------------------------
            2'b10: 
					ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            // ---------------------------------------------------------
            // 2'b11: J-Type (e.g., jal)
            // Immediate is 21 bits (LSB always 0)
            // Bit packing order: 
            // [31], [19:12], [20], [30:21], and a hardcoded 0 at the end.
            // ---------------------------------------------------------
            2'b11: 
					ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            default: ImmExt = 32'bx; // Undefined
        endcase
    end

endmodule