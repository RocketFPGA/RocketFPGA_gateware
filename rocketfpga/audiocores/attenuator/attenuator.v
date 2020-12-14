`default_nettype none

module attenuator #(
	parameter BITSIZE = 16,
)(	
    input wire clk,

    input wire signed [BITSIZE-1:0] in,
    input wire signed [BITSIZE-1:0] att,

	output reg signed [BITSIZE-1:0] out,
);

reg signed [(BITSIZE*2)-1:0] aux;

always @(posedge clk) begin
    aux <= in * att;
    // out <= aux[(BITSIZE*2)-2 -: BITSIZE];
end

assign out = aux[(BITSIZE*2)-2 -: BITSIZE];

endmodule
