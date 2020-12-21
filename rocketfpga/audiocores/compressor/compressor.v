`default_nettype none

module compressor #(
	parameter BITSIZE = 16,
)(	
    input wire bclk,
    input wire lrclk,

    input wire signed [BITSIZE-1:0] in,

    input wire        [BITSIZE-1:0] thr,
    input wire        [BITSIZE-1:0] ratio,
    input wire        [BITSIZE-1:0] attack,
    input wire        [BITSIZE-1:0] releas,

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

  reg [BITSIZE-1:0] attenuation = 16'h7FFF;

  always @(posedge bclk) begin
    if(lrclk)
      counter <= 1;
      
    if (counter == 1) begin
      if (in >= 0) begin

        if (in > thr && attenuation > 512 && attenuation > ratio) begin
          attenuation <= attenuation - attack;
        end else if (in > thr && attenuation > ratio) begin
          attenuation <= 16'h0000;
        end

        if (in < thr && attenuation < 32256) begin
          attenuation <= attenuation + releas;
        end else if (in < thr) begin
          attenuation <= 16'h7FFF;
        end

      end else begin
        
        if (in < -thr && attenuation > 512 && attenuation > ratio) begin
          attenuation <= attenuation - attack;
        end else if (in < -thr && attenuation > ratio) begin
          attenuation <= 16'h0000;
        end

        if (in > -thr && attenuation < 32256) begin
          attenuation <= attenuation + releas;
        end else if (in > -thr) begin
          attenuation <= 16'h7FFF;
        end

      end

      mult_in1 <= (in >= 0) ? in - thr : in + thr;
      mult_in2 <= $signed(attenuation);
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
