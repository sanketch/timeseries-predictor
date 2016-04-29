`include "connect_parameters.v"
module top_noc_linreg(
	CLK,
	RST_N,
	flit_to_send,
	credit_to_accept,

	flit_to_receive,
	credit_to_send,
	send_credit_flag,
	valueIn,
	requestValue
);

 parameter master_destination = 1;
 parameter slave_bits = 2;
 parameter vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
 parameter dest_bits = $clog2(`NUM_USER_RECV_PORTS);
 parameter flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
 parameter credit_port_width = 1 + vc_bits; // 1 valid bit
 
 input CLK, RST_N;
 input [31:0] valueIn;
 output send_credit_flag;
 output wire [flit_port_width-1:0] flit_to_send;
 input wire [credit_port_width-1:0] credit_to_accept;
 input wire [flit_port_width-1:0] flit_to_receive;
 output wire [credit_port_width-1:0] credit_to_send;
 output wire send_credit_flag;
 output wire [31:0] requestValue;
 
reg [31:0] start_index;
reg [31:0] end_index;
reg [31:0] current;
wire [31:0] output_index;
reg [31:0] value;

reg start;
wire done;
wire [31:0] deviation;
wire [31:0] mean;

localparam VALID_BIT = flit_port_width - 1;
localparam IS_TAIL_BIT = VALID_BIT - 1;
localparam DESTINATION_START = IS_TAIL_BIT - 1;
localparam DESTINATION_END = DESTINATION_START - dest_bits;
localparam VC_START = DESTINATION_END - 1;
localparam VC_END = VC_START - vc_bits;
localparam RECEIVE_DATA_START = VC_END - 1;
localparam START_INDEX_MSB = RECEIVE_DATA_START;
localparam START_INDEX_LSB = START_INDEX_MSB - 32;
localparam END_INDEX_MSB = START_INDEX_LSB - 1;
localparam END_INDEX_LSB = 0;

localparam RECEIVE_CHUNK_ID_START = RECEIVE_DATA_START - 60;
localparam RECEIVE_CHUNK_ID_END = 0;

localparam BUFFER_BITS = 28 - slave_bits;
localparam SLAVE_ID_START = VC_END-1;
localparam SLAVE_ID_END = SLAVE_ID_START - slave_bits;

localparam SEND_CHUNK_ID_START = SLAVE_ID_END - 1;
localparam SEND_CHUNK_ID_END = SEND_CHUNK_ID_START - 4;
localparam SEND_DATA_START = SEND_CHUNK_ID_END - 1;
localparam SEND_DATA_END = 0;

localparam QIDLE                = 3'b001;
localparam QRECEIVECHUNKSIZE    = 3'b010;
localparam QOPERATE             = 3'b100;

reg [2:0] STATE;

reg send_valid;
reg [3:0] vc;
reg [slave_bits-1:0] slave_id;
reg [3:0] chunk_id;

assign flit_to_send[flit_port_width-1:VC_END-1] = { done, 1'b1, master_destination, vc};
assign flit_to_send[SLAVE_ID_START:SEND_DATA_END] ={ slave_id, chunk_id, deviation};
assign credit_to_send = {send_valid, vc};

reg [31:0] req;
assign requestValue = req;

always @(posedge CLK)
begin
	if (~RST_N)
	begin
		STATE <= QIDLE;
		start_index <= 0;
		end_index <= 0;
		value <= 0;
		start <= 0;
		current <= 0;
	end
	else
	begin
		case(STATE)
			QIDLE:
			begin
				send_valid = 0;
				if (flit_to_receive[VALID_BIT])
				begin
					start_index <= flit_to_receive[START_INDEX_MSB:START_INDEX_LSB];
					end_index <= flit_to_receive[END_INDEX_MSB:END_INDEX_LSB];
					vc <= flit_to_receive[VC_START:VC_END];
					slave_id <= flit_to_receive[DESTINATION_START:DESTINATION_END];
					STATE <= QRECEIVECHUNKSIZE;
					send_valid <= 1;
				end
			end
			
			QRECEIVECHUNKSIZE:
			begin
				send_valid = 0;
				if (flit_to_receive[VALID_BIT])
				begin
					chunk_id <= flit_to_receive[RECEIVE_CHUNK_ID_START:RECEIVE_CHUNK_ID_END];
					STATE <= QOPERATE;
					send_valid = 1;
					req <= start_index;
					current <= start_index + 1;
					value <= valueIn;
				end
			end
			
			QOPERATE:
			begin
				if (current < end_index - 1)
				begin
					current <= output_index + 2;
					value <= valueIn;
					req <= current;
				end
				else
				begin
					if (done)
					begin
						STATE <= QIDLE;
					end
				end
			end
		endcase
	end
end

LinRegDev core
(
	.Clk(CLK),
	.Rst(RST_N),
	.si(start_index),
	.ei(end_index),
	.index(output_index),
	.value(value),
	.start(start),
	.done(done),
	.deviation(deviation),
	.mean(mean)
);

endmodule