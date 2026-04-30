module axi_lite_slave(
    axi_lite_if bus
);
    // ------------------------------------------------------------------------
    // Internal Memory & Capture Registers
    // ------------------------------------------------------------------------
    logic [31:0] regs [0:3];
    logic [31:0] temp_waddr;
    logic [31:0] temp_data;
    logic [31:0] temp_raddr;
    logic [3:0] temp_wstrb;

    logic w_addr_ok;
    logic r_addr_ok;
    assign w_addr_ok = (temp_waddr <= 32'hC) && (temp_waddr[1:0] == 2'b00);
    assign r_addr_ok = (temp_raddr <= 32'hC) && (temp_raddr[1:0] == 2'b00);

    // ------------------------------------------------------------------------
    // WRITE FSM (AW, W, B Channels)
    // ------------------------------------------------------------------------
    typedef enum {W_IDLE, WAIT_ADDR, WAIT_WDATA, WRITE_EXEC, SEND_RESP} wstate_t;
    wstate_t wcurrent_state, wnext_state;

    // Write State Register
    always_ff @(posedge bus.clk or negedge bus.rst_n) begin
        if(!bus.rst_n) begin
            wcurrent_state <= W_IDLE;
        end else begin
            wcurrent_state <= wnext_state;
        end
    end

    // Write Next State Logic
    always_comb begin
        wnext_state = wcurrent_state; // Default
        case(wcurrent_state)
            W_IDLE: begin
                if(bus.awvalid && bus.wvalid)      wnext_state = WRITE_EXEC;
                else if(bus.awvalid)               wnext_state = WAIT_WDATA;
                else if(bus.wvalid)                wnext_state = WAIT_ADDR;
            end
            WAIT_WDATA: begin
                if(bus.wvalid)                     wnext_state = WRITE_EXEC;
            end
            WAIT_ADDR: begin
                if(bus.awvalid)                    wnext_state = WRITE_EXEC;
            end
            WRITE_EXEC: begin
                wnext_state = SEND_RESP;
            end
            SEND_RESP: begin
                if(bus.bready)                     wnext_state = W_IDLE;
            end
        endcase
    end

    // Write Output & Capture Logic
    always_ff @(posedge bus.clk or negedge bus.rst_n) begin
        if(!bus.rst_n) begin
            bus.awready <= 0;
            bus.wready  <= 0;
            bus.bvalid  <= 0;
            bus.bresp   <= 2'b00;
            temp_waddr <= 0;
        end else begin
            case(wcurrent_state)
                W_IDLE: begin
                    bus.awready <= 1;
                    bus.wready  <= 1;
                    bus.bvalid  <= 0;
                    if(bus.awvalid) temp_waddr <= bus.awaddr;
                    if(bus.wvalid)  temp_data  <= bus.wdata;
                    temp_wstrb <= bus.wstrb;
                end
                WAIT_WDATA: begin
                    bus.awready <= 0; // Got address, close the gate
                    bus.wready  <= 1;
                    if(bus.wvalid)  temp_data  <= bus.wdata;
                end
                WAIT_ADDR: begin
                    bus.awready <= 1;
                    bus.wready  <= 0; // Got data, close the gate
                    if(bus.awvalid) temp_waddr <= bus.awaddr;
                end
                WRITE_EXEC: begin
                    bus.awready <= 0;
                    bus.wready  <= 0;
                    if(w_addr_ok)begin
                        for(int i = 0; i < 4; i++)begin
                            regs[temp_waddr[3:2]][(i*8) +: 8] <= bus.wdata[(i*8) +: 8];
                        end
                        bus.bresp   <= 2'b00; // OKAY
                    end else begin
                        bus.bresp <= 2'b10; // SLVERR (Slave Error)
                    end
                    bus.bvalid  <= 1;
                end
                SEND_RESP: begin
                    bus.awready <= 0;
                    bus.wready  <= 0;
                    // bvalid stays high until bready hits (handled by transition out)
                end
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // READ FSM (AR, R Channels)
    // ------------------------------------------------------------------------
    typedef enum {R_IDLE, READ_FETCH, HANDSHAKE} rstate_t;
    rstate_t rcurrent_state, rnext_state;

    // Read State Register
    always_ff @(posedge bus.clk or negedge bus.rst_n) begin
        if(!bus.rst_n) begin
            rcurrent_state <= R_IDLE;
        end else begin
            rcurrent_state <= rnext_state;
        end
    end

    // Read Next State Logic
    always_comb begin
        rnext_state = rcurrent_state; // Default
        case(rcurrent_state)
            R_IDLE: begin
                if(bus.arvalid)                    rnext_state = READ_FETCH;
            end
            READ_FETCH: begin
                rnext_state = HANDSHAKE;
            end
            HANDSHAKE: begin
                if(bus.rvalid && bus.rready)       rnext_state = R_IDLE;
            end
        endcase
    end

    // Read Output & Capture Logic
    always_ff @(posedge bus.clk or negedge bus.rst_n) begin
        if(!bus.rst_n) begin
            bus.rvalid  <= 0;
            bus.arready <= 0;
            bus.rresp   <= 2'b00;
            temp_raddr <= 0;
        end else begin
            case(rcurrent_state)
                R_IDLE: begin
                    bus.rvalid  <= 0;
                    bus.arready <= 1;
                    if(bus.arvalid) temp_raddr <= bus.araddr;
                end
                READ_FETCH: begin
                    if(r_addr_ok)begin
                        bus.rdata   <= regs[temp_raddr[3:2]];
                        bus.rresp   <= 2'b00; // OKAY
                    end else begin
                        bus.rdata <= 32'hDEAD_BEEF; // Standard "Bad Data" marker
                        bus.rresp <= 2'b10;
                    end
                    bus.arready <= 0; // Close the gate
                end
                HANDSHAKE: begin
                    bus.rvalid  <= 1;
                end
            endcase
        end
    end

endmodule
