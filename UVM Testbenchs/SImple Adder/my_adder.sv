module my_adder(
    input logic rstn,
    input logic a,
    input logic b,

    output logic carry,
    output logic sum
);

    always_comb begin
        if(!rstn)begin
            carry = 0;
            sum = 0;
        end else begin
            {carry, sum} = a + b;
        end
    end

endmodule
