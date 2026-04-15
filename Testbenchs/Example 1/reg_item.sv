// reg_item.sv
class reg_item;

    // 1. Add the 'rand' keyword to the variables you want the simulator to randomize.
    rand logic [7:0]  addr;
    rand logic [15:0] wdata;
    rand logic        wr;

    // These variables are NOT randomized by the generator. 
    // They are filled in by the monitor when reading from the DUT.
    logic [15:0] rdata;

    // 2. Add constraints
    // This constraint ensures we only write to addresses between 0 and 50
    // so we don't have to simulate the entire 256 depth right now.
    constraint addr_range {
        addr inside{[8'h00:8'h32]};
    }

    // Add a constraint to make writes and reads equally likely (50/50 chance)
    // Hint: Use the 'dist' keyword or simply constrain 'wr' to be inside {0, 1}
    constraint wr_dist {
        wr dist{0:=50, 1:=50};
    }

    // 3. A helper function to easily print the transaction
    function void print(string name = "reg_item");
        $display("[%0t] %s: wr=%0d addr=0x%0h wdata=0x%0h rdata=0x%0h", 
                 $time, name, wr, addr, wdata, rdata);
    endfunction

endclass
