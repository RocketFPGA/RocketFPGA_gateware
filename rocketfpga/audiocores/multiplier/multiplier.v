`default_nettype none
// out = (in2 * in1)
module multiplier #(
	parameter BITSIZE = 16,
)(	
    input clk,

    input wire signed [BITSIZE-1:0] in1,
    input wire signed [BITSIZE-1:0] in2,

	output reg signed [BITSIZE-1:0] out,
);

if (BITSIZE == 24) begin
    $error("MULTIPLIER SUPPORT FOR 24 NOT AVAILABLE YET");
end

reg signed [(BITSIZE*2)-1:0] aux;

always @(posedge clk) begin
    aux <= in1 * in2;
    out <= aux[(BITSIZE*2)-1 -:BITSIZE];
end

endmodule