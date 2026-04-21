class add_item;

    bit rstn;
    rand bit a;
    rand bit b;

    bit carry;
    bit sum;

    function void print(string name = "add_item");
        $display("[%0t] %s: rstn=%0b a=%0b b=%0b carry=%0b sum=%0b",
                    $time, name, rstn, a, b, carry, sum);
    endfunction
endclass
