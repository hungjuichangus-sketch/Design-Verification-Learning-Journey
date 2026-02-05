//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [15:0]lfsr_out;
wire [15:0]answer;
wire ans_ready;
wire btn_debounce;
wire [2:0] As, Bs, Ass, Bss;
wire [3:0] d0, d1, d2, d3;
wire [3:0] d0s, d1s, d2s, d3s;
wire [3:0] round_counter;
wire WE;
wire [21:0] history;
//=======================================================
//  Structural coding
//=======================================================
Debouncer udebouncer (
	.clk(MAX10_CLK1_50), .rst_n(KEY[0]), .btn_in(KEY[1]), .btn_out(btn_debounce)
);
LFSR_16 ulfsr (
	.clk(MAX10_CLK1_50), .rst_n(KEY[0]), .lfsr_out(lfsr_out)
);
AnswerGenerator uag (
	.clk(MAX10_CLK1_50), .rst_n(KEY[0]), .btn_in(btn_debounce), .lfsr_in(lfsr_out[3:0]), .answer(answer),
	.ready(ans_ready)
);
MainFSM umain(
	.clk(MAX10_CLK1_50), .rst_n(KEY[0]), .btn_in(btn_debounce), .answer(answer), .digit_in(SW[3:0]), .clear_sw(SW[9]),
	.ans_ready(ans_ready), .As(As), .Bs(Bs), .guess_counter(LEDR[8:0]), .guessed(LEDR[9]), .WE(WE), .round_counter(round_counter),
	.d0(d0), .d1(d1), .d2(d2), .d3(d3)
);
GuessHistory umem (
	.clk(MAX10_CLK1_50), .rst_n(KEY[0]), .WE(WE), .read_addr(SW[7:4]), .write_addr(round_counter),
	.history_out(history), .guess({As, Bs, d0, d1, d2, d3})
);

assign d3s = (SW[8])? answer[15:12] : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[3:0] : d3;
assign d2s = (SW[8])? answer[11:8] : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[7:4] : d2;
assign d1s = (SW[8])? answer[7:4] : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[11:8] : d1;
assign d0s = (SW[8])? answer[3:0] : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[15:12] : d0;

assign Bss = (SW[8])? Bs : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[18:16] : Bs;
assign Ass = (SW[8])? As : (SW[7:4] > 0 && SW[7:4] <= round_counter)? history[21:19] : As;

HexDigit uhex0 (
	.bin_digit(d3s), .seg(HEX0)
);
HexDigit uhex1 (
	.bin_digit(d2s), .seg(HEX1)
);
HexDigit uhex2 (
	.bin_digit(d1s), .seg(HEX2)
);
HexDigit uhex3 (
	.bin_digit(d0s), .seg(HEX3)
);
HexDigit uhex4 (
	.bin_digit(Bss), .seg(HEX4)
);
HexDigit uhex5 (
	.bin_digit(Ass), .seg(HEX5)
);
