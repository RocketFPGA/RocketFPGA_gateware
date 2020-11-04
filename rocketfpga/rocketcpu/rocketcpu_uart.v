`default_nettype none
module rocketcpu_uart #(
	parameter integer PREESCALER_DIV = 104
)(  
	input wire            reset,

    input wire 		    i_wb_clk,
    input wire [31:0] 	i_wb_dat,
    input wire [3:0] 	i_wb_sel,
    input wire 		    i_wb_we,
    input wire 		    i_wb_cyc,
    output reg [31:0] 	o_wb_rdt,
    output reg 	        o_wb_ack,

	output ser_tx,
	input  ser_rx,
	output wire irq,
);
	reg [13:0] cfg_divider = PREESCALER_DIV;

	reg [3:0] recv_state;
	reg [31:0] recv_divcnt;
	reg [7:0] recv_pattern;
	reg [7:0] recv_buf_data;
	reg recv_buf_valid;

	assign irq = recv_buf_valid;

	reg [9:0] send_pattern;
	reg [3:0] send_bitcnt;
	reg [31:0] send_divcnt;
	reg send_dummy;

	wire reg_dat_we;
	wire reg_dat_wait;

	assign reg_dat_we = (i_wb_we && i_wb_cyc) ? i_wb_sel[0] : 1'b0;
	assign reg_dat_wait = reg_dat_we && (send_bitcnt || send_dummy);
	assign o_wb_rdt = (recv_buf_valid) ? recv_buf_data : ~0;

	reg [1:0]		uart_re;
	wire reg_dat_re;
	assign reg_dat_re = uart_re[0] && !uart_re[1];
	always @(posedge i_wb_clk) begin
		uart_re[1] <= uart_re[0];
		uart_re[0] <= !i_wb_we && i_wb_cyc;
	end

	always @(posedge i_wb_clk) begin
		if (i_wb_cyc) begin
			o_wb_ack <= (i_wb_we) ? !reg_dat_wait : 1'b1;
		end else begin
			o_wb_ack <= 0;
		end
  	end

	always @(posedge i_wb_clk) begin
		if (reset) begin
			recv_state <= 0;
			recv_divcnt <= 0;
			recv_pattern <= 0;
			recv_buf_data <= 0;
			recv_buf_valid <= 0;
		end else begin
			recv_divcnt <= recv_divcnt + 1;
			if (reg_dat_re)
				recv_buf_valid <= 0;
			case (recv_state)
				0: begin
					if (!ser_rx)
						recv_state <= 1;
					recv_divcnt <= 0;
				end
				1: begin
					if (2*recv_divcnt > cfg_divider) begin
						recv_state <= 2;
						recv_divcnt <= 0;
					end
				end
				10: begin
					if (recv_divcnt > cfg_divider) begin
						recv_buf_data <= recv_pattern;
						recv_buf_valid <= 1;
						recv_state <= 0;
					end
				end
				default: begin
					if (recv_divcnt > cfg_divider) begin
						recv_pattern <= {ser_rx, recv_pattern[7:1]};
						recv_state <= recv_state + 1;
						recv_divcnt <= 0;
					end
				end
			endcase
		end
	end

	assign ser_tx = send_pattern[0];

	always @(posedge i_wb_clk) begin
		send_divcnt <= send_divcnt + 1;
		if (reset) begin
			send_pattern <= ~0;
			send_bitcnt <= 0;
			send_divcnt <= 0;
			send_dummy <= 1;
		end else begin
			if (send_dummy && !send_bitcnt) begin
				send_pattern <= ~0;
				send_bitcnt <= 15;
				send_divcnt <= 0;
				send_dummy <= 0;
			end else
			if (reg_dat_we && !send_bitcnt) begin
				send_pattern <= {1'b1, i_wb_dat[7:0], 1'b0};
				send_bitcnt <= 10;
				send_divcnt <= 0;
			end else
			if (send_divcnt > cfg_divider && send_bitcnt) begin
				send_pattern <= {1'b1, send_pattern[9:1]};
				send_bitcnt <= send_bitcnt - 1;
				send_divcnt <= 0;
			end
		end
	end
endmodule
