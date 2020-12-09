`default_nettype none

module rocketcpu_leds_charlieplexed #(
   parameter SIZE = 12
) (
   input wire        i_wb_clk,
   input wire [31:0] i_wb_dat,
   input wire        i_wb_we,
   input wire        i_wb_cyc,
   output reg [31:0] o_wb_rdt,

   inout reg [3:0] o_gpio,
);
   reg [SIZE-1:0] led_status;

   reg [3:0] pin_out;
   reg [3:0] pin_in;
   reg [3:0] pin_dir;

   reg [3:0] counter;
   reg [9:0] charlie_divider;

   initial counter = 0;
   initial led_status = 12'd0;

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) flash_io_buf [3:0] (
        .PACKAGE_PIN({ o_gpio[0], o_gpio[1], o_gpio[2], o_gpio[3]}),
        .OUTPUT_ENABLE(    {pin_dir[3],pin_dir[2], pin_dir[1], pin_dir[0]}),
        .D_OUT_0(          {pin_out[3],pin_out[2], pin_out[1], pin_out[0]}),
        .D_IN_0(           {pin_in[3],pin_in[2], pin_in[1], pin_in[0]})
    );

   always @(posedge i_wb_clk) begin
      charlie_divider <= charlie_divider + 1;

      if (i_wb_cyc & i_wb_we) begin
			led_status <= i_wb_dat[SIZE-1:0];
		end

      o_wb_rdt[SIZE-1:0] <= led_status;
   end

   always @(posedge charlie_divider[8]) begin
      counter <= counter + 1;
      pin_out <= 4'b0000;
      case (counter)
         0: begin
            pin_out[2] <= led_status[0];
            pin_dir <= 4'b1100;
         end 
         1: begin
            pin_out[1] <= led_status[1];
            pin_dir <= 4'b1010;
         end 
         2: begin
            pin_out[0] <= led_status[2];
            pin_dir <= 4'b1001;
         end 
         3: begin
            pin_out[3] <= led_status[3];
            pin_dir <= 4'b1100;
         end 
         4: begin
            pin_out[3] <= led_status[4];
            pin_dir <= 4'b1010;
         end 
         5: begin
            pin_out[3] <= led_status[5];
            pin_dir <= 4'b1001;
         end 
         6: begin
            pin_out[1] <= led_status[6];
            pin_dir <= 4'b0110;
         end 
         7: begin
            pin_out[0] <= led_status[7];
            pin_dir <= 4'b0101;
         end 
         8: begin
            pin_out[2] <= led_status[8];
            pin_dir <= 4'b0110;
         end 
         9: begin
            pin_out[2] <= led_status[9];
            pin_dir <= 4'b0101;
         end 
         10: begin
            pin_out[0] <= led_status[10];
            pin_dir <= 4'b0011;
         end 
         11: begin
            pin_out[1] <= led_status[11];
            pin_dir <= 4'b0011;
         end 
         default:
            counter <= 0;
      endcase
   end
endmodule
