module master(
  clk, rst

  //whatever else is needed?
);

parameter VCHANNELBITS = 3; //Number of Virtual Channel bits (for FIFO depth calculation)
parameter VCHANNELS = 1 << VCHANNELBITS;
parameter SLAVEBITS = 2; //Number of bits for the slave (In this case, 2 bits = 4 slaves)
parameter SLAVES = 1 << SLAVEBITS;
parameter N_SIZES = 4;
parameter [31:0] SIZES [0:N_SIZES-1] = '{10, 20, 50, 100};

reg [31:0] N_CHUNKS [0:N_SIZES-1];

reg [31:0] N_CHUNKS_COMPLETED [0:N_SIZES-1];

reg [31:0] N_CHUNKS

////////////////////////////////////////////////////////////////////////
//Fifos go here!
////////////////////////////////////////////////////////////

//IndexFifo: Holds 3 pieces of info:
 //   |-chunkID-|-------indexStart---------|--------indexEnd--------|
 //   73        64                         32                       0
 //Doesn't need to be too deep - Processing a new chunk shouldn't take more
 //than 2 or 3 clocks, so if the assigner manages to empty it we can still
 //fill it again pretty quickly.
  reg  [73:0] indexFifoIn;
  reg         indexFifoPush;
  reg         indexFifoPop;
  wire [73:0] indexFifoOut;
  wire        indexFifoEmpty;
  wire        indexFifoFull;
  fifo #(.DEPTH_BITS(4), .DATA_WIDTH(73))
    indexFifo  ( .clk(clk), .rst(rst)
                 .val_in(indexFifoIn), .push(indexFifoPush),
                 .val_out(indexFifoOut), .pop(indexFifoPop),
                 .empty(indexFifoEmpty), full(indexFifoFull)
               );

//virChanFifo: Holds the VCs that are free. Needs to be as deep as there are
 //channels.  Otherwise, all good.  Don't need tracking full, since a proper
 //implementation shouldn't need to - but doing so anyway for debugging
  reg  [VCHANNELBITS-1:0] virChanFifoIn;
  reg                     virChanFifoPush;
  reg                     virChanFifoPop;
  wire [VCHANNELBITS-1:0] virChanFifoOut;
  wire                    virChanFifoEmpty;
  wire                    virChanFifoFull;
  fifo #(.DEPTH_BITS(VCHANNELBITS), .DATA_WIDTH(VCHANNELBITS))
    virChanFifo( .clk(clk), .rst(rst)
                 .val_in(virChanFifoIn), .push(virChanFifoPush),
                 .val_out(virChanFifoOut), .pop(virChanFifoPop),
                 .emptyvirChanFifoEmpty(), full(virChanFifoFull)
               );

//slaveFifo
 //Keeps track of available slaves.  Same as virChanFifo, just need to make
 //sure we have enough room for all the slaves and a width for their IDs.
  reg  [SLAVEBITS-1:0] slaveFifoIn;
  reg                  slaveFifoPush;
  reg                  slaveFifoPop;
  wire [SLAVEBITS-1:0] slaveFifoOut;
  wire                 slaveFifoEmpty;
  wire                 slaveFifoFull;
  fifo #(.DEPTH_BITS(SLAVEBITS), .DATA_WIDTH(SLAVEBITS))
    slaveFifo( .clk(clk), .rst(rst)
               .val_in(slaveFifoIn), .push(slaveFifoPush),
               .val_out(slaveFifoOut), .pop(slaveFifoPop),
               .emptyslaveFifoEmpty(), full(slaveFifoFull)
             );


endmodule
