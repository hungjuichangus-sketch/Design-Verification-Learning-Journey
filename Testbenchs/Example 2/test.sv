class base_test;

    env environment;

    function new(virtual reg_if vif);
        environment = new(vif);
    endfunction

    task run();
        $display("=======================================");
        $display("   STARTING BASE TEST");
        $display("=======================================");

        environment.gen.num_tx = 20;

        environment.run();
    endtask

endclass

class test_write_only extends base_test;

    function new(virtual reg_if vif);
        super.new(vif);
    endfunction

    task run();
        $display("=======================================");
        $display("   STARTING WRITE-ONLY TEST");
        $display("=======================================");

        environment.gen.num_tx = 10;
        environment.gen.test_type = "write_only";
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

        environment.gen.num_tx = 200;
        environment.gen.test_type = "base";
        environment.run();
    endtask

endclass
