module Mux2 (
    input  [31:0] d0, // Select 0 Input
    input  [31:0] d1, // Select 1 Input
    input         s,  // Select Signal
    output [31:0] y   // Output
);

    // The Ternary Operator
    // If s is 1, y = d1.
    // If s is 0, y = d0.
    assign y = s ? d1 : d0;

endmodule