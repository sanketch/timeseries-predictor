//Given a start index and end index, calculates the linear fit of the data and
//then the average of the square of the deviation from the linear fit.
module  LinFitDev(
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
  output reg [31:0] deviation,
  output reg [31:0] mean
);


localparam IDLE       = 2'b00;
localparam MEAN       = 2'b01;
localparam REGRESSION = 2'b10;
localparam REGVAR     = 2'b11;
reg [1:0] state;

reg [31:0] sum_x, sum_y, mean_x, mean_y, slope, intercept;

wire [31:0] n;
assign n = ei-si;

always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
    state <= IDLE;
    done <= 1;
  end
  else
  begin
    case (state)
    IDLE:
    begin
      if (start==1)
      begin
        state <= MEAN;
        index <= si;
        sum_x <= 0;
        sum_y <= 0;
        done <= 0;
        slope <= 0;
        intercept <= 0;
      end
    end
    MEAN:
    begin
      if (index == ei)
      begin
        mean_x <= sum_x/n;
        mean_y <= sum_y/n;
        state <= REGRESSION;
        index <= si;
        sum_x <= 0;
        sum_y <= 0;
      end
      else
      begin
        sum_x <= sum_x + index;
        sum_y <= sum_y + value;
        index <= index + 1;
      end
    end
    REGRESSION:
    begin
      if (index == ei)
      begin
        state <= REGVAR;
        index <= si;
        slope <= sum_y/sum_x;
        intercept <= mean_y-(sum_y/sum_x)*mean_x;
        sum_x <= 0;
        sum_y <= 0;
      end
      else
      begin
        sum_y <= sum_y + (index-mean_x)*(value-mean_y);
        sum_x <= sum_x + (index-mean_x)*(index-mean_x);
        index <= index + 1;
      end
    end
    REGVAR:
    begin
      if (index == ei)
      begin
        done <= 1;
        state <= IDLE;
        deviation <= sum_x/n;
      end
      else
      begin
        sum_x <= (((index*slope) + intercept) - value)**2;
        index <= index+1;
      end
    end
    endcase
  end
end

endmodule
