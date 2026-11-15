class scoreboard;
  mailbox mon2scb;
  int no_transactions;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main;
    transaction trans;
    bit [3:0] exp_sum;
    bit       exp_cout;
    forever begin
      mon2scb.get(trans);
      {exp_cout, exp_sum} = trans.a + trans.b + trans.cin;
      if ((exp_sum == trans.sum) && (exp_cout == trans.cout))
        $display("result is as expected");
      else
        $error("wrong result \n \t expected: sum=%0d cout=%0b | actual: sum=%0d cout=%0b",
               exp_sum, exp_cout, trans.sum, trans.cout);
      no_transactions++;
      trans.display("[scoreboard]");
    end
  endtask
endclass
