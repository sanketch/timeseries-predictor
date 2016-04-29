`timescale 1ns /100ps

module tb_master;

parameter clk_cycle = 2;
reg clk, rst;
always #(clk_cycle/2) clk = ~clk;

reg start;

master dut(
  .clk(clk), .rst(rst), .start(start)
  );

initial
begin
  clk = 0;
  rst = 0;
  start = 0;
  #4
  rst = 1;
  #40
  start = 1;
  #4
  start = 0;
end
endmodule
