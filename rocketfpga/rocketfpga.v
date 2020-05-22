`default_nettype none
module rocketfpga
(
	input OSC,

	// GPIO interface
	input  USER_BUTTON,
	output LED,

	// SPI Interface
	output FLASH_CS,
	output CODEC_CS,
	output FLASH_CLK,
	inout  FLASH_IO0,
	inout  FLASH_IO1,
	inout  FLASH_IO2,
	inout  FLASH_IO3,

	//I2S Interface
    output  MCLK,
    input  	BCLK,
    input  	ADCLRC,
    input  	DACLRC,
    input  	ADCDAT,
    output  DACDAT,

	// SPI Codec Interface
	output CODEC_SCLK,
	output CODEC_MOSI,
	output CODEC_CS,

	// UART Interface
	output TXD,
	input  RXD,

	// Low frequency ADC
    // output CAPACITOR,
    // output POT_1,
    // output POT_2,
    // input DIFF_IN,

	// Debug Inteface
	output IO7,
	output IO6,
);

	localparam BITSIZE = 16;
	localparam SAMPLING = 48;

	// RocketCPU
	wire [31:0] osc_1;
	wire [31:0] osc_2;
	wire [31:0] osc_3;
	wire [31:0] osc_4;
	wire [31:0] triggers;
	wire [31:0] adsr;
	wire [31:0] echo_offset;
	wire [31:0] pot_in;

	rocketcpu rocketcpu(
		.external_rst 	(1'b0),
		.led      		(LED),
		.button      	(USER_BUTTON),

		.flash_csb (FLASH_CS),
		.flash_clk (FLASH_CLK),
		.flash_io0 (FLASH_IO0),
		.flash_io1 (FLASH_IO1),
		.flash_io2 (FLASH_IO2),
		.flash_io3 (FLASH_IO3),

		.ser_tx(TXD),
		.ser_rx(RXD),

		.param_1(osc_1),
		.param_2(osc_2),
		.param_3(osc_3),
		.param_4(osc_4),	
		.param_5(triggers),	
		.param_6(adsr),	
		.param_7(echo_offset),

		.iparam_1(pot_in),	
	);

	// Low frequency ADC
	// adc #(
	// 	.OUTSIZE(32),
	// ) ADC1 (
	// 	.pot_1(POT_1),
	// 	.pot_2(POT_2),
	// 	.capacitor(CAPACITOR),
	// 	.osc(OSC),			// 49.152 MHz
	// 	.sense(DIFF_IN),
	// 	.out(pot_in)
	// );

	// Audio clocking and reset
	reg [7:0] divider;
	always @(posedge OSC) begin
		divider <= divider + 1;
	end

	assign MCLK = divider[1]; // 12.288 MHz

	configurator #(
		.BITSIZE(BITSIZE),
		.SAMPLING(SAMPLING),
		.LINE_NOMIC(1'b0),
		.ENABLE_MICBOOST(1'b1),
	) conf (
		.clk(divider[6]),
		.spi_mosi(CODEC_MOSI), 
		.spi_sck(CODEC_SCLK),
		.cs(CODEC_CS),
		.prereset(1'b1),
		.done()
	);

	wire signed [BITSIZE-1:0] mic;

	i2s_rx #( 
		.BITSIZE(BITSIZE),
	) I2SRX (
		.sclk (BCLK), 
		.lrclk (ADCLRC),
		.sdata (ADCDAT),
		.left_chan (mic),
	);

	// Multi waveform generator
	wire [BITSIZE-1:0] out_generator [0:3];
	localparam PHASE_SIZE = 16;
	`define CALCULATE_PHASE_FROM_FREQ(f) $rtoi(f * $pow(2,PHASE_SIZE) / (SAMPLING * 1000.0))

	multigenerator #(
		.BITSIZE(BITSIZE),
		.PHASESIZE(PHASE_SIZE),
		.TABLESIZE(12),
	) S1 (
		.lrclk(DACLRC),
		.bclk(BCLK),
		.osc(OSC),

		.enable_1(triggers[1]),
		.enable_2(triggers[2]),
		.enable_3(triggers[3]),
		.enable_4(triggers[4]),

		.out_1(out_generator[0]),
		.out_2(out_generator[1]),
		.out_3(out_generator[2]),
		.out_4(out_generator[3]),

		.freq_1(osc_1),
		.freq_2(osc_2),
		.freq_3(osc_3),
		.freq_4(osc_4),
	);

	wire [BITSIZE-1:0] m1_out;

	mixer4_fixed #(
    	.BITSIZE(BITSIZE),
	) MX1 (
		.in1(out_generator[0]),
		.in2(out_generator[1]),
		.in3(out_generator[2]),
		.in4(out_generator[3]),
		.out(m1_out),
	);

	wire signed [BITSIZE-1:0] envelope;
	envelope_generator #(
		.SAMPLE_CLK_FREQ(48000),
		.ACCUMULATOR_BITS(16),
	) ENV1 (
		.clk(DACLRC),
		.gate(triggers[0]),
		.a(adsr[31 -: 4]),
		.d(adsr[27 -: 4]),
		.s(adsr[23 -: 4]),
		.r(adsr[19 -: 4]),
		.amplitude(envelope),
	);

	wire signed [BITSIZE-1:0] mult_out;
	multiplier #(
		.BITSIZE(BITSIZE),
	) M1 (
		.in1(envelope),
		.in2(m1_out),
		.out(mult_out),
	);

	wire signed [BITSIZE-1:0] echo_out;

	echo #( 
		.BITSIZE(BITSIZE),
	) E1 (
		.enable(triggers[5]),
		.bclk (BCLK), 
		.lrclk (ADCLRC),
		.offset(echo_offset),
		.in (mult_out),
		.out (echo_out),
	);

	i2s_tx #( 
		.BITSIZE(BITSIZE),
	) I2STX (
		.sclk (BCLK), 
		.lrclk (DACLRC),
		.sdata (DACDAT),
		.left_chan (mult_out + echo_out),
		.right_chan (mult_out + echo_out)
	);




endmodule
