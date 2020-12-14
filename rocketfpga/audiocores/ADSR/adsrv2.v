`default_nettype none
module envelope_generator #(
  parameter BITSIZE = 16,
  parameter ACCUMULATOR_BITS = 20,
  parameter PARAMETERS_BITS = 16
) (
  input wire clk,

  input wire gate,

  input wire [PARAMETERS_BITS-1:0] att,
  input wire [PARAMETERS_BITS-1:0] dec,
  input wire [PARAMETERS_BITS-1:0] sus,
  input wire [PARAMETERS_BITS-1:0] rel,

	input wire signed [BITSIZE-1:0] in,
	output reg signed [BITSIZE-1:0] out,
);

  reg [ACCUMULATOR_BITS-1:0] accumulator;
  wire [BITSIZE-1:0] amplitude;
  assign amplitude = accumulator[ACCUMULATOR_BITS-1 -: BITSIZE];

  reg decay_triggered = 0;

  always @(posedge clk) begin

      case (gate)
        1'b1:
          begin
            if (amplitude < 32255 && !decay_triggered) begin
              accumulator <= accumulator + att;
            end else if (amplitude > sus && decay_triggered) begin
               accumulator <=  accumulator - dec;
            end else begin
              decay_triggered <= 1;
            end

          end
        1'b0:
          begin
            decay_triggered <= 0;
            if (amplitude > 512)
              accumulator <=  accumulator - rel;
            else
              accumulator <= 0;
          end
      endcase

  end

  // Signal attenuation
  reg signed  [BITSIZE-1:0] mult_in1;
  reg 	      [BITSIZE-1:0] mult_in2;
  wire signed [BITSIZE-1:0] mult_out;

  attenuator #(
    .BITSIZE(BITSIZE),
  ) A1 (
    .clk(clk),
    .in(mult_in1),
    .att(mult_in2),
    .out(mult_out),
  );

  always @(posedge clk) begin
    mult_in1 <= in;
    mult_in2 <= amplitude;
    out <= mult_out;
  end

endmodule
