module HazardDetectionUnit (
    // Inputs from Decode Stage (Current Instruction Source Regs)
    input [4:0] Rs1_D,
    input [4:0] Rs2_D,

    // Inputs from Execute Stage (Previous Instruction)
    input [4:0] Rd_E,
    input [1:0] ResultSrc_E, // 01 = Load
    input       PCSrc_E,     // 1 = Branch/Jump Taken

    // Outputs to Pipeline Registers and PC
    output reg StallF,      // Freeze PC
    output reg StallD,      // Freeze IF/ID
    output reg FlushD,      // Flush IF/ID
    output reg FlushE       // Flush ID/EX
);

    reg lwStall;

    always @(*) begin
        // 1. Detect Load-Use Hazard
        // If instruction in Execute is a Load (ResultSrc_E[0] == 1)
        // AND it writes to a register that Decode stage needs
        if ((ResultSrc_E[0] == 1'b1) && ((Rd_E == Rs1_D) || (Rd_E == Rs2_D))) begin
            lwStall = 1'b1;
        end else begin
            lwStall = 1'b0;
        end

        // 2. Generate Outputs
        
        // STALLS: Freezes the Fetch and Decode stages so we retry later
        StallF = lwStall; 
        StallD = lwStall;

        // FLUSHES: Kills the instruction in the pipeline
        
        // Flush Decode (IF/ID): 
        // If we take a branch (PCSrc_E), the instruction in Decode is wrong.
        FlushD = PCSrc_E; 

        // Flush Execute (ID/EX): 
        // If Load-Use stall, we inject a NOP into Execute.
        // If Branch Taken, we flush Execute as well.
        FlushE = lwStall || PCSrc_E;
    end

endmodule