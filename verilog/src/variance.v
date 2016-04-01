module var(
  input Clk,
  input Rst,

  //Take in start, end index
  input [31:0] si,
  input [31:0] ei,

  //Value retrieval
  output reg [31:0] index,
  input [31:0] value,

  //Start, done, output
  input start,
  output reg done,
  output reg [31:0] variance,
  output reg [31:0] mean
);


localparam IDLE     = 2'b00;
localparam MEAN     = 2'b01;
localparam VARIANCE = 2'b10;
reg [1:0] state;

reg [31:0] sum;

wire [31:0] n;
assign n = ei-si;

always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
    state <= IDLE;
  end
  else
  begin
    case (state)
    IDLE:
    begin
      if (start)
      begin
        state <= MEAN;
        index <= si;
        sum <= 0;
        variance <= 0;
      end
    end
    MEAN:
    begin
      if (index == ei)
      begin
        mean <= sum/n;
        state <= VARIANCE;
        index <= si;
        sum <= 0;
      end
      else
      begin
        sum <= sum + value;
        index <= index + 1;
      end
    end
    VARIANCE:
    begin
      if (index == ei)
      begin
        variance <= sum/n;
        state <= IDLE;
      end
      else
      begin
        sum <= sum + (value > mean ? value-mean : mean-value);
        index <= index + 1;
      end
    end
    endcase
  end
end

endmodule
