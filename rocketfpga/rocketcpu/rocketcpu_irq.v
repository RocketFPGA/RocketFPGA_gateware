`default_nettype none
module rocketcpu_irq #(
   parameter SIZE = 3
)(
   input wire 	      i_wb_clk,
   input wire [31:0] i_wb_adr,
   input wire [31:0] i_wb_dat,
   input wire 	      i_wb_we,
   input wire 	      i_wb_cyc,
   output reg [31:0] o_wb_rdt,
   output reg 		   o_wb_ack,


   input wire [SIZE-1:0] i_irq,
   output reg 	          o_irq,

);
   reg [SIZE-1:0]    irq;
   reg [SIZE-1:0]    mask;

   initial o_wb_rdt = 0;
   initial mask = 0;
   initial irq = 0;

   reg o_wb_ack_aux = 0;

   always @(posedge i_wb_clk) begin
		o_wb_ack_aux <= i_wb_cyc & !o_wb_ack_aux;
		o_wb_ack <= o_wb_ack_aux;
	end 

   always @(posedge i_wb_clk) begin
      irq <= (i_irq | irq) & mask;
      o_irq <= irq > 0;

      if (i_wb_cyc & i_wb_we) begin
			case (i_wb_adr)
				32'h0900_0000  : irq <= i_wb_dat;
				32'h0900_0004  : mask <= i_wb_dat;
			endcase
		end

		case (i_wb_adr)
			32'h0900_0000  : o_wb_rdt[SIZE-1:0] <= irq;
			32'h0900_0004  : o_wb_rdt[SIZE-1:0] <= mask;
		endcase
   end

endmodule
