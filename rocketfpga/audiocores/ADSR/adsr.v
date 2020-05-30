`default_nettype none
module envelope_generator #(
  parameter BITSIZE = 16,
  parameter SAMPLE_CLK_FREQ = 44100,
  parameter ACCUMULATOR_BITS = 26
) (
  input wire clk,
  input wire gate,
  input wire [15:0] att,
  input wire [15:0] dec,
  input wire [15:0] sus,
  input wire [15:0] rel,
  output reg signed [BITSIZE-1:0] amplitude,
);

  localparam  ACCUMULATOR_SIZE = 2**ACCUMULATOR_BITS;
  reg signed [ACCUMULATOR_BITS:0] accumulator = 0;
  reg signed [ACCUMULATOR_BITS:0] future_accumulator = 1;
  
  function [2:0] next_state;
    input [2:0] s;
    input g;
    begin
      case ({ s, g })
        { ATTACK,  1'b0 }: next_state = RELEASE;  /* attack, gate off => skip decay, sustain; go to release */
        { ATTACK,  1'b1 }: next_state = DECAY;    /* attack, gate still on => decay */
        { DECAY,   1'b0 }: next_state = RELEASE;  /* decay, gate off => skip sustain; go to release */
        { DECAY,   1'b1 }: next_state = SUSTAIN;  /* decay, gate still on => sustain */
        { SUSTAIN, 1'b0 }: next_state = RELEASE;  /* sustain, gate off => go to release */
        { SUSTAIN, 1'b1 }: next_state = SUSTAIN;  /* sustain, gate on => stay in sustain */
        { RELEASE, 1'b0 }: next_state = OFF;      /* release, gate off => end state */
        { RELEASE, 1'b1 }: next_state = ATTACK;   /* release, gate on => attack */
        { OFF,     1'b0 }: next_state = OFF;      /* end_state, gate off => stay in end state */
        { OFF,     1'b1 }: next_state = ATTACK;   /* end_state, gate on => attack */
        default: next_state = OFF;                /* default is end (off) state */
      endcase
    end
  endfunction


  // State machine
  localparam OFF     = 3'd0;
  localparam ATTACK  = 3'd1;
  localparam DECAY   = 3'd2;
  localparam SUSTAIN = 3'd3;
  localparam RELEASE = 3'd4;

  reg[2:0] state = OFF;

  reg last_gate;

  wire overflow;
  assign overflow = accumulator[ACCUMULATOR_BITS];

  reg signed [ACCUMULATOR_BITS:0] sustain_volume;
  always @(sus) begin
      sustain_volume <= {1'b0, sus, {(ACCUMULATOR_BITS-17){sus[0]}} };
  end

  reg signed [ACCUMULATOR_BITS:0] max_acc;
  always @(att) begin
      max_acc <= {(ACCUMULATOR_BITS){1'b1}} - att;
  end

  assign amplitude = {2'b00, accumulator[ACCUMULATOR_BITS-1 -: BITSIZE-2]};

  always @(posedge clk) begin
      last_gate <= gate;
      case (state)
        ATTACK:
          begin
            if (accumulator < max_acc) begin
              accumulator <= accumulator + att;
            end else begin
              state <= next_state(state, gate);
            end
          end
        DECAY:
          begin
            if (!last_gate && gate) begin
                state = ATTACK;
            end
            if (accumulator >= sustain_volume) begin
                accumulator <= accumulator - dec;
            end else begin
                state <= next_state(state, gate);
            end
          end
        SUSTAIN:
          begin
            state <= next_state(state, gate);
          end
        RELEASE:
          begin
            if (accumulator > rel) begin
                accumulator <= accumulator - rel;
            end else begin
                state <= next_state(state, gate);
            end
          end
        default:
          begin
            accumulator <= 0;
            state <= next_state(state, gate);
          end
      endcase

  end

endmodule
