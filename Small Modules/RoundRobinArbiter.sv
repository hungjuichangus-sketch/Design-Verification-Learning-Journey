module RoundRobinArbiter(
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] req,
    output logic [3:0] grant
);

    logic [3:0] last_grant;
    
    // Intermediate variables for Combinational logic
    logic [3:0] mask;
    logic [3:0] masked_req;
    logic [3:0] mask_grant;
    logic [3:0] unmask_grant;

    //========================================================
    // Block 1: Combinational Logic (Math)
    // Instantly calculates the grant based on current requests
    //========================================================
    always_comb begin
        // 1. Generate Mask and apply it to the requests
        mask = ~(last_grant | (last_grant - 1'b1));
        masked_req = req & mask;

        // 2. The Fixed-Priority Engines (Two's Complement trick)
        mask_grant   = masked_req & ~(masked_req - 1'b1); 
        unmask_grant = req & ~(req - 1'b1);

        // 3. The Decision
        if (masked_req != 4'b0) begin
            grant = mask_grant;
        end else begin
            grant = unmask_grant;
        end
    end

    //========================================================
    // Block 2: Sequential Logic (Memory)
    // Only responsible for remembering who won last time
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Must initialize to a valid priority state, not zero!
            last_grant <= 4'b0001; 
        end else begin
            // Only update the memory if an actual request was made
            if (req != 4'b0) begin
                last_grant <= grant;
            end
        end
    end

endmodule
