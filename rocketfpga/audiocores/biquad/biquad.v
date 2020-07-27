`default_nettype none

module biquad_multiplier #(
	parameter BITSIZE = 16,
)(	
    input wire lrclk,
    input wire bclk,

    input wire signed [BITSIZE-1:0] in,
	output reg signed [BITSIZE-1:0] out,

    input wire signed [BITSIZE-1:0] a0,
    input wire signed [BITSIZE-1:0] a1,
    input wire signed [BITSIZE-1:0] a2,
    input wire signed [BITSIZE-1:0] b0,
    input wire signed [BITSIZE-1:0] b1,
);

reg signed [(BITSIZE*2)-1:0] aux;


always @(clk) begin
    aux <= in1 * in2;
end

assign out = aux[(BITSIZE*2)-1 -: BITSIZE];

endmodule

module biquad #(
	parameter BITSIZE = 16,
)(	
    input clk,

    input wire signed [BITSIZE-1:0] in1,
    input wire signed [BITSIZE-1:0] in2,

	output reg signed [BITSIZE-1:0] out,
);
//                            b_0
// x[n] ---> + ----------o-----X-----> + -----> y[n]
//           ^           |             ^
//           |          z-1            |
//           |   -a_1    |    b_1      |
//           + <---X-----o-----X-----> +
//           ^           |             ^
//           |          z-2            |
//           |   -a_2    |    b_2      |
//           ------X-----o-----X--------

// PIPELINE:
//  1. Multiply delay_2 by -a_2 -> aux_1
//  2. Multiply delay_1 by -a_2 -> aux_2
//  3. Sum aux_1 + aux_2        -> aux_1
//  4. Sum aux_1 + input        -> aux_mid
//  5. Multiply delay_2 by b_2  -> aux_1
//  6. Multiply delay_1 by b_1  -> aux_2
//  7. Sum aux_1 + aux_2        -> aux_1
//  8. Multiply aux_mid by b_0  -> aux_2
//  9. Sum aux_1 + aux_2        -> out
// 10. delay_1                  -> delay_2
// 11. aux_mid                  -> delay_1

reg [BITSIZE-1:0] mult_in1;
reg [BITSIZE-1:0] mult_in2;
wire [BITSIZE-1:0] mult_out;

biquad_multiplier #(
    .BITSIZE(BITSIZE),
) mult_1 (
    .clk(bclk),
    .in1(mult_in1),
    .in2(mult_in2),
    .out(mult_out),
);

reg signed [BITSIZE-1:0] delay_1;
reg signed [BITSIZE-1:0] delay_2;

reg signed [BITSIZE-1:0] aux_1;
reg signed [BITSIZE-1:0] aux_2;

initial delay_1 = 0; 
initial delay_2 = 0; 

reg [2:0] counter;

always @(posedge lrclk) begin
    out <= mult_out;
end


// https://www.earlevel.com/main/2012/11/26/biquad-c-source-code/

//     double out = in * a0 + z1;
//     z1 = in * a1 + z2 - b1 * out;
//     z2 = in * a2 - b2 * out;
//     return out;

// PIPELINE:
// 1. input * a0       -> aux_1
// 2. aux_1 + delay_1  -> out
// 3. input * a1       -> aux_1
// 4. aux_1 + delay_2  -> aux_1
// 5. out * b1         -> aux_2
// 6. aux_1 - aux_2    -> delay_1
// 7. in * a2          -> aux_1
// 8. out * b2         -> aux_2
// 9. aux_1 - aux_2    -> delay_2

always @(posedge bclk) begin
    
    if (lrclk) begin
        counter <= 0;
    end 

    if (counter == 0) begin
        mult_in1 <= in;
        mult_in2 <= a0;
        counter <= counter + 1;
    end else if (counter == 1) begin
        out <= mult_out + delay_1;
        mult_in1 <= in;
        mult_in2 <= a1;
        counter <= counter + 1;
    end else if (counter == 2) begin
        aux_1 <= mult_out + delay_2;
        mult_in1 <= out;
        mult_in2 <= b1;
        counter <= counter + 1;
    end else if (counter == 3) begin
        delay_1 <= aux_1 - mult_out;
        mult_in1 <= in;
        mult_in2 <= a2;
        counter <= counter + 1;
    end else if (counter == 4) begin
        aux_1 <= mult_out;
        mult_in1 <= out;
        mult_in2 <= b2;
        counter <= counter + 1;
    end else if (counter == 5) begin
        delay_2 <= aux_1 - mult_out
        counter <= counter + 1;
    end

endmodule