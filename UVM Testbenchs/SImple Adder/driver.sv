class driver extends uvm_driver #(add_item);
    `uvm_component_utils(driver)

    virtual add_if vif;
    function new(string name = "driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual add_if)::get(this, "", "vif", vif));
            `uvm_fatal("DRV", "Could not get virtual interface from config DB");
    endfunction

    task reset();
        vif.drv_cb.rstn <= 0;
        repeat(2) @(vif.drv_cb);
        vif.drv_cb.rstn <= 1;
    endtask

    task run_phase(uvm_phase phase);
        reset();
        forever begin

            seq_itme_port.get_next_item(req);
            @(vif.drv_cb);
            vif.drv_cb.a <= req.a;
            vif.drv_cb.b <= req.b;
            `uvm_info("DRV", "Driver drove the signal", UVM_HIGH)

            seq_item_port.item_done();
        end
    endtask
endclass
