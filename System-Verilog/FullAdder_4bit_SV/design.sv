module full_adder (
    input  logic       clk,
    input  logic       rst,
    input  logic       valid,
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  logic [4:0] tmp_out;

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      tmp_out <= 5'b00000;
    else if (valid)
      tmp_out <= a + b + cin;
  end

  assign {cout, sum} = tmp_out;
endmodule
