class monitor extends uvm_component;

    `uvm_component_utils(monitor)

    virtual add_if vif;

    uvm_analysis_port #(add_item) ap;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db#(virtual add_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get virtual interface from config DB!")
    endfunction

    task run_phase(uvm_phase phase);

        wait(vif.rstn === 1'b1);
        forever begin
            add_item act_tx;
            @(vif.mon_cb);

            act_tx = add_item::type_id::create("act_tx");
            act_tx.rstn = vif.mon_cb.rstn;
            act_tx.a = vif.mon_cb.a;
            act_tx.b = vif.mon_cb.b;
            act_tx.carry = vif.mon_cb.carry;
            act_tx.sum = vif.mon_cb.sum;

            ap.write(act_tx);
            `uvm_info("MON", "Monitor broadcasted data", UVM_HIGH)
        end
    endtask
endclass
