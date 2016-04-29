module master(
  clk, rst,
  start, done, clear,
  //whatever else is needed?
  endIndex,
  creditGetEn,
  creditGet,
  creditPutEn,
  creditPut,
  flitReceiveEn,
  flitReceive,
  flitSendEn,
  flitSend
);

////////////////////////////////////////////////////////////////////////////////
// Variable declaration
////////////////////////////////////////////////////////////////////////////

/////////
// Parameters
////
parameter                      VCHANNELBITS        = 3; //Number of Virtual Channel bits 
                                                        //(for FIFO depth calculation)
parameter                      VCHANNELS           = 1 << VCHANNELBITS;
parameter                      DESTBITS            = 3;
parameter                      NSLAVEBITS          = 2; //Number of bits for the slave 
                                                        //(In this case, 2 bits = 4 slaves)
parameter                      NSLAVES             = 1 << NSLAVEBITS;
parameter                      FLITDATAWIDTH       = 64;
parameter                      NSIZESBITS          = 3;
parameter                      N_SIZES             = 4;
parameter   [31:0]             SIZES [0:N_SIZES-1] = '{10, 20, 50, 100};


/////////
// Local Parameters
////
 //Global
  localparam flit_width        = 2 + VCHANNELBITS + DESTBITS + FLITDATAWIDTH;
  localparam credit_width      = 1 + VCHANNELBITS;

 //Controller
  localparam CONTROLLERSETUP   = 2'b00;
  localparam CONTROLLERREADY   = 2'b01;
  localparam CONTROLLERWORKING = 2'b10;
  localparam CONTROLLERDONE    = 2'b11;

/////////
// I/O
////

input  wire [31:0]             endIndex;
input  wire                    clk, rst, start, clear;
input  wire [flit_width-1:0]   flitReceive;
input  wire [credit_width-1:0] creditGet;
output reg  [flit_width-1:0]   flitSend;
output wire [credit_width-1:0] creditPut;
output wire                    creditPutEn,
                               flitReceiveEn;
output reg                     creditGetEn,
                               flitSendEn;
output reg                     done;

/////////
// Local Variables
////
 
 //Section Chunking
  reg  [NSIZESBITS-1:0]   currentSizeID;        //Keeps track of which chunk we're processing
  reg                     chunkingDone;
  reg                     chunkingReset;
  reg                     chunking;             //Whether we're currently chunking.
  reg                     chunkingReverse;      //Reversing chunking? (1 is yes)
  reg  [31:0]             chunkingN1;           //Index we're currently at
  reg  [31:0]             chunkingN2;           //previous N

 //Job Assignment
  reg                     jobAssign;            //Whether to try to assign jobs
  reg                     jobFirstPacket;
  reg  [DESTBITS-1:0]     tempAddr;

 //Response Collection
  reg  [31:0]             nChunks              [0:N_SIZES-1];
  reg  [31:0]             chunkSums            [0:N_SIZES-1];
  wire                    valid_flit;
  wire [3:0]              flitReceiveID;
  wire [31:0]             flitReceiveResult;
  wire [VCHANNELBITS-1:0] flitReceiveVirC;
  wire [NSLAVEBITS-1:0]   flitReceiveSlave;

 //Controller
  reg  [1:0]              controllerState;

 //Fifos
  //index
  wire [66:0]             indexFifoIn;
  reg                     indexFifoPush;
  reg                     indexFifoPop;
  wire [66:0]             indexFifoOut;
  wire                    indexFifoEmpty;
  wire                    indexFifoFull;
  //virChan
  reg  [VCHANNELBITS-1:0] virChanFifoIn;
  reg                     virChanFifoPush;
  reg                     virChanFifoPop;
  wire [VCHANNELBITS-1:0] virChanFifoOut;
  wire                    virChanFifoEmpty;
  wire                    virChanFifoFull;
  //slave
  reg  [NSLAVEBITS-1:0]   slaveFifoIn;
  reg                     slaveFifoPush;
  reg                     slaveFifoPop;
  wire [NSLAVEBITS-1:0]   slaveFifoOut;
  wire                    slaveFifoEmpty;
  wire                    slaveFifoFull;

/////////
// Assignment statements
////
 
 //Chunking
   //Always want indexFifoOut to be a combination of the three
  assign indexFifoIn       = {currentSizeID, chunkingN1, chunkingN2};

 //Response collection
  assign validFlit         = flitReceive[FLITDATAWIDTH-1];
   //Respond with a credit whenever information received
  assign creditPut         = {1'b1, flitReceiveVirC};
  assign creditPutEn       = validFlit;
  assign flitReceiveEn     = 1'b1;
  assign flitReceiveID     = flitReceive[35:32];
  assign flitReceiveResult = flitReceive[31:0];
  assign flitReceiveVirC   = flitReceive[FLITDATAWIDTH + VCHANNELBITS - 1:FLITDATAWIDTH];
  assign flitReceiveSlave  = flitReceive[35+NSLAVEBITS:36];


////////////////////////////////////////////////////////////////////////////////
// Module instantiation
////////////////////////////////////////////////////////////////////////////
//IndexFifo: Holds 3 pieces of info:
 //   |-chunkID-|-------indexStart---------|--------indexEnd--------|
 //   67        64                         32                       0
 //Doesn't need to be too deep - Processing a new chunk shouldn't take more
 //than a clock, so if the assigner manages to empty it we can still
 //fill it again pretty quickly.
  fifo #(.DEPTH_BITS(4), .DATA_WIDTH(67))
    indexFifo  ( .clk(clk), .rst(rst),
                 .val_in(indexFifoIn), .push(indexFifoPush),
                 .val_out(indexFifoOut), .pop(indexFifoPop),
                 .empty(indexFifoEmpty), .full(indexFifoFull)
               );

//virChanFifo: Holds the VCs that are free. Needs to be as deep as there are
 //channels.  Otherwise, all good.  Don't need tracking full, since a proper
 //implementation shouldn't need to - but doing so anyway for debugging
  fifo #(.DEPTH_BITS(VCHANNELBITS), .DATA_WIDTH(VCHANNELBITS))
    virChanFifo( .clk(clk), .rst(rst),
                 .val_in(virChanFifoIn), .push(virChanFifoPush),
                 .val_out(virChanFifoOut), .pop(virChanFifoPop),
                 .empty(virChanFifoEmpty), .full(virChanFifoFull)
               );

//slaveFifo
 //Keeps track of available slaves.  Same as virChanFifo, just need to make
 //sure we have enough room for all the slaves and a width for their IDs.
  fifo #(.DEPTH_BITS(NSLAVEBITS), .DATA_WIDTH(NSLAVEBITS))
    slaveFifo( .clk(clk), .rst(rst),
               .val_in(slaveFifoIn), .push(slaveFifoPush),
               .val_out(slaveFifoOut), .pop(slaveFifoPop),
               .empty(slaveFifoEmpty), .full(slaveFifoFull)
             );



////////////////////////////////////////////////////////////////////////
//  Controller
//    Controls all of it - preloads fifo, starts chunking, starts job
//    assigner, starts LinRegVar on results (if we ever get there)
///////////////////////////////////////////////////
always @ (posedge clk, negedge rst)
begin
  if (!rst)
  begin
    controllerState <= CONTROLLERSETUP; 
    virChanFifoIn   <= 0;
    slaveFifoIn     <= 0;
    slaveFifoPush   <= 1;
    virChanFifoPush <= 1;
    done            <= 0;
  end
  else
  begin
  case (controllerState)
    CONTROLLERSETUP:
    begin
      if (!slaveFifoFull)
        slaveFifoIn   <= slaveFifoIn + 1;
      else 
        slaveFifoPush <= 0;
      if (!virChanFifoFull)
        virChanFifoIn <= virChanFifoIn + 1;
      else
        virChanFifoPush <= 0;
      if (slaveFifoFull && virChanFifoFull)
        controllerState <= CONTROLLERREADY;
    end
    CONTROLLERREADY:
    begin
      if (start)
      begin
        chunking        <= 1;
        jobAssign       <= 1;
        controllerState <= CONTROLLERWORKING;
      end
    end
    CONTROLLERWORKING:
    begin
      if (slaveFifoFull && virChanFifoFull && indexFifoEmpty && !chunking)
      begin
        controllerState <= CONTROLLERDONE;
        done            <= 1;
        jobAssign       <= 0;
      end
	  if (valid_flit)
	  begin
		nChunks[flitReceiveID]   <= nChunks[flitReceiveID] + 1;
		chunkSums[flitReceiveID] <= nChunks[flitReceiveID] + flitReceiveResult;
		virChanFifoIn            <= flitReceiveVirC;
		virChanFifoPush          <= 1;
		slaveFifoIn              <= flitReceiveSlave;
		slaveFifoPush            <= 1;
	  end
	  else
	  begin
		slaveFifoPush <= 0;
		virChanFifoPush <= 0;
	  end
    end
    CONTROLLERDONE:
    begin
      if (clear)
      begin
        controllerState <= CONTROLLERSETUP;
        done            <= 0;
      end
    end
  endcase
  end
end

////////////////////////////////////////////////////////////////////////
//Job Assignment goes here
////////////////////////////////////////////////////////////
always @ (posedge clk, negedge rst)
begin
  if (!rst)
  begin
    jobFirstPacket <= 1;
	slaveFifoPop   <= 0;
	virChanFifoPop <= 0;
	indexFifoPop   <= 0;
  end
  else
  begin
    if (jobFirstPacket)
    begin
      if (jobAssign && 
          !slaveFifoEmpty && !virChanFifoEmpty && !indexFifoEmpty)
      begin
        tempAddr        = slaveFifoOut;
        flitSend       <= {1'b1, 1'b0, tempAddr, virChanFifoOut, indexFifoOut[63:0]};
        jobFirstPacket <= 0;
        flitSendEn     <= 1;
        creditGetEn    <= 1;
		slaveFifoPop   <= 1;
        virChanFifoPop <= 1;
        indexFifoPop   <= 1;
      end
      else
      begin
        flitSendEn      <= 0;
        creditGetEn     <= 0;
      end
    end
    else
    begin
      flitSend[flit_width-1:FLITDATAWIDTH] <= {1'b1, 1'b1, tempAddr, virChanFifoOut};
      flitSend[3:0]                        <= {indexFifoOut [66:64]};
      slaveFifoPop                         <= 0;
      virChanFifoPop                       <= 0;
      indexFifoPop                         <= 0;
	  jobFirstPacket                       <= 1;
    end
  end
end

/////////////////////////////////////////////////////////////////////////
// Chunking-related stuff
/////////////////////////////////////////////////////////
//   Always moving as following...
//
//   |              (chunk)             |
//   |-------------|=========|----------|
//   |             N2        N1         |
//   0                                  endIndex
//        ...Regardless of which way, up or down.  N1 is start, N2 is end


//Chunking clock operations
always @ (posedge clk, negedge rst)
begin
  if (!rst || chunkingReset)
  begin
    currentSizeID   <= 0;
    chunking        <= 0;
    chunkingReverse <= 0;
    chunkingN2      <= SIZES[0];
    chunkingN1      <= 0;
    indexFifoPush   <= 0;
    chunkingReset   <= 0;
    chunkingDone    <= 0;
  end
  else
  begin
    if (chunking && !indexFifoFull)
    begin
      if (chunkingReverse)
      begin
        if (chunkingN2 - SIZES[currentSizeID] < 0)
        begin
          if (currentSizeID+1 < N_SIZES)
          begin  
            //Next pair won't work, set up next ID
            chunkingReverse <= 0;
            chunkingN1      <= SIZES[currentSizeID+1];
            chunkingN2      <= 0;
            indexFifoPush   <= 1;
            currentSizeID   <= currentSizeID + 1;
          end
          else
          begin
            //Done chunking
            chunking        <= 0;
            indexFifoPush   <= 0;
            chunkingDone    <= 1;
          end
        end
        //Continue with chunking backwards
        else
        begin
          chunkingN2    <= chunkingN2 - SIZES[currentSizeID];
          chunkingN1    <= chunkingN2;
          indexFifoPush <= 1;
        end
      end
      else
      begin
        if (chunkingN1 + SIZES[currentSizeID] > endIndex)
        begin
          //Next pair won't work, set up for going in reverse
          chunkingReverse <= 1;
          chunkingN2      <= endIndex - SIZES[currentSizeID];
          chunkingN1      <= endIndex;
          indexFifoPush   <= 1;
        end
        //Continue with chunking
        else
        begin
          chunkingN1      <= chunkingN1 + SIZES[currentSizeID];
          chunkingN2      <= chunkingN1;
          indexFifoPush   <= 1;
        end
      end
    end
    else
    begin
      //Just in case - make sure nothing is written next go
      indexFifoPush <= 0;
    end
  end
end
endmodule
