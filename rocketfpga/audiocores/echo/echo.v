`default_nettype none

module echo #(
	parameter BITSIZE = 16,
	parameter LENGHT = 1,
)(	
	input wire enable,

	input wire bclk,    // 64 times lrclk 
	input wire lrclk,

	input wire [31:0] offset,

	input wire [BITSIZE-1:0] dry_gain,
    input wire [BITSIZE-1:0] wet_gain,

	input wire signed [BITSIZE-1:0] in,
	output wire signed [BITSIZE-1:0] out,
);

if (BITSIZE == 24) begin
    $error("ECHO SUPPORT FOR 24 NOT AVAILABLE YET");
end

localparam ADDRLEN = (LENGHT == 4) ? 16 : ((LENGHT == 2) ? 15 : 14);

reg [ADDRLEN-1:0] wr_ptr = 0;

reg [2:0] counter = 0;
reg cleaning = 1;

reg wren;
reg [ADDRLEN-1:0] memaddr;
reg signed [BITSIZE-1:0] datain;
reg signed [BITSIZE-1:0] dataout;
reg signed [BITSIZE-1:0] gain_reg;
wire signed [BITSIZE-1:0] outbuff;

memory  #( 
   .BITSIZE(BITSIZE),
   .LENGHT(LENGHT),
) M1 (
    .clk(bclk),
    .addr(memaddr),
    .datain(datain),
    .dataout(outbuff),
	.wren(wren)
);

reg signed  [BITSIZE-1:0] mult_in1;
reg 	    [BITSIZE-1:0] mult_in2;
wire signed [BITSIZE-1:0] mult_out;

attenuator #(
	.BITSIZE(BITSIZE),
) A1 (
	.clk(bclk),
	.in(mult_in1),
	.att(mult_in2),
	.out(mult_out),
);

assign out = (cleaning || !enable) ? 0 : outbuff; 

always @(posedge bclk) begin
	if(lrclk)
		counter <= 1;
	
	if (wr_ptr == (2**ADDRLEN)-1)
		cleaning <= 0;
		
	if (counter == 1) begin
		if (cleaning || !enable)
			datain <= 0;
		else
			datain <= gain_reg + dataout;
		wren <= 1;
		memaddr <= wr_ptr;
		counter <= counter + 1;
	end else if (counter == 2) begin
		wren <= 0;
		memaddr <= wr_ptr - offset[ADDRLEN-1:0];  //Here is where lenght of echo is set
		counter <= counter + 1; 
	end else if (counter == 3) begin
		mult_in1 <= outbuff;
		mult_in2 <= wet_gain;
		wr_ptr <= wr_ptr + 1;
		counter <= counter + 1;
	end else if (counter == 4) begin
		dataout <= mult_out;
		mult_in1 <= in;
		mult_in2 <= dry_gain;
		counter <= counter + 1;
	end else if (counter == 5) begin
		gain_reg <= mult_out;
		counter <= counter + 1;
	end
end

endmodule