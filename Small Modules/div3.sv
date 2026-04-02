module clk_div3 (
    input  logic clk,
    input  logic rst_n,
    output logic clk_out
);

    // Change the size of counter to divide any odd number
    // The formula for Div N, and N is an odd number
    // counter must count to N-1, and be HIGH for (N-1)/2 cycle
    // shifte 0.5 cycle by using negedge clk
    // ORing the two clk together.
    logic [1:0] counter;
    logic clk_p;
    logic clk_n;

    //==================================================
    // 1. Base Counter (Counts 0, 1, 2 on positive edge)
    //==================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 2'b00;
        end else begin
            if (counter == 2'd2)
                counter <= 2'b00;
            else
                counter <= counter + 1'b1;
        end
    end

    //==================================================
    // 2. Positive Phase Pulse (HIGH for 1 cycle)
    //==================================================
    // clk_p is HIGH only when the counter is 0. 
    // This gives us a 33% duty cycle (1 cycle HIGH, 2 cycles LOW)
    assign clk_p = (counter == 2'd0);

    //==================================================
    // 3. Negative Phase Pulse (Shifted by 0.5 cycles)
    //==================================================
    // Sample clk_p on the negative edge of the clock.
    // This perfectly delays the pulse by 0.5 clock cycles.
    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_n <= 1'b0;
        end else begin
            clk_n <= clk_p; 
        end
    end

    //==================================================
    // 4. Combine to get 50% Duty Cycle
    //==================================================
    // 1 cycle HIGH (from clk_p) + 0.5 cycle shift (from clk_n) 
    // = Exactly 1.5 cycles HIGH and 1.5 cycles LOW!
    assign clk_out = clk_p | clk_n;

endmodule
