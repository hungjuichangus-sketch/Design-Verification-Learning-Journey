module tx #(parameter DATA_WIDTH = 8)(
    input logic clk,
    input logic rst_n,
    input logic fifo_empty,
    input logic [DATA_WIDTH-1:0] fifo_data,

    output logic fifo_read_en,
    output logic tx_out,
    output logic tx_busy
);
    typedef enum {IDLE, START_BIT, DATA_BITS, STOP_BIT} state_t;
    state_t current_state, next_state;

    logic [DATA_WIDTH-1:0] tx_shift_reg;
    logic[DATA_WIDTH-1:0] data_index;

    always_ff @(posedge clk)begin
        if(!rst_n)begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        case(current_state)
            IDLE: begin
                if(fifo_empty)
                    next_state = IDLE;
                else
                    next_state = START_BIT;
            end
            START_BIT: next_state = DATA_BITS;
            DATA_BITS: begin
                if(data_index == (DATA_WIDTH - 1))
                    next_state = STOP_BIT;
                else
                    next_state = DATA_BITS;
            end
            STOP_BIT: next_state = IDLE;
            default next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk)begin
        if(!rst_n)begin
            tx_busy <= 0;
            tx_out <= 1;
            data_index <= 0;
            fifo_read_en <= 0;
        end else begin
            case(current_state)
                IDLE: begin
                    tx_busy <= 0;
                    tx_out <= 1;
                    fifo_read_en <= 0;
                end
                START_BIT: begin
                    tx_busy <= 1;
                    tx_out <= 0;
                    fifo_read_en <= 1;
                    data_index <= 0;
                    tx_shift_reg <= fifo_data;
                end
                DATA_BITS: begin
                    tx_busy <= 1;
                    fifo_read_en <= 0;
                    tx_out <= tx_shift_reg[data_index];
                    data_index <= data_index + 1'b1;
                end
                STOP_BIT: begin
                    data_index <= 0;
                    tx_out <= 1;
                end
                default: begin
                    tx_bust <= 0;
                    tx_out <= 1;
                    fifo_read_en <= 0;
                end
            endcase
        end
    end
endmodule
