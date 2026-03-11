module Axis_Display_Driver (
	input [15:0] axis_data,
	output led_sign,       // Connect to LEDR
	output [6:0] hex_int,  // Connect to the Integer HEX (e.g., HEX1)
	output [6:0] hex_frac  // Connect to the Fraction HEX (e.g., HEX0)
);

	// 1. Extract Sign and Absolute Value
	wire sign = axis_data[15];
	wire [15:0] abs_data = sign ? (~axis_data + 1'b1) : axis_data;

	// 2. The Math: Multiply by 10, Divide by 256 (shift right by 8)
	wire [19:0] math_mult = abs_data * 4'd10; 
	wire [11:0] decimal_val = math_mult[19:8]; 

	// 3. Cap at 9.9g (99) so the displays never output garbage if you shake it hard
	wire [6:0] capped_val = (decimal_val > 99) ? 7'd99 : decimal_val[6:0];

	// 4. Split into two digits (Tens and Ones)
	wire [3:0] bcd_int  = capped_val / 10;
	wire [3:0] bcd_frac = capped_val % 10;

	// 5. Output Routing
	assign led_sign = sign; // Turns on LED if negative

	Seven_Seg_Decoder dec_int  (.bcd(bcd_int),  .seg(hex_int));
	Seven_Seg_Decoder dec_frac (.bcd(bcd_frac), .seg(hex_frac));

endmodule