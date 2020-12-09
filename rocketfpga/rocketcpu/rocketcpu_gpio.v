module rocketcpu_gpio
(
   input wire        i_wb_clk,
   input wire [31:0] i_wb_dat,
   input wire        i_wb_we,
   input wire        i_wb_cyc,
   output reg [31:0] o_wb_rdt,
   output reg        o_gpio,
   input wire [3:0]  i_gpio
);
   reg mem = 0;

   always @(posedge i_wb_clk) begin
      o_wb_rdt[0] <= mem;
      o_gpio <= mem;
      o_wb_rdt[4:1] <= i_gpio;

      if (i_wb_cyc & i_wb_we)
         mem <= i_wb_dat[0];
   end

endmodule
