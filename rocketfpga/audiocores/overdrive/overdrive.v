module overdrive #(
	parameter BITSIZE = 16,
)(	
    input wire signed [BITSIZE-1:0] gain,

    input wire signed [BITSIZE-1:0] in,
	output reg signed [BITSIZE-1:0] out,
);

assign out = (in > gain) ? gain : 
             (in < -gain) ? -gain : in ;

endmodule