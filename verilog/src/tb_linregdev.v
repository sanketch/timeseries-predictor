`timescale 1ns / 100ps

module tb_linregdev;

parameter clk_cycle = 2;

reg clk, rst;
always #(clk_cycle/2) clk = ~clk;

reg [31:0] si, ei;
reg start;
reg [31:0] data [0:9];
wire [31:0] index, deviation, mean, value;
wire done;

assign value = data[index];

LinRegDev dut(
  .Clk(clk), .Rst(rst),
  .si(si), .ei(ei),
  .index(index), .deviation(deviation), .mean(mean), .value(value),
  .start(start), .done(done)
);

initial
begin
  //Initialize
  si = 0;
  ei = 10;
  clk = 0;
  start = 0;
  rst = 0;
  data[0] = 33;
  data[1] = 23;
  data[2] = 15;
  data[3] = 12;
  data[4] = 82;
  data[5] = 64;
  data[6] = 53;
  data[7] = 58;
  data[8] = 66;
  data[9] = 39;

  #4
  rst = 1;
  #4

  start = 1;
  #4
  start = 0;
end

endmodule
