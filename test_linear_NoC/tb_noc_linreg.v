
`include "connect_parameters.v"

module tb_noc_linreg();
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2*HalfClkPeriod;

  // non-VC routers still reeserve 1 dummy bit for VC.
  localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  localparam credit_port_width = 1 + vc_bits; // 1 valid bit
 
  reg Clk;
  reg Rst_n;

  // send_flit is used to signal that specific core wants to send a flit out, one entry for each core
  reg send_flit [0:`NUM_USER_SEND_PORTS-1];
  
  // array of actual outgoing flits, one entry for each core,
  // each entry is flit_port_width for data and routing
  reg [flit_port_width-1:0] flit_in [0:`NUM_USER_SEND_PORTS-1];

  // send_credits is used to signal that a core has received a flit
  wire send_credit [0:`NUM_USER_RECV_PORTS-1];

  // the actual credit that is sent by each core
  wire [credit_port_width-1:0] credit_in [0:`NUM_USER_RECV_PORTS-1];

  // output wires

  // credit received by each core is stored here
  wire [credit_port_width-1:0] credit_out [0:`NUM_USER_SEND_PORTS-1];

  // flit received by each core is stored here
  wire [flit_port_width-1:0] flit_out [0:`NUM_USER_RECV_PORTS-1];

  wire accept_credit [0:`NUM_USER_SEND_PORTS-1];
  
  reg [dest_bits-1:0] dest;
  reg [vc_bits-1:0]   vc;
  reg [`FLIT_DATA_WIDTH-1:0] data;

  wire [flit_port_width-1:0] flit = flit_in[0];
  reg [31:0] slave0Index;
  reg [31:0] slave0Value;
  
  // Generate Clock
  initial Clk = 0;
  always #(HalfClkPeriod) Clk = ~Clk;
  integer i;
  initial
  begin
   
    $display("---- Performing Reset ----");
    Rst_n = 0; // perform reset (active low) 
    #(5*ClkPeriod+HalfClkPeriod); 
    Rst_n = 1; 
    #(HalfClkPeriod);
    
    // send a 2-flit packet from send port 0 to receive port 1
    send_flit[1] = 1'b1;
    dest = 0;
    vc = 0;
    data = {32'b00000000000000000000000000000000, 32'b00000000000000000000000000001000};
    flit_in[1] = {1'b1 /*valid*/, 1'b0 /*tail*/, dest, vc, data};
    $display("Injecting flit %x into send port %0d", flit_in[1], 1);
    
    #(5*ClkPeriod);
    
    
  end
  
    // Monitor arriving flits
  always @ (posedge Clk) begin
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin
      if(flit_out[i][flit_port_width-1]) begin // valid flit
        $display("Ejecting flit %x at receive port %0d", flit_out[i], i);
      end
    end
  end
  
  parameter datawidth = 32;
  parameter depthbits = 4;
  parameter datadepth = 1 << depthbits;
  parameter [datawidth-1:0] ram [0:datadepth-1] =
                         '{32'h00000000, 32'h00000001, 32'h00000002,
                           32'h00000003, 32'h00000004, 32'h00000005,
                           32'h00000006, 32'h00000007, 32'h00000008,
                           32'h00000009, 32'h0000000a, 32'h0000000b,
                           32'h0000000c, 32'h0000000d, 32'h0000000e,
                           32'h0000000f};
  
    multipleIOram #(.DATAWIDTH(datawidth),.DEPTHBITS(depthbits),.DATA(ram)) memory(
        .clk(Clk),
        .in1(slave0Index),
        .out1(slave0Value)
    );

	top_noc_linreg #(1) slave0 (
		.CLK(Clk),
		.RST_N(Rst_n),
		.flit_to_send(flit),
		.credit_to_accept(credit_out[0]),
		.flit_to_receive(flit_out[0]),
		.credit_to_send(credit_in[0]),
		.send_credit_flag(send_credit[0]),
		.valueIn(slave0Value),
		.requestValue(slave0Index)
	);

	mkNetwork routers
	(
		.CLK(Clk),
		.RST_N(Rst_n),
	// START FOR SETTING UP CORE 0 (slave0)

	// sending flits
		.send_ports_0_putFlit_flit_in(flit_in[0]), // actual flits from source 0
		.EN_send_ports_0_putFlit(send_flit[0]), // signal that source 0 is sending valid flit
		.EN_send_ports_0_getCredits(1'b1), // signal that credits can be recieved for port 0. Set to 0 for not ready. Use variable if switching
		.send_ports_0_getCredits(credit_out[0]), // core 0's actual credit obtained from VC from the receiving core

	// receiving flits
		.EN_recv_ports_0_getFlit(1'b1), // signal that receiver 0 is ready to take in flits. Set to 0 when not ready. Use variable if switching
		.recv_ports_0_getFlit(flit_out[0]), // actual flit received by core 0
		.recv_ports_0_putCredits_cr_in(credit_in[0]), // actual credit sent out by receiving core 0 (to the VC and whatever sender)
		.EN_recv_ports_0_putCredits(send_credit[0]), // signal that core 0 has successfully obtained the flit from the VC and return a credit to the sender

	// START FOR SETTING UP CORE 1 (master aka this)

	//	sending flits
		.send_ports_1_putFlit_flit_in(flit_in[1]),
		.EN_send_ports_1_putFlit(send_flit[1]),
		.EN_send_ports_1_getCredits(1'b1),
		.send_ports_1_getCredits(credit_out[1]),
	
	//	receiving flits
		.EN_recv_ports_1_getFlit(1'b1),
		.recv_ports_1_getFlit(flit_out[1]),
		.recv_ports_1_putCredits_cr_in(credit_in[1]),
		.EN_recv_ports_1_putCredits(send_credit[1])
	);

endmodule