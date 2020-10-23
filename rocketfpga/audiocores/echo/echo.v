// -- RocketFPGA Delay implementation --
// 
//                             +---------+
//           +---+             |         |
// in  +------|A|-----+--------+  DELAY  +-------+--------> out
//           +---+    ^        |    K    |       |
//                    |        +---------+       |
//                    |                          |
//                    |           +---+          |
//                    +------------|B|-----------+
//                                +---+
// A controls the input gain - input_gain
// B controls the feedback gain - feedback_gain
// K represents the delay lenght - lenght

// PIPELINE:
// 1. input * A        -> aux_1
// 2. output     	   -> out
//    read mem w/ K	   -> aux_2
// 3. aux_2 * B		   -> aux_2
// 4. aux_1 * aux_2	   -> mem input
// 5. mem write

module echo_multiplier #(
	parameter BITSIZE = 16,
)(	
    input wire clk,
    input wire signed [BITSIZE-1:0] in1,
    input wire signed [BITSIZE-1:0] in2,
	output reg signed [BITSIZE-1:0] out,
);

reg signed [(BITSIZE*2)-1:0] aux;

always @(clk) begin
    aux <= in1 * in2;
end

assign out = aux >>> BITSIZE - 2;

endmodule


module echo #(
	parameter BITSIZE = 16,
	parameter LENGHT = 1,
)(	
	input wire enable,

	input wire bclk,    // 64 times lrclk 
	input wire lrclk,

	input wire [31:0] lenght,
    input wire signed [BITSIZE-1:0] input_gain,
    input wire signed [BITSIZE-1:0] feedback_gain,

	input wire signed [BITSIZE-1:0] in,
	output wire signed [BITSIZE-1:0] out,
);

if (BITSIZE == 24) begin
    $error("ECHO SUPPORT FOR 24 NOT AVAILABLE");
end

localparam ADDRLEN = (LENGHT == 4) ? 16 : 
					 (LENGHT == 2) ? 15 : 14;

reg [ADDRLEN-1:0] wr_ptr = 0;

reg [2:0] counter = 0;
reg cleaning = 1;

// Memory

reg wren;
reg [ADDRLEN-1:0] memaddr;
reg signed [BITSIZE-1:0] datain;
reg signed [BITSIZE-1:0] dataout;
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

// Multiplier

reg signed [BITSIZE-1:0] mult_in1;
reg signed [BITSIZE-1:0] mult_in2;
wire signed [BITSIZE-1:0] mult_out;

echo_multiplier #(
    .BITSIZE(BITSIZE),
) mult_1 (
    .clk(bclk),
    .in1(mult_in1),
    .in2(mult_in2),
    .out(mult_out),
);

reg signed [BITSIZE-1:0] aux_1;
reg signed [BITSIZE-1:0] aux_2;

assign out = (cleaning || !enable) ? 0 : dataout; 

always @(posedge bclk) begin
	if(lrclk)
		counter <= 0;
	
	if (cleaning && wr_ptr == (2**ADDRLEN)-1)
		cleaning <= 0;

    if (counter == 0) begin
        mult_in1 <= in;
        mult_in2 <= input_gain;

        counter <= counter + 1;
    end else if (counter == 1) begin
		dataout <= outbuff;

        aux_1 <= mult_out;

        mult_in1 <= outbuff;
        mult_in2 <= feedback_gain;

        counter <= counter + 1;
    end else if (counter == 2) begin
		if (cleaning)
			datain <= 0;
		else
       		datain <= aux_1 + mult_out;
		wren <= 1;
		memaddr <= wr_ptr;

        counter <= counter + 1;
    end else if (counter == 3) begin
		wren <= 0;
		memaddr <= wr_ptr + lenght;

        counter <= counter + 1;
    end
		
end

endmodule