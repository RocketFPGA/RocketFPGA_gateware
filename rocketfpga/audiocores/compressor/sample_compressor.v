`default_nettype none

module compressor #(
	parameter BITSIZE = 16,
)(	
    input wire bclk,
    input wire lrclk,

    input wire signed [BITSIZE-1:0] in,
    input wire        [BITSIZE-1:0] thr,
    input wire        [BITSIZE-1:0] ratio,

	  output reg signed [BITSIZE-1:0] out,
);


  // Signal attenuation
  reg signed [BITSIZE-1:0] mult_in1;
  reg signed [BITSIZE-1:0] mult_in2;
  wire signed [BITSIZE-1:0] mult_out;

  attenuator #(
    .BITSIZE(BITSIZE),
  ) A1 (
    .clk(bclk),
    .in(mult_in1),
    .att(mult_in2),
    .out(mult_out),
  );

  reg [1:0] counter;

  always @(posedge bclk) begin
    if(lrclk)
		  counter <= 1;
      
    if (counter == 1) begin
      mult_in1 <= (in >= 0) ? in - thr : in + thr;
      mult_in2 <= $signed(ratio);
      counter <= counter + 1;
    end else if (counter == 2) begin
      if (in >= 0) begin
        out <= (in > thr) ? mult_out + thr : in;
      end else begin
        out <= (in < -thr) ? mult_out - thr : in;
      end
    end
  end
endmodule
