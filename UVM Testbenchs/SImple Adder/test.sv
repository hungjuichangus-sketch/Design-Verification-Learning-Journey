class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    env enviroment;

    int test_num_tx = 10;


    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        enviroment = env::type_id::create("enviroment", this);
    endfunction


    task run_phase(uvm_phase phase);

        add_sequence seq;
        phase.raise_objection(this);

        `uvm_info("TEST", "Starting test", UVM_LOW)

        enviroment.scb.num_tx = test_num_tx;

        seq = add_sequence::type_id::create("seq");
        seq.num_tx = test_num_tx;

        seq.start(enviroment.sqr);

        wait(enviroment.scb.test_done.triggered);
        `uvm_info("TEST", "TEST FINISHED GRACEFULLY", UVM_LOW)

        phase.drop_objection(this);
    endtask
endclass

class test_long extends base_test;
    `uvm_component_utils(test_long)

    function new(string name = "test_long", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        test_num_tx = 50;
    endfunction
endclass

