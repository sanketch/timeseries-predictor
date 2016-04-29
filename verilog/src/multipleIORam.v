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
  in16, out16
);

parameter DATAWIDTH = 2;
parameter DEPTHBITS = 3;
parameter DATADEPTH = 1 << DEPTHBITS;
parameter [DATAWIDTH-1:0] DATA [0:DATADEPTH-1] = '{2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10, 2'b10};

input clk;
input [DEPTHBITS-1:0] in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16;
output reg [DATAWIDTH-1:0] out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15, out16;

reg [DATAWIDTH-1:0] mem [0:DATADEPTH-1];

always @ (posedge clk)
begin
  out1  <= mem[in1];
  out2  <= mem[in2];
  out3  <= mem[in3];
  out4  <= mem[in4];
  out5  <= mem[in5];
  out6  <= mem[in6];
  out7  <= mem[in7];
  out8  <= mem[in8];
  out9  <= mem[in9];
  out10 <= mem[in10];
  out11 <= mem[in11];
  out12 <= mem[in12];
  out13 <= mem[in13];
  out14 <= mem[in14];
  out15 <= mem[in15];
  out16 <= mem[in16];
end
endmodule
