// test.sv
class base_test;

    // 1. Declare the environment
    env environment;

    // 2. The constructor takes the virtual interface from tb_top
    // and passes it down to the environment
    function new(virtual reg_if vif);
        environment = new(vif);
    endfunction

    // 3. The main run task
    task run();
        $display("=======================================");
        $display("   STARTING BASE TEST");
        $display("=======================================");

        // a. Configure the Generator!
        // Let's override the default and tell it to send 20 transactions.
        // Hint: Access the generator inside the environment using environment.gen...
        environment.gen.num_tx = 20;

        // b. Run the environment
        environment.run();
    endtask

endclass

class test_write_only extends base_test;

    // The constructor calls super.new() to build the environment exactly like the base_test
    function new(virtual reg_if vif);
        super.new(vif);
    endfunction

    // We completely override the run task for this specific test
    task run();
        $display("=======================================");
        $display("   STARTING WRITE-ONLY TEST");
        $display("=======================================");

        // 1. Set how many items we want
        environment.gen.num_tx = 10;

        // 2. Twist the constraint knob!
        environment.gen.test_type = "write_only";

        // 3. Run it
        environment.run();
    endtask

endclass

class test_heavy_random extends base_test;

    function new(virtual reg_if vif);
        super.new(vif);
    endfunction

    task run();
        $display("=======================================");
        $display("   STARTING HEAVY RANDOM STRESS TEST");
        $display("=======================================");

        // 1. Open the floodgates: 200 transactions!
        environment.gen.num_tx = 200;

        // 2. Twist the knob back to the base constraints (50/50 Read/Write)
        environment.gen.test_type = "base";

        // 3. Run the environment
        environment.run();
    endtask

endclass
