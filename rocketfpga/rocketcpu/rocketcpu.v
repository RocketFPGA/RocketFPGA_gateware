`default_nettype none
module rocketcpu
(
	// input wire  wb_clk,
	input  external_rst,

	output led,
	input  button,

	output flash_csb,
	output flash_clk,
	inout flash_io0,
	inout flash_io1,
	inout flash_io2,
	inout flash_io3,

	output ser_tx,
	input  ser_rx,

	output [31:0] param_1,
	output [31:0] param_2,
	output [31:0] param_3,
	output [31:0] param_4,
	output [31:0] param_5,
	output [31:0] param_6,
	output [31:0] param_7,

	input [31:0] iparam_1,
);
	// 12 MHz system clock
	wire      wb_clk;
	SB_HFOSC #(
		.CLKHF_DIV ("0b10"),
	) OSC12MHZ (
		.CLKHFEN(1'b1),
		.CLKHFPU(1'b1),
		.CLKHF(wb_clk)
	);

	// Reset handling (5 clock cycles)
	wire wb_rst;
	reg [4:0] rst_reg = 5'b11111;

	always @(posedge wb_clk)
		rst_reg <= {1'b0, rst_reg[4:1]};
	assign wb_rst = rst_reg[0];
	
	// Memory bus
	wire [31:0] 	wb_mem_adr;
	wire [31:0] 	wb_mem_dat;
	wire [3:0] 		wb_mem_sel;
	wire 			wb_mem_we;
	wire 			wb_mem_cyc;
	wire [31:0] 	wb_mem_rdt;
	wire 			wb_mem_ack;

	// Flash memory interface
	wire wb_mem_flash_enabled;
	wire [31:0] wb_mem_rdt_flash;
	wire wb_mem_ack_flash;

	assign wb_mem_flash_enabled = wb_mem_cyc && (wb_mem_adr >= 32'h0010_0000) && (wb_mem_adr < 32'h0200_0000);

	rocketcpu_flashio flash(   
		.reset(wb_rst),

		.i_wb_clk	(wb_clk),
		.i_wb_adr	(wb_mem_adr),
		.i_wb_dat	(wb_mem_dat),
		.i_wb_sel	(wb_mem_sel),
		.i_wb_we	(wb_mem_we),
		.i_wb_cyc	(wb_mem_flash_enabled),
		.o_wb_rdt	(wb_mem_rdt_flash),
		.o_wb_ack	(wb_mem_ack_flash),

		.flash_csb	(flash_csb),
		.flash_clk	(flash_clk),
		.flash_io0	(flash_io0),
		.flash_io1	(flash_io1),
		.flash_io2	(flash_io2),
		.flash_io3	(flash_io3),
	);

	// 128 KB RAM memory interface
	wire wb_mem_ram_enabled;
	wire [31:0] wb_mem_rdt_ram;
	wire wb_mem_ack_ram;

	assign wb_mem_ram_enabled = wb_mem_cyc && wb_mem_adr <  32'h0000_8000;

	rocketcpu_ram ram (
		.i_wb_clk (wb_clk),
		.i_wb_adr (wb_mem_adr),
		.i_wb_cyc (wb_mem_ram_enabled),
		.i_wb_we  (wb_mem_we) ,
		.i_wb_sel (wb_mem_sel),
		.i_wb_dat (wb_mem_dat),
		.o_wb_rdt (wb_mem_rdt_ram),
		.o_wb_ack (wb_mem_ack_ram),
	);

	// Memory mapped audio registers
	wire wb_mem_audio_enabled;
	wire [31:0] wb_mem_rdt_audio;
	wire wb_mem_ack_audio;

	assign wb_mem_audio_enabled = wb_mem_cyc && wb_mem_adr >=  32'h1000_0000  && wb_mem_adr <=  32'h1000_0040;

	rocketcpu_audio_registers audio_regs (
		.i_wb_clk (wb_clk),
		.i_wb_adr (wb_mem_adr),
		.i_wb_cyc (wb_mem_audio_enabled),
		.i_wb_we  (wb_mem_we) ,
		.i_wb_sel (wb_mem_sel),
		.i_wb_dat (wb_mem_dat),
		.o_wb_rdt (wb_mem_rdt_audio),
		.o_wb_ack (wb_mem_ack_audio),

		.param_1(param_1),
		.param_2(param_2),
		.param_3(param_3),
		.param_4(param_4),
		.param_5(param_5),
		.param_6(param_6),
		.param_7(param_7),

		.iparam_1(iparam_1),
	);

	// Memory mapped GPIO
	wire wb_mem_gpio_enabled;
	wire [31:0] wb_mem_rdt_gpio;

	assign wb_mem_gpio_enabled = wb_mem_cyc && wb_mem_adr ==  32'h0200_0000;

	rocketcpu_gpio gpio(
		.i_wb_clk (wb_clk),
		.i_wb_dat (wb_mem_dat),
		.i_wb_we  (wb_mem_we),
		.i_wb_cyc (wb_mem_gpio_enabled),
		.o_wb_rdt (wb_mem_rdt_gpio),

		.o_gpio   (led),
		.i_gpio	  (button),
	);

	// Memory mapped timer
   	wire timer_irq;
	wire wb_mem_timer_enabled;
	wire [31:0] wb_mem_rdt_timer;
	
	assign wb_mem_timer_enabled = wb_mem_cyc && wb_mem_adr ==  32'h0800_0000;

	rocketcpu_timer
      	#(.WIDTH (32)
	) timer (
		.i_wb_clk (wb_clk),
        .i_wb_cyc (wb_mem_timer_enabled),
        .i_wb_we  (wb_mem_we) ,
        .i_wb_dat (wb_mem_dat),
        .o_wb_rdt (wb_mem_rdt_timer),

		.o_irq    (timer_irq),
	);

	// Memory mapped uart
	wire wb_mem_uart_enabled;
	wire [31:0] wb_mem_rdt_uart;
	wire wb_mem_ack_uart;

	assign wb_mem_uart_enabled = wb_mem_cyc && wb_mem_adr ==  32'h0400_0000;

	rocketcpu_uart uart (
		.reset(wb_rst),

		.i_wb_clk (wb_clk),
		.i_wb_adr (wb_mem_adr),
		.i_wb_cyc (wb_mem_uart_enabled),
		.i_wb_we  (wb_mem_we) ,
		.i_wb_sel (wb_mem_sel),
		.i_wb_dat (wb_mem_dat),
		.o_wb_rdt (wb_mem_rdt_uart),
		.o_wb_ack (wb_mem_ack_uart),

		.ser_tx(ser_tx),
		.ser_rx(ser_rx),
	);

	
	// Data and instructions bus arbiter
	wire [31:0] 	wb_dbus_adr;
	wire [31:0] 	wb_dbus_dat;
	wire [3:0] 		wb_dbus_sel;
	wire 			wb_dbus_we;
	wire 			wb_dbus_cyc;
	wire [31:0] 	wb_dbus_rdt;
	wire 			wb_dbus_ack;

	wire [31:0] 	wb_ibus_adr;
	wire 			wb_ibus_cyc;
	wire [31:0] 	wb_ibus_rdt;
	wire 			wb_ibus_ack;

	rocketcpu_arbiter arbiter(
		.i_wb_cpu_dbus_adr (wb_dbus_adr),
		.i_wb_cpu_dbus_dat (wb_dbus_dat),
		.i_wb_cpu_dbus_sel (wb_dbus_sel),
		.i_wb_cpu_dbus_we  (wb_dbus_we ),
		.i_wb_cpu_dbus_cyc (wb_dbus_cyc),
		.o_wb_cpu_dbus_rdt (wb_dbus_rdt),
		.o_wb_cpu_dbus_ack (wb_dbus_ack),

		.i_wb_cpu_ibus_adr (wb_ibus_adr),
		.i_wb_cpu_ibus_cyc (wb_ibus_cyc),
		.o_wb_cpu_ibus_rdt (wb_ibus_rdt),
		.o_wb_cpu_ibus_ack (wb_ibus_ack),

		.o_wb_cpu_adr (wb_mem_adr),
		.o_wb_cpu_dat (wb_mem_dat),
		.o_wb_cpu_sel (wb_mem_sel),
		.o_wb_cpu_we  (wb_mem_we ),
		.o_wb_cpu_cyc (wb_mem_cyc),
		.i_wb_cpu_rdt (wb_mem_rdt),
		.i_wb_cpu_ack (wb_mem_ack)
	);

	assign wb_mem_rdt = (wb_mem_flash_enabled) 	? wb_mem_rdt_flash 	:
						(wb_mem_ram_enabled)	? wb_mem_rdt_ram 	:
						(wb_mem_uart_enabled)	? wb_mem_rdt_uart 	:
						(wb_mem_audio_enabled)	? wb_mem_rdt_audio 	:
						(wb_mem_gpio_enabled)	? wb_mem_rdt_gpio 	:
						(wb_mem_timer_enabled)	? wb_mem_rdt_timer	: 32'b0;

	assign wb_mem_ack = (wb_rst)				? 1'b0				:
						(wb_mem_flash_enabled) 	? wb_mem_ack_flash 	:
						(wb_mem_ram_enabled)	? wb_mem_ack_ram 	:
						(wb_mem_uart_enabled)	? wb_mem_ack_uart 	:
						(wb_mem_audio_enabled)	? wb_mem_ack_audio 	:
						(wb_mem_gpio_enabled)	? 1'b1			 	:
						(wb_mem_timer_enabled)	? 1'b1				: 1'b0;
    
	// SERV core
	serv_rf_top
		#(.RESET_PC (32'h0010_0000)
	) cpu (
		.clk      	  	(wb_clk),
		.i_rst    	  	(wb_rst),
		.i_timer_irq  	(timer_irq),

		.o_ibus_adr   	(wb_ibus_adr),
		.o_ibus_cyc   	(wb_ibus_cyc),
		.i_ibus_rdt   	(wb_ibus_rdt),
		.i_ibus_ack   	(wb_ibus_ack),

		.o_dbus_adr   	(wb_dbus_adr),
		.o_dbus_dat   	(wb_dbus_dat),
		.o_dbus_sel   	(wb_dbus_sel),
		.o_dbus_we    	(wb_dbus_we),
		.o_dbus_cyc   	(wb_dbus_cyc),
		.i_dbus_rdt   	(wb_dbus_rdt),
		.i_dbus_ack   	(wb_dbus_ack)
	);

endmodule
