`default_nettype none
module rocketcpu_ram
(   
    input wire 		      i_wb_clk,
    input wire [31:0]     i_wb_adr,
    input wire [31:0] 	  i_wb_dat,
    input wire [3:0] 	  i_wb_sel,
    input wire 		      i_wb_we,
    input wire 		      i_wb_cyc,
    output reg [31:0] 	  o_wb_rdt,
    output reg 		      o_wb_ack,
);
  	// SPRAM Memory
	reg         	o_wb_ack_spram = 0;

	always @(posedge i_wb_clk) begin
		o_wb_ack_spram <= i_wb_cyc & !o_wb_ack_spram;
		o_wb_ack <= o_wb_ack_spram;
	end 

	SB_SPRAM256KA ram00 (
		.ADDRESS(i_wb_adr[15:2]),
		.DATAIN(i_wb_dat[15:0]),
		.MASKWREN((i_wb_cyc) ? {i_wb_sel[1], i_wb_sel[1], i_wb_sel[0], i_wb_sel[0]} : 4'b0000),
		.WREN(i_wb_cyc && i_wb_we && (i_wb_sel[1] || i_wb_sel[0])),
		.CHIPSELECT(1'b1),
		.CLOCK(i_wb_clk),
		.STANDBY(1'b0),
		.SLEEP(1'b0),
		.POWEROFF(1'b1),
		.DATAOUT(o_wb_rdt[15:0])
	);

	SB_SPRAM256KA ram01 (
		.ADDRESS(i_wb_adr[15:2]),
		.DATAIN(i_wb_dat[31:16]),
		.MASKWREN((i_wb_cyc) ? {i_wb_sel[3], i_wb_sel[3], i_wb_sel[2], i_wb_sel[2]} : 4'b0000),
		.WREN(i_wb_cyc && i_wb_we && (i_wb_sel[3] || i_wb_sel[2])),
		.CHIPSELECT(1'b1),
		.CLOCK(i_wb_clk),
		.STANDBY(1'b0),
		.SLEEP(1'b0),
		.POWEROFF(1'b1),
		.DATAOUT(o_wb_rdt[31:16])
	);

endmodule
