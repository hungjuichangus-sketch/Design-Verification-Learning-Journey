// 1101 Sequence detector
module MealyFSM(
    input clk,
    input rst_n,
    input data_in,

    output logic seq_found
);
    typedef enum logic [1:0] {IDLE, state1, state11, state110} state_t;

    state_t state;
    state_t next_state;

    always_ff @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case(state)
            IDLE:begin
                if(data_in) next_state = state1;
                else next_state = IDLE;
            end
            state1:begin
                if(data_in) next_state = state11;
                else next_state = IDLE;
            end
            state11:begin
                if(data_in) next_state = state11;
                else next_state = state110;
            end
            state110:begin
                if(data_in) next_state = state1;
                else next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    assign seq_found = (state == state110) && (data_in);
endmodule
