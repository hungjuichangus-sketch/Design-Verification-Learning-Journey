class reg_item;

    rand logic [7:0]  addr;
    rand logic [15:0] wdata;
    rand logic        wr;

    logic [15:0] rdata;

    constraint addr_range {
        addr inside{[8'h00:8'h32]};
    }

    constraint wr_dist {
        wr dist{0:=50, 1:=50};
    }

    function void print(string name = "reg_item");
        $display("[%0t] %s: wr=%0d addr=0x%0h wdata=0x%0h rdata=0x%0h", 
                 $time, name, wr, addr, wdata, rdata);
    endfunction

endclass
