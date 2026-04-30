class axi_lite_driver extends uvm_driver #(axi_lite_seq_item);
    `uvm_component_utils(axi_lite_driver)

    virtual axi_lite_if vif;

    function new(string name = "axi_lite_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual axi_lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get the virtual interface from Config DB")
    endfunction

    task run_phase(uvm_phase phase);
        // Wait for physical reset to happen in the testbench
        wait(!vif.rst_n);
        reset();         // Drive 0s while reset is active
        wait(vif.rst_n); // Wait for chip to wake up

        forever begin
            seq_item_port.get_next_item(req);

            if(req.op == axi_lite_seq_item::WRITE)
                drive_write(req);
            else
                drive_read(req);

            seq_item_port.item_done();
        end
    endtask

    task reset();
        vif.awaddr  <= 0;
        vif.awvalid <= 0;
        vif.wdata   <= 0;
        vif.wstrb   <= 0;
        vif.wvalid  <= 0;
        vif.bready  <= 0;
        vif.araddr  <= 0;
        vif.arvalid <= 0;
        vif.rready  <= 0;
    endtask

    task drive_write(axi_lite_seq_item req);
        @(vif.drv_cb); // Sync to clock before driving

        // 1. Drive Address and Data
        vif.drv_cb.awaddr  <= req.addr;
        vif.drv_cb.wdata   <= req.wdata;
        vif.drv_cb.wstrb   <= req.wstrb; // Added wstrb!
        vif.drv_cb.awvalid <= 1;
        vif.drv_cb.wvalid  <= 1;

        // 2. Wait for Slave to accept BOTH
        // (Note: For a fully generic driver, use fork...join here,
        // but this works perfectly for your specific slave!)
        @(vif.drv_cb iff (vif.drv_cb.awready && vif.drv_cb.wready));

        // 3. Drop valids
        vif.drv_cb.awvalid <= 0;
        vif.drv_cb.wvalid  <= 0;

        // 4. Wait for Receipt
        vif.drv_cb.bready <= 1;
        @(vif.drv_cb iff (vif.drv_cb.bvalid));
        req.resp = vif.drv_cb.bresp;
        vif.drv_cb.bready <= 0;
    endtask

    task drive_read(axi_lite_seq_item req);
        @(vif.drv_cb); // Sync to clock before driving

        // 1. Send Address
        vif.drv_cb.araddr  <= req.addr;
        vif.drv_cb.arvalid <= 1;

        // Wait for Slave to accept Address
        @(vif.drv_cb iff (vif.drv_cb.arready));
        vif.drv_cb.arvalid <= 0;

        // 2. Wait for Data
        vif.drv_cb.rready <= 1;
        @(vif.drv_cb iff (vif.drv_cb.rvalid));
        req.rdata = vif.drv_cb.rdata;
        req.resp  = vif.drv_cb.rresp;
        vif.drv_cb.rready <= 0;
    endtask

endclass
