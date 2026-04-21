class add_item extends uvm_sequence_item;

    bit rstn;
    rand bit a;
    rand bit b;

    bit carry;
    bit sum;

    `uvm_object_utils(add_item)

    function new(string name = "add_item");
        super.new(name);
    endfunction

    function void print_item();
        `uvm_info("ADD_ITEM", $sformatf("rstn=%0b a=%0b b=%0b carry=%0b sum=%0b",
                                        rstn, a, b, carry, sum), UVM_LOW)
    endfunction

endclass
