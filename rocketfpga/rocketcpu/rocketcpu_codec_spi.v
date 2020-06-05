`default_nettype none
module rocketcpu_codec_spi
(   
    input wire 		      i_wb_clk,
    input wire [15:0] 	  i_wb_dat,
    input wire 		      i_wb_we,
    input wire 		      i_wb_cyc,
    output reg 		      o_wb_ack,

	output reg codec_di, 
    output reg codec_clk, 
    output reg codec_cs, 
);

	reg [7:0] nbits;
	reg [15:0] inner_data;

	wire enabled = i_wb_cyc & i_wb_we;

	always @(posedge i_wb_clk) begin
		if (!enabled) begin
			codec_di <= 0;
			codec_cs <= 1;
			o_wb_ack <= 0;
			nbits <= 0;
		end else begin
			if (nbits == 0) begin
				inner_data <= i_wb_dat; 
				codec_clk <= 0;
				codec_cs <= 1;
				codec_di <= i_wb_dat[15];
				nbits <= 16;
			end else if (nbits > 0 && codec_clk == 1) begin
				codec_di <= inner_data[nbits-2];
				nbits <= nbits - 1;
				codec_clk <= 0;
			end else if (codec_clk == 0 && nbits > 0) begin
				codec_clk <= 1;
			end else begin
				codec_di <= 0;
				codec_cs <= 0;
				o_wb_ack <= 1;
				codec_clk <= 0;
			end
		end
	end
endmodule
