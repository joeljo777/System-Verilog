class monitor;
  virtual intf vif;
  mailbox mon2scb;

  function new(virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main;
    forever begin
      transaction trans;
      trans = new();
      @(posedge vif.clk);
      wait(vif.valid);
      @(posedge vif.clk); // Clock edge where DUT samples valid inputs
      trans.a   = vif.a;
      trans.b   = vif.b;
      trans.cin = vif.cin;
      @(posedge vif.clk); // Next clock edge where registered outputs settle
      trans.sum  = vif.sum;
      trans.cout = vif.cout;
      mon2scb.put(trans);
      trans.display("monitor");
    end
  endtask
endclass
