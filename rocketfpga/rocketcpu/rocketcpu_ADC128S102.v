`default_nettype none
module rocketcpu_ADC128S102 
(
   input wire        reset,   
   input wire        i_wb_clk,
   input wire [31:0] i_wb_adr,
   input wire        i_wb_cyc,
   output reg [31:0] o_wb_rdt,
   output reg 		   o_wb_ack,

   output clk,
	input  din,
	output dout,
	output n_cs,
);
   reg [2:0] adc_counter;
   reg [11:0] reading_sample;
   reg [11:0] samples [0:7];
   reg [3:0] clock_counter;

   assign clk = clock;

   reg [5:0] divider;
   reg clock;
   assign clock = divider[4];

   always @(posedge i_wb_clk) begin
      divider <= divider + 1;
   end

	reg o_wb_ack_aux = 0;

	always @(posedge i_wb_clk) begin
		o_wb_ack_aux <= i_wb_cyc & !o_wb_ack_aux;
		o_wb_ack <= o_wb_ack_aux;
      o_wb_rdt[11:0] <= samples[i_wb_adr[4:2]];
	end 

   always @(negedge clock) begin
      case (clock_counter)
         1: dout <= 1;
         2: dout <= adc_counter[2];
         3: dout <= adc_counter[1];
         4: dout <= adc_counter[0];
         default: dout <= 0;
      endcase
   end

   always @(posedge clock) begin
      if (reset) begin
         adc_counter <= 7;
         reading_sample <= 0;
         clock_counter <= 0;
         n_cs <= 1;
      end else begin
         n_cs <= 0;
         clock_counter <= clock_counter + 1;
         case (clock_counter)
            0: begin
               samples[adc_counter] <= (reading_sample >> 1) + (samples[adc_counter] >> 1);  // LPF
               adc_counter <= adc_counter + 1;
            end
            1: begin
            end 
            2: begin
            end 
            3: begin
            end 
            default:
               reading_sample <= {reading_sample[10:0], din};
         endcase
      end
   end
endmodule
