// Ram with a ton of in-outs, works in one clock. Read-only.

module multipleIOram(
  clk,

  in1, out1,
  in2, out2,
  in3, out3, 
  in4, out4,
  in5, out5,
  in6, out6,
  in7, out7,
  in8, out8,
  in9, out9,
  in10, out10,
  in11, out11,
  in12, out12,
  in13, out13,
  in14, out14,
  in15, out15,
  in0, out0
);

parameter DATAWIDTH = 2;
parameter DEPTHBITS = 3;
parameter DATADEPTH = 1 << DEPTHBITS;
parameter [DATAWIDTH-1:0] DATA [0:DATADEPTH-1] = '{2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10};

input clk;
input [DEPTHBITS-1:0] in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in0;
output wire [DATAWIDTH-1:0] out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15, out0;

assign out1 = DATA[in1];
assign out2 = DATA[in2];
assign out3 = DATA[in3];
assign out4 = DATA[in4];
assign out5 = DATA[in5];
assign out6 = DATA[in6];
assign out7 = DATA[in7];
assign out8 = DATA[in8];
assign out9 = DATA[in9];
assign out10 = DATA[in10];
assign out11 = DATA[in11];
assign out12 = DATA[in12];
assign out13 = DATA[in13];
assign out14 = DATA[in14];
assign out15 = DATA[in15];
assign out0 = DATA[in0];

endmodule
