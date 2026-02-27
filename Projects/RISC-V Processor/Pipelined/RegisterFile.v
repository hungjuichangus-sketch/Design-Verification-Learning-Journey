module RegisterFile(
    input clk,
    input WE3,                  // Write Enable
    input [4:0] A1, A2, A3,     // Address for Register
    input [31:0] WD3,           // Write Data
    output [31:0] RD1, RD2      // Read Data
);

    // 1. Declare the memory array (32 registers, each 32 bits wide)
    reg [31:0] rf [31:0];

    // 2. Read Logic (Combinational)
    assign RD1 = rf[A1];
    assign RD2 = rf[A2];

    // 3. Write Logic (Sequential)
    always @(posedge clk) begin
        // Strategy: Write Protection
        // 1. Force Register 0 to stay 0 (Self-correcting)
        rf[0] <= 32'd0;
		  
        // 2. Only write to other registers if Write Enable is ON and Address is not 0
        if (WE3 && (A3 != 5'd0)) begin
            rf[A3] <= WD3;
        end
    end

endmodule