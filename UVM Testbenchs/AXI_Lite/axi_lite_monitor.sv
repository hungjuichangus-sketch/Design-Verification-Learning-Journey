class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)

    virtual axi_lite_if vif;
    uvm_analysis_port #(axi_lite_seq_item) ap;

    function new(string name = "axi_lite_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual axi_lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get the virtual interface from Config DB")
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        // Run two detective threads at the same time!
        fork
            monitor_writes();
            monitor_reads();
        join_none
    endtask

    // ------------------------------------------------------------------------
    // Thread 1: Watch for Writes
    // ------------------------------------------------------------------------
    task monitor_writes();
        axi_lite_seq_item w_item;
        forever begin
            w_item = axi_lite_seq_item::type_id::create("w_item");
            w_item.op = axi_lite_seq_item::WRITE;
            fork
                begin
                    // Wait for Address Phase
                    @(posedge vif.clk iff (vif.awvalid && vif.awready));
                    w_item.addr = vif.awaddr;
                end
                begin
                    // Wait for Data Phase
                    @(posedge vif.clk iff (vif.wvalid && vif.wready));
                    w_item.wdata = vif.wdata;
                    w_item.wstrb = vif.wstrb;
                end
            join
            // Wait for Response Phase (Transaction Complete!)
            @(posedge vif.clk iff (vif.bvalid && vif.bready));
            w_item.resp = vif.bresp;

            // Send the completed package to the Scoreboard
            ap.write(w_item);
        end
    endtask

    // ------------------------------------------------------------------------
    // Thread 2: Watch for Reads
    // ------------------------------------------------------------------------
    task monitor_reads();
        axi_lite_seq_item r_item;
        forever begin
            r_item = axi_lite_seq_item::type_id::create("r_item");
            r_item.op = axi_lite_seq_item::READ;

            // Wait for Address Phase
            @(posedge vif.clk iff (vif.arvalid && vif.arready));
            r_item.addr = vif.araddr;

            // Wait for Data & Response Phase (Transaction Complete!)
            @(posedge vif.clk iff (vif.rvalid && vif.rready));
            r_item.rdata = vif.rdata;
            r_item.resp  = vif.rresp;

            // Send the completed package to the Scoreboard
            ap.write(r_item);
        end
    endtask

endclass
