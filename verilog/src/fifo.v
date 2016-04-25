module fifo(
  clk, rst,

  val_in, push,

  val_out, pop, empty, full
);
input clk, rst;

parameter DEPTH_BITS = 4;
parameter DATA_WIDTH = 16;

localparam DEPTH = 1 << DEPTH_BITS;

input [DATA_WIDTH-1:0] val_in;
input push, pop;

output [DATA_WIDTH-1:0] val_out;
output empty, full;

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
reg [DEPTH_BITS:0] head, tail; //One extra bit to track empty/full
wire same_loc;

assign same_loc = (head[DEPTH_BITS-1:0] == tail[DEPTH_BITS-1:0]) ? 1 : 0;
assign full = (same_loc && head[DEPTH_BITS] != tail[DEPTH_BITS]) ? 1 : 0;
assign empty= (same_loc && head[DEPTH_BITS] == tail[DEPTH_BITS]) ? 1 : 0;
assign val_out = mem[tail];

always @ (posedge clk, negedge rst)
begin
  if (!rst)
  begin
    head <= 0;
    tail <= 0;
  end
  else
  begin
    if (push && !full)
    begin
      mem[head] <= val_in;
      head <= head + 1'b1;
    end
    if (pop && !empty)
    begin
      tail <= tail + 1'b1;
    end
  end
end

endmodule
