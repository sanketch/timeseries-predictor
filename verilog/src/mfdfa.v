module mfdfa(
  input Clk,
  input Rst,
);

parameter nStocks = 301;
parameter nChunkSizes = 3;
reg [31:0] chunkSizes [nChunkSizes-1:0] = {10, 20, 30};
reg [31:0] chunkResults [nChunkSizes-1:0];
reg [31:0] stocks [nStocks-1:0] = {10768, 10519, 10567, 10613, 10672, 10591, 10592, 10580, 10597, 10458, 10252, 10226, 10117, 10112, 10103, 10187, 10301, 10150, 10075, 10053, 9669, 9691, 9676, 9610, 9469, 9688, 9604, 9626, 9812, 9664, 9399, 9370, 9427, 9499, 9501, 9402, 9660, 9635, 9448, 9643, 9734, 9409, 9342, 9999, 9944, 10142, 9630, 9679, 9666, 9713, 9952, 9739, 9996, 9853, 9696, 9645, 10070, 10271, 10535, 10526, 10732, 10874, 10682, 10803, 10861, 10723, 10733, 10603, 10898, 11134, 11049, 11248, 11318, 11617, 11562, 11823, 11828, 11903, 11520, 11628, 11734, 11830, 11781, 11803, 11888, 11775, 11930, 11878, 11729, 11369, 11417, 11234, 11572, 11611, 11677, 12057, 12106, 12092, 12200, 12257, 12118, 11950, 12053, 11927, 11455, 11528, 11908, 11550, 11376, 11377, 11173, 11104, 11186, 11021, 11179, 11160, 11212, 10950, 11078, 11131, 11078, 11038, 10958, 11030, 10906, 11244, 11471, 11500, 11432, 11340, 11521, 11345, 11392, 11641, 11628, 11531, 11421, 11257, 11015, 11231, 10927, 11037, 11234, 10772, 11276, 11329, 11292, 10969, 10374, 10312, 10576, 11265, 11501, 11650, 11716, 11596, 11515, 11524, 11349, 11972, 11552, 11513, 11540, 11464, 11844, 12130, 12237, 12299, 12338, 12277, 12450, 12516, 12522, 13075, 13207, 12962, 12851, 12682, 12561, 12566, 12328, 12007, 12257, 12569, 12600, 12644, 12660, 12542, 12453, 12675, 12750, 12811, 12703, 12761, 12660, 12788, 12730, 12760, 12692, 12717, 12859, 12888, 12742, 12780, 12865, 12936, 13012, 12996, 13053, 13028, 13178, 13204, 12962, 13254, 13138, 13006, 13007, 13019, 12877, 12894, 12601, 12586, 12632, 12762, 12526, 12501, 12580, 12869, 12894, 12515, 12863, 13056, 13265, 13028, 12966, 12862, 12691, 12760, 12475, 12617, 12678, 12630, 12685, 12710, 12656, 12560, 12601, 12735, 12532, 12425, 12443, 12637, 12325, 12424, 12338, 12669, 12721, 12590, 12749, 12847, 12704, 12495, 12359, 12445, 12224, 12451, 12714, 12660, 12641, 12854, 12936, 12909, 12846, 13041, 12879, 13216, 13300, 12949, 12844, 12871, 12783, 12708, 12646, 12488, 12202, 11972, 11893, 11994, 11956, 11865, 11863, 11716, 11890, 11531, 10914, 11310, 11298, 11240, 10955, 10872, 10599};

reg [3:0] state;
parameter MEAN_CALC            = 4'b0000;
parameter PROFILE_CONSTRUCTION = 4'b0001;
parameter CHUNKING             = 4'b0010;
parameter CHUNK_REG            = 4'b0011;
parameter LOG_RESULTS          = 4'b0111;

always @ (posedge Clk, negedge Rst)
begin
  if (!Rst)
  begin
  end
  else
  begin
    case (state)
      MEAN_CALC:
      begin
        //Turns out we don't need to do this.
      end
      PROFILE_CONSTRUCTION:
      begin
        //Or this.
      end
      CHUNKING:
      begin
        
      end
      LOG_RESULTS
      begin
      end
    endcase
  end
end

endmodule
