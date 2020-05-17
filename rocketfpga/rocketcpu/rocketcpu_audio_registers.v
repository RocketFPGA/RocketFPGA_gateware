`default_nettype none
module rocketcpu_audio_registers
(   
    input wire 		      i_wb_clk,
    input wire [31:0]     i_wb_adr,
    input wire [31:0] 	  i_wb_dat,
    input wire [3:0] 	  i_wb_sel,
    input wire 		      i_wb_we,
    input wire 		      i_wb_cyc,
    output reg [31:0] 	  o_wb_rdt,
    output reg 		      o_wb_ack,

	output [31:0] 		  param_1,
	output [31:0] 		  param_2,
	output [31:0] 		  param_3,
	output [31:0] 		  param_4,
	output [31:0] 		  param_5,
	output [31:0] 		  param_6,
	output [31:0] 		  param_7,

	input [31:0] iparam_1,
);
	reg [31:0] regs [0:10];

	assign param_1 = regs[0];
	assign param_2 = regs[1];
	assign param_3 = regs[2];
	assign param_4 = regs[3];
	assign param_5 = regs[4];
	assign param_6 = regs[5];
	assign param_7 = regs[6];

	reg o_wb_ack_aux = 0;

	always @(posedge i_wb_clk) begin
		o_wb_ack_aux <= i_wb_cyc & !o_wb_ack_aux;
		o_wb_ack <= o_wb_ack_aux;
	end 

	always @(posedge i_wb_clk) begin
		if (i_wb_cyc & i_wb_we) begin
			case (i_wb_adr)
				32'h1000_0000  : regs[0] <= i_wb_dat;
				32'h1000_0004  : regs[1] <= i_wb_dat;
				32'h1000_0008  : regs[2] <= i_wb_dat;
				32'h1000_000C  : regs[3] <= i_wb_dat;
				32'h1000_0010  : regs[4] <= i_wb_dat;
				32'h1000_0014  : regs[5] <= i_wb_dat;
				32'h1000_0018  : regs[6] <= i_wb_dat;
			endcase
		end

		case (i_wb_adr)
			32'h1000_0000  : o_wb_rdt <= regs[0];
			32'h1000_0004  : o_wb_rdt <= regs[1];
			32'h1000_0008  : o_wb_rdt <= regs[2];
			32'h1000_000C  : o_wb_rdt <= regs[3];
			32'h1000_0010  : o_wb_rdt <= regs[4];
			32'h1000_0014  : o_wb_rdt <= regs[5];
			32'h1000_0018  : o_wb_rdt <= regs[6];
			32'h1000_001C  : o_wb_rdt <= iparam_1;
		endcase
   	end

endmodule