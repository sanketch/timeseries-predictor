`timescale 1ns / 100ps

module variance_tb;

parameter clk_cycle = 2;

reg clk, rst;
always #(clk_cycle/2) clk = ~clk;

reg [31:0] si, ei;
reg start;
reg [31:0] data [0:9] = '{3, 17, 11, 5, 9, 10, 11, 15, 8, 12};
wire [31:0] index, variance, mean, value;
wire done;

assign value = data[index];

var dut(
  .Clk(clk), .Rst(rst),
  .si(si), .ei(ei),
  .index(index), .variance(variance), .mean(mean), .value(value),
  .start(start), .done(done)
);

initial
begin
  //Initialize
  si = 0;
  ei = 10;
  clk = 0;
  start = 0;
  rst = 1;

  #4
  rst = 0;
  #4

  start = 1;
  #4
  start = 0;
end

endmodule
