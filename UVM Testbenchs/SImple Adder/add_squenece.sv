class add_sequence extends uvm_sequence #(add_item);

    `uvm_object_utils(add_sequence)

    int num_tx = 10;

    function new(string name = "add_sequence");
        super.new(name);
    endfunction

    task body();
        for(int i = 0; i < num_tx; i++) begin
            req = add_item::type_id::create("req");

            start_item(req);

            if(!req.randomize()) begin
                `uvm_error("SEQ", "Randomization failed")
            end

            finish_item(req);

            `uvm_info("SEQ", "Generated and sent signal to driver", UVM_HIGH)
        end
    endtask
endclass
