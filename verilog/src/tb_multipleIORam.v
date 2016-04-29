`timescale 1ns/100ps

module tb_multipleIOram;

parameter clk_cycle = 2;
parameter DATAWIDTH = 2;
parameter DEPTHBITS = 2;
parameter DATADEPTH = 1 << DEPTHBITS;
parameter [DATAWIDTH-1:0] DATA [0:DATADEPTH-1] = '{2'b00, 2'b01, 2'b10, 2'b11};

reg clk;
reg  [DATADEPTH-1:0] in1;
wire [DATAWIDTH-1:0] out1;
multipleIOram #(.DATAWIDTH(DATAWIDTH), .DEPTHBITS(DEPTHBITS), .DATA(DATA))
  dut (.clk(clk), .in1(in1), .out1(out1));

always #(clk_cycle/2) clk = ~clk;

initial
begin
  clk = 0;
  in1 = 0;
  #5
  in1 = 1;
  #5
  in1 = 2;
  #5
  in1 = 3;
end
endmodule
