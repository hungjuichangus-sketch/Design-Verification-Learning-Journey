module HazardUnit (
    // Inputs from Execute Stage (The registers we need)
    input [4:0] Rs1_E,
    input [4:0] Rs2_E,

    // Inputs from Memory Stage (The result available now)
    input [4:0] Rd_M,
    input RegWrite_M,

    // Inputs from Writeback Stage (The result written back)
    input [4:0] Rd_W,
    input RegWrite_W,

    // Outputs (Mux Selects)
    output reg [1:0] ForwardA_E,
    output reg [1:0] ForwardB_E
);

    // Forwarding Logic for SrcA
    always @(*) begin
        // Priority 1: Forward from Memory Stage (The most recent result)
        // Condition: Memory stage is writing to a register AND It's not x0 AND It matches Rs1
        if ((RegWrite_M == 1'b1) && (Rd_M != 5'd0) && (Rd_M == Rs1_E)) begin
            ForwardA_E = 2'b10;
        end
        // Priority 2: Forward from Writeback Stage
        else if ((RegWrite_W == 1'b1) && (Rd_W != 5'd0) && (Rd_W == Rs1_E)) begin
            ForwardA_E = 2'b01;
        end
        // Default: No forwarding
        else begin
            ForwardA_E = 2'b00;
        end
    end

    // Forwarding Logic for SrcB (Identical logic, just check Rs2)
    always @(*) begin
        if ((RegWrite_M == 1'b1) && (Rd_M != 5'd0) && (Rd_M == Rs2_E)) begin
            ForwardB_E = 2'b10;
        end
        else if ((RegWrite_W == 1'b1) && (Rd_W != 5'd0) && (Rd_W == Rs2_E)) begin
            ForwardB_E = 2'b01;
        end
        else begin
            ForwardB_E = 2'b00;
        end
    end

endmodule