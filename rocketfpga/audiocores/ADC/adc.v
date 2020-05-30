module adc (	
	output wire capacitor,
	input wire osc,			// 49.152 MHz
	input wire sense,
	output reg [31:0] out,
);
localparam sense_division = 2;  
// localparam capacitor_division = sense_division + OUTSIZE + 1; // 46.875 Hz -> 10 uF
localparam capacitor_division = 16; // 46.875 Hz -> 10 uF

wire aux;
reg [31:0] counter;
reg done = 0;

reg [16:0] divider;
always @(posedge osc) begin
    divider <= divider + 1;
end

assign capacitor = divider[capacitor_division];

SB_IO #(
  .PIN_TYPE(6'b000000), 
  .IO_STANDARD("SB_LVDS_INPUT")
) _io (
 .PACKAGE_PIN(sense),
 .INPUT_CLK (divider[sense_division]),
 .D_IN_0 (aux)
);

always @(posedge divider[3]) begin
  if (!divider[capacitor_division]) begin
    counter <= 0;
    done <= 0;
  end else if (!done) begin
    counter <= counter + 1;
    if (!aux) begin
      done <= 1;
      out <= counter;
    end
  end
end

endmodule