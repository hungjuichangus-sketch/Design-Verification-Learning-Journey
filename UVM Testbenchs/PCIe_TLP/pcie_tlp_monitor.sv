class pcie_tlp_monitor extends uvm_monitor;
    `uvm_component_utils(pcie_tlp_monitor)

    virtual pcie_tlp_if vif;
    uvm_analysis_port #(pcie_tlp_seq_item) req_ap, cpl_ap;

    function new(string name = "pcie_tlp_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual pcie_tlp_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get the virtual interface from Config DB")
        req_ap = new("req_ap", this);
        cpl_ap = new("cpl_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_reads();
            monitor_writes();
        join_none
    endtask

    task monitor_reads();
        pcie_tlp_seq_item cpl_item;
        forever begin
            cpl_item = pcie_tlp_seq_item::type_id::create("cpl_item");
            @(vif.mon_cb iff (vif.mon_cb.tx_valid && vif.mon_cb.tx_sop));
            cpl_item.fmt = vif.mon_cb.tx_data[31:29];
            cpl_item.typ = vif.mon_cb.tx_data[28:24];
            cpl_item.length = vif.mon_cb.tx_data[9:0];
            // `uvm_info("MON", $sformatf("Completion Header 0: 0x%h", vif.mon_cb.tx_data), UVM_LOW)
            @(vif.mon_cb);
            cpl_item.cpl_id = vif.mon_cb.tx_data[31:16];
            cpl_item.status = vif.mon_cb.tx_data[15:13];
            // `uvm_info("MON", $sformatf("Completion Header 1: 0x%h", vif.mon_cb.tx_data), UVM_LOW)
            @(vif.mon_cb);
            cpl_item.req_id = vif.mon_cb.tx_data[31:16];
            cpl_item.tag = vif.mon_cb.tx_data[15:8];
            // `uvm_info("MON", $sformatf("Completion Header 2: 0x%h", vif.mon_cb.tx_data), UVM_LOW)
            if(cpl_item.fmt == 3'b010)begin
                cpl_item.rdata = new[cpl_item.length];
                for(int i = 0; i < cpl_item.length; i++)begin
                    @(vif.mon_cb);
                    cpl_item.rdata[i] = vif.mon_cb.tx_data;
                    // `uvm_info("MON", $sformatf("Data sent: 0x%h", vif.mon_cb.tx_data), UVM_LOW)
                end
            end

            cpl_ap.write(cpl_item);
        end
    endtask

    task monitor_writes();
        pcie_tlp_seq_item req_item;
        forever begin
            @(vif.mon_cb iff (vif.mon_cb.rx_valid && vif.mon_cb.rx_sop));
            req_item = pcie_tlp_seq_item::type_id::create("req_item");

            req_item.fmt = vif.mon_cb.rx_data[31:29];
            req_item.typ = vif.mon_cb.rx_data[28:24];
            req_item.tc = vif.mon_cb.rx_data[22:20];
            req_item.td = vif.mon_cb.rx_data[15];
            req_item.ep = vif.mon_cb.rx_data[14];
            req_item.length = vif.mon_cb.rx_data[9:0];
            // `uvm_info("MON", $sformatf("Request Header 0: 0x%h", vif.mon_cb.rx_data), UVM_LOW)
            @(vif.mon_cb);
            req_item.req_id = vif.mon_cb.rx_data[31:16];
            req_item.tag = vif.mon_cb.rx_data[15:8];
            req_item.last_dw_be = vif.mon_cb.rx_data[7:4];
            req_item.first_dw_be = vif.mon_cb.rx_data[3:0];
            // `uvm_info("MON", $sformatf("Request Header 1: 0x%h", vif.mon_cb.rx_data), UVM_LOW)
            @(vif.mon_cb);
            req_item.addr = vif.mon_cb.rx_data;
            // `uvm_info("MON", $sformatf("Request Header 2: 0x%h", vif.mon_cb.rx_data), UVM_LOW)
            if(req_item.fmt == 3'b010)begin
                req_item.wdata = new[req_item.length];
                for(int i = 0; i < req_item.length; i++)begin
                    @(vif.mon_cb);
                    req_item.wdata[i] = vif.mon_cb.rx_data;
                    // `uvm_info("MON", $sformatf("Data write: 0x%h", vif.mon_cb.rx_data), UVM_LOW)
                end
            end

            req_ap.write(req_item);
        end
    endtask
endclass
