class driver;
  int no_transactions;
  virtual intf vif;
  mailbox gen2driv;

  function new(virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

  task reset;
    wait(vif.rst);
    $display("[driver]--------- reset started -------");
    vif.a     <= 4'b0000;
    vif.b     <= 4'b0000;
    vif.cin   <= 1'b0;
    vif.valid <= 1'b0;
    wait(!vif.rst);
    $display("[driver]--------- reset ended ---------");
  endtask

  task main;
    transaction trans;
    forever begin
      gen2driv.get(trans);
      @(posedge vif.clk);
      vif.valid <= 1'b1;
      vif.a     <= trans.a;
      vif.b     <= trans.b;
      vif.cin   <= trans.cin;
      @(posedge vif.clk);
      vif.valid <= 1'b0;
      @(posedge vif.clk);
      trans.sum  = vif.sum;
      trans.cout = vif.cout;
      trans.display("Driver");
      no_transactions++;
    end
  endtask
endclass
