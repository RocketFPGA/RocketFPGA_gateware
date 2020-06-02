// out = ((a*in2)+b) * in1

module modulator_multiplier #(
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

assign out = aux[(BITSIZE*2)-1 -: BITSIZE];

endmodule

module modulator #(
	parameter BITSIZE = 16,
)(	
    input wire lrclk,
    input wire bclk,

    input wire signed [BITSIZE-1:0] in1,
    input wire signed [BITSIZE-1:0] in2,

    input wire signed [BITSIZE-1:0] a,
    input wire signed [BITSIZE-1:0] b,

	output reg signed [BITSIZE-1:0] out,
);

reg [BITSIZE-1:0] mult_in1;
reg [BITSIZE-1:0] mult_in2;
wire [BITSIZE-1:0] mult_out;

modulator_multiplier #(
    .BITSIZE(BITSIZE),
) mult_1 (
    .clk(bclk),
    .in1(mult_in1),
    .in2(mult_in2),
    .out(mult_out),
);

reg [1:0] counter;

always @(posedge lrclk) begin
    out <= mult_out;
end

always @(posedge bclk) begin
    
    if (lrclk) begin
        counter <= 0;
    end 

    if (counter == 0) begin
        mult_in1 <= a;
        mult_in2 <= in2;
        counter <= counter + 1;
    end else if (counter == 1) begin
        mult_in1 <= mult_out + b;
        mult_in2 <= in1;
        counter <= counter + 1;
    end
end

endmodule