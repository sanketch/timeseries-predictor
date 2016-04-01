module chunker(
  input Clk,
  input Rst,

  //Going to allow 4 variable query/retrievals for parallel access, if
  //desired.
  output [31:0] varIndx1,
  input  [31:0] var1,

  output [31:0] varIndx2,
  input  [31:0] var2,

  output [31:0] varIndx3,
  input  [31:0] var3,

  output [31:0] varIndx4,
  input  [31:0] var4,

  //Start when told
  input start,

  //Yell when done
  output done,
  
  //Actually get the data out -- how?
)

//Parameters controlling chunk and data size.
parameter nChunks = 10;
parameter nData = 20;


localparam chunkSize = nData/nChunks;
localparam IDLE     = 2'b00;
localparam INDEX    = 2'b01;
localparam MEAN     = 2'b10;
localparam VARIANCE = 2'b11;
reg [1:0] state;

//Doing 2n so neither side is left out of uneven regression
reg [31:0] varianceResults [nChunks*2-1:0];

//Variables for indexing iteration
reg [31:0] index;
reg [31:0] index_last;
reg [31:0] index_id;
reg        index_up;

//Queue
reg         qLoad, qPop;
// reg  [31:0] qSin, qEin, qIDin; //Can just pipe the index stuff right in
wire        qFull;
wire [31:0] qSout, qEout, qIDout;
queue q (.Clk(Clk), .Rst(Rst),
         .si_in(index_last), .ei_in(index), .id_in(index_id),
         .si_out(qSout), .ei_out(qEout), .id_out(qIDout),
         .load(qLoad), .pop(qPop),
         .full(qFull));


always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
    state <= IDLE;
    index <= chunkSize;
    index_prev <= 0;
    index_up <= 1'b1;
    index_id <= 0;
  end
  else
  begin
    case (state):
      IDLE:
      begin
        if (start)
        begin
          qLoad <= 1;
          state <= INDEX;
        end
      end
      INDEX:
      begin
        //If we've gone there and back, done.
        if (index_prev-chunkSize < 0 && !index_up)
        begin
          state <= MEAN;
          qLoad <= 0;
        end
        //If not done, keep loading.
        else
        begin
          index_id <= index_id+1;
          if (index+chunkSize > nData && index_up)
          begin
            //Change directions
            index_up <= 0;
            index <= nData;
          end
          else
          begin
            if (index_up)
              index <= index + chunkSize;
              index_prev <= index;
            else
              index_prev <= index_prev - chunkSize;
              index <= index_prev;
          end
        end
      end
      VARIANCE:
      begin
      end
    endcase
  end
end

endmodule
