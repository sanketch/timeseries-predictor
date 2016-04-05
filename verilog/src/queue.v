module queue(
  input Clk,
  input Rst,

  input [31:0] si_in;
  input [31:0] ei_in;
  input [31:0] id_in;
  input load;

  output [31:0] si_out;
  output [31:0] ei_out;
  output [31:0] id_out;
  input pop;

  output full;
);

reg [31:0] si_buff [255:0];
reg [31:0] ei_buff [255:0];
reg [31:0] id_buff [255:0];
reg [8:0] head, tail;

assign full = (head[7:0] == tail[7:0] && head[8] != tail[8]) ? 1 : 0;

assign si_out = si_buff[head];
assign ei_out = ei_buff[head];
assign id_out = id_buff[head];

always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
    head = 0;
    tail = 0;
  end
  else
  begin
    if (load && !full)
    begin
      si_buff[tail] <= si_in;
      ei_buff[tail] <= ei_in;
      id_buff[tail] <= id_in;
    end
    if (pop)
    begin
      head <= head+1;
    end
  end
  
end

endmodule
