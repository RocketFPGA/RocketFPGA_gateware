`default_nettype none
module rocketcpu_uart(  
	input wire            reset,

    input wire 		    i_wb_clk,
    input wire [31:0]   i_wb_adr,
    input wire [31:0] 	i_wb_dat,
    input wire [3:0] 	i_wb_sel,
    input wire 		    i_wb_we,
    input wire 		    i_wb_cyc,
    output reg [31:0] 	o_wb_rdt,
    output reg 	        o_wb_ack,

	output ser_tx,
	input  ser_rx,
);

  always @(posedge i_wb_clk) begin
	if (i_wb_cyc) begin
		o_wb_ack <= (i_wb_we) ? !o_wb_wait_uart : 1'b1;
    	o_wb_rdt <= o_wb_rdt_uart_dat;
	end else begin
		o_wb_ack <= 0;
    	o_wb_rdt <= 0;
	end
  end

	// UART Mapping
	wire [31:0] 	o_wb_rdt_uart_dat;
  	wire          	o_wb_wait_uart;

	reg [1:0]		uart_re;
	always @(posedge i_wb_clk) begin
		uart_re[1] <= uart_re[0];
		uart_re[0] <= !i_wb_we && i_wb_cyc;
	end
	  
	simpleuart simpleuart (
		.clk(i_wb_clk),
		.resetn(!reset),

		.ser_tx(ser_tx),
		.ser_rx(ser_rx),

		.reg_dat_we  ((i_wb_we && i_wb_cyc) ? i_wb_sel[0] : 1'b0),
		.reg_dat_re  (uart_re[0] && !uart_re[1]),
		.reg_dat_di  (i_wb_dat),
		.reg_dat_do  (o_wb_rdt_uart_dat),
		.reg_dat_wait(o_wb_wait_uart),
	);

	

endmodule
