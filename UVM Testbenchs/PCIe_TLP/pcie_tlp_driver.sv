class pcie_tlp_driver extends uvm_driver #(pcie_tlp_seq_item);
    `uvm_component_utils(pcie_tlp_driver)

    virtual pcie_tlp_if vif;

    function new(string name = "pcie_tlp_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual pcie_tlp_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get the virtual interface from Config DB")
    endfunction

    task run_phase(uvm_phase phase);
        reset();
        forever begin
            seq_item_port.get_next_item(req);
            drive_tlp(req);
            seq_item_port.item_done();
        end
    endtask

    task reset();
        vif.drv_cb.rx_data <= 0;
        vif.drv_cb.rx_valid <= 0;
        vif.drv_cb.rx_sop <= 0;
        vif.drv_cb.rx_eop <= 0;

        wait(vif.rst_n == 1'b1);
        @(vif.drv_cb);
    endtask

    task drive_tlp(pcie_tlp_seq_item req);
        @(vif.drv_cb);
        vif.drv_cb.rx_valid <= 1;
        vif.drv_cb.rx_sop <= 1;
        vif.drv_cb.rx_data <= req.header[0];

        @(vif.drv_cb);
        vif.drv_cb.rx_sop <= 0;
        vif.drv_cb.rx_data <= req.header[1];

        @(vif.drv_cb);
        vif.drv_cb.rx_data <= req.header[2];
        if(req.fmt == 3'b010)begin
            for(int i = 0; i < req.length; i ++)begin
                @(vif.drv_cb);
                vif.drv_cb.rx_data <= req.wdata[i];
                if(i == (req.length - 1))
                    vif.drv_cb.rx_eop <= 1;
            end
        end
        else
            vif.drv_cb.rx_eop <= 1;

        @(vif.drv_cb);
        vif.drv_cb.rx_valid <= 0;
        vif.drv_cb.rx_eop <= 0;
        vif.drv_cb.rx_data <= 0;
    endtask
endclass
