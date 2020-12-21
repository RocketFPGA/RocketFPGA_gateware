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
	output [31:0] 		  param_8,
	output [31:0] 		  param_9,
	output [31:0] 		  param_10,
	output [31:0] 		  param_11,
	output [31:0] 		  param_12,
	output [31:0] 		  param_13,
	output [31:0] 		  param_14,
	output [31:0] 		  param_15,
	output [31:0] 		  param_16,
	output [31:0] 		  param_17,
	output [31:0] 		  param_18,
);
	reg [31:0] regs [0:19];

	assign param_1 = regs[0];
	assign param_2 = regs[1];
	assign param_3 = regs[2];
	assign param_4 = regs[3];
	assign param_5 = regs[4];
	assign param_6 = regs[5];
	assign param_7 = regs[6];
	assign param_8 = regs[7];
	assign param_9 = regs[8];
	assign param_10 = regs[9];
	assign param_11 = regs[10];
	assign param_12 = regs[11];
	assign param_13 = regs[12];
	assign param_14 = regs[13];
	assign param_15 = regs[14];
	assign param_16 = regs[15];
	assign param_17 = regs[16];
	assign param_18 = regs[17];

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
				32'h1000_001C  : regs[7] <= i_wb_dat;
				32'h1000_0020  : regs[8] <= i_wb_dat;
				32'h1000_0024  : regs[9] <= i_wb_dat;
				32'h1000_0028  : regs[10] <= i_wb_dat;
				32'h1000_002C  : regs[11] <= i_wb_dat;
				32'h1000_0030  : regs[12] <= i_wb_dat;
				32'h1000_0034  : regs[13] <= i_wb_dat;
				32'h1000_0038  : regs[14] <= i_wb_dat;
				32'h1000_003C  : regs[15] <= i_wb_dat;
				32'h1000_0040  : regs[16] <= i_wb_dat;
				32'h1000_0044  : regs[17] <= i_wb_dat;
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
			32'h1000_001C  : o_wb_rdt <= regs[7];
			32'h1000_0020  : o_wb_rdt <= regs[8];
			32'h1000_0024  : o_wb_rdt <= regs[9];
			32'h1000_0028  : o_wb_rdt <= regs[10];
			32'h1000_002C  : o_wb_rdt <= regs[11];
			32'h1000_0030  : o_wb_rdt <= regs[12];
			32'h1000_0034  : o_wb_rdt <= regs[13];
			32'h1000_0038  : o_wb_rdt <= regs[14];
			32'h1000_003C  : o_wb_rdt <= regs[15];
			32'h1000_0040  : o_wb_rdt <= regs[16];
			32'h1000_0044  : o_wb_rdt <= regs[17];
		endcase
   	end

endmodule
