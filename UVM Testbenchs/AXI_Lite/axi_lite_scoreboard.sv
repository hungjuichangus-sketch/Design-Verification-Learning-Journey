class axi_lite_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_lite_scoreboard)

    uvm_tlm_analysis_fifo #(axi_lite_seq_item) item_fifo;

    logic [31:0] regs[0:3] = '{default: '0};

    function new(string name = "axi_lite_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_fifo = new("item_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_seq_item item;
        forever begin
            item_fifo.get(item);
            if(item.op == axi_lite_seq_item::WRITE)
                check_writes(item);
            else
                check_reads(item);
        end
    endtask

    function void check_writes(axi_lite_seq_item item);
        int idx = item.addr[3:2];
        for(int i = 0; i < 4; i++)begin
            if(item.wstrb[i])begin
                regs[idx][(i*8) +: 8] = item.wdata[(i*8) +: 8];
            end
        end
    endfunction

    function void check_reads(axi_lite_seq_item item);
        bit is_valid = is_addr_valid(item.addr);
        logic [31:0] expected_data;
        expected_data = regs[item.addr[3:2]];

        if(is_valid && item.resp != 2'b00) begin
            `uvm_error("SCB", $sformatf("Unexpected Error! Valid Addr 'h%h returned resp 'b%b", item.addr, item.resp))
        end
        else if(!is_valid && item.resp == 2'b00) begin
            `uvm_error("SCB", $sformatf("Security Gap! Illegal Addr 'h%h returned OKAY", item.addr))
        end
        if(is_valid && item.resp == 2'b00)begin
            if(expected_data != item.rdata)begin
                `uvm_error("SCB", $sformatf("Mismatch at Addr: 'h%0h | Expected: 'h%0h | Actual: 'h%0h",
                                            item.addr, expected_data, item.rdata))
            end else begin
                `uvm_info("SCB", $sformatf("PASS at Addr: 'h%0h | Data: 'h%0h", item.addr, item.rdata), UVM_HIGH)
            end
        end
    endfunction

    function bit is_addr_valid(bit [31:0] addr);
        return (addr <= 32'hC && addr[1:0] == 2'b00);
    endfunction
endclass
