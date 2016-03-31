module iter(
  input Clk,
  input Rst,
  
  //Control signals and output
  input  start,
  output done,
  output [31:0] final_value,
  
  //Start and end indices
  input [31:0] s_index,
  input [31:0] e_index,

  //Value retrieval
  output [31:0] v_index,
  input  [31:0] value,

  //Whatever operation is being done
  output [31:0] to_op,
  input  [31:0] from_op,
);

reg [31:0] v_index;
reg running;
reg done;

assign final_value = running ? from_op : final_value;
assign to_op = value;

always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
    v_index <= 31'h00000000;
    running = 0;
    done = 0;
  end
  else
  begin
    if (running && v_index == e_index)
    begin
      done <= 1;
      running <= 0;
    end
    else if (!running && start)
    begin
      running <= 1;
      done <= 0;
    end
    else if (running)
    begin
      running <= 1;
    end
  end
end
endmodule
