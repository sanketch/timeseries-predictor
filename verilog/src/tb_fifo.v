`timescale 1ns/100ps

module tb_fifo;

parameter clk_cycle = 2;
parameter DEPTH_BITS = 3;
parameter DATA_WIDTH = 8;

reg clk, rst;

always #(clk_cycle/2) clk = ~clk;

reg  [DATA_WIDTH-1:0] val_in;
wire [DATA_WIDTH-1:0] val_out;
reg  pop, push;
wire full, empty;

fifo #(.DEPTH_BITS(DEPTH_BITS), .DATA_WIDTH(DATA_WIDTH)) 
  dut (.clk(clk), .rst(rst), .val_in(val_in), .val_out(val_out), 
       .push(push), .pop(pop), .full(full), .empty(empty));

initial
begin
  rst = 0;
  val_in = 5;
  push = 0;
  pop = 0;
  clk = 0;
  #4
  rst = 1;
  push = 1;
  #4
  push = 0;
  #4
  push = 1;
  #30;
  push = 0;
  pop = 1;
  #30;
end

endmodule
