module rx #(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rx_in,
    input  logic fifo_full,

    output logic fifo_write_en,
    output logic [DATA_WIDTH-1:0] fifo_data_out,
    output logic parity_error,
    output logic framing_error
);

    typedef enum logic [2:0] {IDLE, START_DETECT, DATA_RECEIVE, STOP_DETECT, PUSH} state_t;
    state_t current_state, next_state;

    // 2-Flop Synchronizer for asynchronous input
    logic rx_sync_1, rx_sync;
    logic rx_sync_prev;

    logic [3:0] sample_cnt;

    logic [$clog2(DATA_WIDTH):0] data_index;

    logic [DATA_WIDTH-1:0] rx_shift_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            current_state <= IDLE;
            rx_sync_1     <= 1'b1;
            rx_sync       <= 1'b1;
            rx_sync_prev  <= 1'b1;
        end else begin
            current_state <= next_state;

            rx_sync_1     <= rx_in;
            rx_sync       <= rx_sync_1;
            rx_sync_prev  <= rx_sync;
        end
    end

    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                // Detect falling edge (Start Bit transition)
                if (rx_sync_prev == 1'b1 && rx_sync == 1'b0)
                    next_state = START_DETECT;
            end

            START_DETECT: begin
                // Wait until the middle of the start bit (tick 7)
                if (sample_cnt == 4'd7) begin
                    if (rx_sync == 1'b0)
                        next_state = DATA_RECEIVE; // Valid start bit
                    else
                        next_state = IDLE;         // Noise glitch, abort
                end
            end

            DATA_RECEIVE: begin
                // Transition only when the last bit has finished its 16 clock cycles
                if (sample_cnt == 4'd15 && data_index == (DATA_WIDTH - 1))
                    next_state = STOP_DETECT;
            end

            STOP_DETECT: begin
                // Wait until the middle of the stop bit (tick 15)
                if (sample_cnt == 4'd15)
                    next_state = PUSH;
            end

            PUSH: begin
                // Takes 1 clock cycle to evaluate FIFO, then returns to IDLE
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sample_cnt    <= 4'd0;
            data_index    <= '0;
            rx_shift_reg  <= '0;
            fifo_write_en <= 1'b0;
            fifo_data_out <= '0;
            framing_error <= 1'b0;
            parity_error  <= 1'b0;
        end else begin
            fifo_write_en <= 1'b0;

            case (current_state)
                IDLE: begin
                    sample_cnt <= 4'd0;
                    data_index <= '0;
                end

                START_DETECT: begin
                    if (sample_cnt == 4'd7) begin
                        sample_cnt <= 4'd0;
                    end else begin
                        sample_cnt <= sample_cnt + 1'b1;
                    end
                end

                DATA_RECEIVE: begin
                    if (sample_cnt == 4'd15) begin
                        sample_cnt <= 4'd0;

                        // UART transmits LSB first. Shift data in from the MSB side.
                        rx_shift_reg <= {rx_sync, rx_shift_reg[DATA_WIDTH-1:1]};
                        data_index   <= data_index + 1'b1;
                    end else begin
                        sample_cnt <= sample_cnt + 1'b1;
                    end
                end

                STOP_DETECT: begin
                    if (sample_cnt == 4'd15) begin
                        sample_cnt <= 4'd0;

                        // Evaluate framing error (Stop bit must be 1)
                        if (rx_sync == 1'b0)
                            framing_error <= 1'b1;
                        else
                            framing_error <= 1'b0;
                    end else begin
                        sample_cnt <= sample_cnt + 1'b1;
                    end
                end

                PUSH: begin
                    if (!fifo_full) begin
                        fifo_write_en <= 1'b1;
                        fifo_data_out <= rx_shift_reg;
                    end
                end

                default: begin
                    sample_cnt <= 4'd0;
                    data_index <= '0;
                end
            endcase
        end
    end
endmodule
