class scoreboard extends uvm_component;

    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(add_item, scoreboard) ap_imp;

    event test_done;
    int num_tx;
    int items_checked = 0;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(add_item act_tx);
        if(act_tx.a + act_tx.b == {act_tx.carry, act_tx.sum})
            // Using UVM reporting from Step 1!
            `uvm_info("SCB", $sformatf("PASS! a=%0b b=%0b carry=%0b sum=%0b",
                                       act_tx.a, act_tx.b, act_tx.carry, act_tx.sum), UVM_LOW)
        else
            `uvm_error("SCB", $sformatf("FAIL! a=%0b b=%0b carry=%0b sum=%0b",
                                        act_tx.a, act_tx.b, act_tx.carry, act_tx.sum))

        items_checked++;
        if(items_checked == num_tx) begin
            -> test_done;
        end
    endfunction

endclass
