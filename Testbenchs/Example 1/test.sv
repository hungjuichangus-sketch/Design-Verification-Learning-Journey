class base_test;

    env enviroment;

    function new(virtual add_if vif);
        enviroment = new(vif);
    endfunction

    task run();
        $display("=======================================");
        $display("   STARTING TEST");
        $display("=======================================");

        enviroment.gen.num_tx = 10;
        enviroment.run();
    endtask
endclass
