class transaction;
  rand bit [3:0] a;
  rand bit [3:0] b;
  rand bit       cin;
  bit [3:0]      sum;
  bit            cout;

  function void display(string name);
    $display("-----------------------------");
    $display("-%s", name);
    $display("-----------------------------");
    $display("-a: %0d (4'b%04b) || b: %0d (4'b%04b) || cin: %0b", a, a, b, b, cin);
    $display("-sum: %0d (4'b%04b) || cout: %0b", sum, sum, cout);
    $display("-----------------------------");
  endfunction
endclass
