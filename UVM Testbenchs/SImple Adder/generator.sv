class generator extends uvm_component;

    int num_tx = 10;
    mailbox #(add_item) drv_mbx;

    function new(string name = "generator", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(mailbox #(add_item))::get(this, "*", "drv_mbx", drv_mbx));
            `uvm_fatal("GEN", "Could not get mailbox from config DB");
    endfunction

    task run_phase(uvm_phase phase);
        for(int i = 0; i < num_tx; i++)begin
            add_item req;
            req = add_item::type_id::create("req");

            if(!req.randomize())
                `uvm_error("GEN", "Randomization failed")
            else begin
                drv_mbx.put(req);
                `uvm_info("GEN", "Generated signals", UVM_HIGH)
            end
        end
    endtask
endclass
