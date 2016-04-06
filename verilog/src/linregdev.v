//Given a start index and end index, calculates the linear fit of the data and
//then the average of the square of the deviation from the linear fit.
module  LinRegDev(
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
localparam REGRESSION = 2'b10;
localparam REGVAR     = 2'b11;
reg [1:0] state;

reg [31:0] mean_x, mean_y, mean_xy, mean_xx, slope, intercept, sum;

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
        state <= REGRESSION;
        index <= si;
        mean_x <= 0;
        mean_y <= 0;
        mean_xy <= 0;
        mean_xx <= 0;
        done <= 0;
        slope <= 0;
        intercept <= 0;
      end
    end
    REGRESSION:
    begin
      if (index == ei)
      begin
        state <= REGVAR;
        index <= si;
        mean_x <= mean_x/n;
        mean_y <= mean_y/n;
        mean_xx <= mean_xx/n;
        mean_xy <= mean_xy/n; 
        slope <= (mean_xy - mean_x*mean_y/n)/(mean_xx - mean_x*mean_x/n);
        intercept <= (mean_y-(mean_xy - mean_x*mean_y/n)/
		                     (mean_xx - mean_x*mean_x/n)*mean_x)/n;
        sum <= 0;
      end
      else
      begin
        mean_x <= mean_x + index;
        mean_y <= mean_y + value;
        mean_xy <= mean_xy + index*value;
        mean_xx <= mean_xx + index*index;
        index <= index + 1;
      end
    end
    REGVAR:
    begin
      if (index == ei)
      begin
        done <= 1;
        state <= IDLE;
        deviation <= sum/n;
      end
      else
      begin
        sum <= (((index*slope) + intercept) - value)**2;
        index <= index+1;
      end
    end
    endcase
  end
end

endmodule
