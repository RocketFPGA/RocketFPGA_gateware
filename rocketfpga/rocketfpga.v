`default_nettype none
module rocketfpga
(
	input OSC,

	// GPIO interface
	input  PRE_RESET,
	output LED,

	// SPI Interface
	output FLASH_CS,
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

	// -- Pots Shield --
	// Fix for first unit v2
	// output IO0,
	// output IO1,
	output IO2,
	output IO3,
	// ChalieLEDS
	inout IO4,
	inout IO5,
	inout IO6,
	inout IO7,
	// External ADC
	output IO8,  //CLK
	input  IO9,  //DOUT
	output IO10, //DIN
	output IO11, //N_CS
	// Buttons
	input IO12, //B1
	input IO13, //B2
	input IO14, //B3
	input IO15, //B4
);

	localparam BITSIZE = 16;
	localparam SAMPLING = 48;

	// RocketCPU
	wire [31:0] osc_1;
	wire [31:0] osc_2;
	wire [31:0] osc_3;
	wire [31:0] osc_4;
	wire [31:0] triggers;
	wire [31:0] echo_offset;
	wire [31:0] pot_in;

	wire [31:0] adsr1_1;
	wire [31:0] adsr1_2;

	wire [31:0] matrix_1;
	wire [31:0] matrix_2;

	wire [31:0] osc_type;

	wire [31:0] modulator;

	wire [31:0] coefs_1;
	wire [31:0] coefs_2;
	wire [31:0] coefs_3;

	wire [31:0] echo_gains;

	wire [31:0] compressor_params;
	wire [31:0] compressor_params2;

	rocketcpu rocketcpu(
		.external_rst 	(1'b0),
		.led      		(LED),

		.flash_csb (FLASH_CS),
		.flash_clk (FLASH_CLK),
		.flash_io0 (FLASH_IO0),
		.flash_io1 (FLASH_IO1),
		.flash_io2 (FLASH_IO2),
		.flash_io3 (FLASH_IO3),

		.ser_tx(TXD),
		.ser_rx(RXD),

		.codec_di(CODEC_MOSI),
		.codec_clk(CODEC_SCLK),
		.codec_cs(CODEC_CS),

		.param_1(osc_1),
		.param_2(osc_2),
		.param_3(osc_3),
		.param_4(osc_4),	
		.param_5(triggers),	
		.param_6(echo_offset),	
		.param_7(matrix_1),
		.param_8(matrix_2),
		.param_9(adsr1_1),
		.param_10(adsr1_2),
		.param_11(osc_type),
		.param_12(modulator),
		.param_13(coefs_1),
		.param_14(coefs_2),
		.param_15(coefs_3),
		.param_16(echo_gains),
		.param_17(compressor_params),
		.param_18(compressor_params2),

		// Pots Shield specific
		.charlieleds({IO4, IO5, IO6, IO7}),
		.spi_adc({IO11, IO10, IO9, IO8}),
		.buttons({!IO15, !IO14, !IO13, !IO12}),
	);

	// Audio clocking and reset
	reg [13:0] divider;
	always @(posedge OSC) begin
		divider <= divider + 1;
	end

	assign MCLK = divider[1]; // 12.288 MHz

	// Line input or mic
	wire signed [BITSIZE-1:0] in_l;
	wire signed [BITSIZE-1:0] in_r;
	i2s_rx #( 
		.BITSIZE(BITSIZE),
	) I2SRX (
		.sclk (BCLK), 
		.lrclk (ADCLRC),
		.sdata (ADCDAT),
		.left_chan (in_l),
		.right_chan (in_r),
	);

	// Multi waveform generator
	wire [BITSIZE-1:0] generator_out [0:3];
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

		.enable_1(1),
		// .type_1(osc_type[31 -: 2]),
		.out_1(generator_out[0]),
		.freq_1(osc_1),

		// .enable_2(1),
		// // .type_2(osc_type[29 -: 2]),
		// .out_2(generator_out[1]),
		// .freq_2(osc_2),

		// .enable_3(1),
		// // .type_3(osc_type[27 -: 2]),
		// .out_3(generator_out[2]),
		// .freq_3(osc_3),

		// .enable_4(1),
		// // .type_4(osc_type[25 -: 2]),
		// .out_4(generator_out[3]),
		// .freq_4(osc_4),
	);

	// Compressor
	wire [BITSIZE-1:0] compressor_in;
	wire [BITSIZE-1:0] compressor_out;

	compressor #(
    	.BITSIZE(BITSIZE),
	) C1 (
		.bclk (BCLK), 
		.lrclk (ADCLRC),
		.in(compressor_in),
		.thr(compressor_params[31 -: 16]),
		.ratio(compressor_params[15 -: 16]),
		.attack(compressor_params2[31 -: 16]),
		.releas(compressor_params2[15 -: 16]),
		.out(compressor_out),
	);

	// Mixer 4
	wire [BITSIZE-1:0] mixer_in [0:3];
	wire [BITSIZE-1:0] mixer_out;

	// mixer4_fixed #(
    // 	.BITSIZE(BITSIZE),
	// ) MX1 (
	// 	.clk(DACLRC),
	// 	.in1(mixer_in[0]),
	// 	.in2(mixer_in[1]),
	// 	.in3(mixer_in[2]),
	// 	.in4(mixer_in[3]),
	// 	.out(mixer_out),
	// );

	// ADSR
	wire signed [BITSIZE-1:0] adsr_in;
	wire signed [BITSIZE-1:0] adsr_out;

	// envelope_generator ENV1 (
	// 	.clk (ADCLRC),
	// 	.gate (triggers[0]),
	// 	.att (adsr1_1[31 -: 16]),
	// 	.dec (adsr1_1[15 -: 16]),
	// 	.sus (adsr1_2[31 -: 16]),
	// 	.rel (adsr1_2[15 -: 16]),

	// 	.in (adsr_in),
	// 	.out (adsr_out),
	// );

	// Echo
	wire signed [BITSIZE-1:0] echo_in;
	wire signed [BITSIZE-1:0] echo_out;

	// echo #( 
	// 	.BITSIZE(BITSIZE),
	// ) E1 (
	// 	.enable(triggers[5]),
	// 	.bclk (BCLK), 
	// 	.lrclk (ADCLRC),
	// 	.offset(echo_offset),
	// 	.dry_gain (echo_gains[31 -: 16]),
	// 	.wet_gain (echo_gains[15 -: 16]),
	// 	.in (echo_in),
	// 	.out (echo_out),
	// );

	// Modulator
	wire signed [BITSIZE-1:0] mod_in1;
	wire signed [BITSIZE-1:0] mod_in2;
	wire signed [BITSIZE-1:0] mod_out;

	// modulator #( 
	// 	.BITSIZE(BITSIZE),
	// ) MOD1 (
	// 	.bclk (BCLK), 
	// 	.lrclk (ADCLRC),
	// 	.in1(mod_in1),
	// 	.in2 (mod_in2),
	// 	.a (modulator[31 -: 16]),
	// 	.b (modulator[15 -: 16]),
	// 	.out (mod_out),
	// );

	// Biquad
	wire signed [BITSIZE-1:0] biquad_in;
	wire signed [BITSIZE-1:0] biquad_out;

	// biquad #( 
	// 	.BITSIZE(BITSIZE),
	// ) BQD1 (
	// 	.bclk (BCLK), 
	// 	.lrclk (ADCLRC),

	// 	.in (biquad_in),
	// 	.out (biquad_out),

	// 	.a0 (coefs_1[31 -: 16]),
	// 	.a1 (coefs_1[15 -: 16]),
	// 	.a2 (coefs_2[31 -: 16]),
	// 	.b1 (coefs_2[15 -: 16]),
	// 	.b2 (coefs_3[31 -: 16]),
	// );

	// Line out
	wire signed [BITSIZE-1:0] out_r;
	wire signed [BITSIZE-1:0] out_l;

	i2s_tx #( 
		.BITSIZE(BITSIZE),
	) I2STX (
		.sclk (BCLK), 
		.lrclk (DACLRC),
		.sdata (DACDAT),
		.left_chan (out_l),
		.right_chan (out_r)
	);

	matrix #( 
	.BITSIZE(BITSIZE),
	) M10x11 (
		.clk(DACLRC),
		
		.in1(generator_out[0]),
		.in2(generator_out[1]),
		.in3(generator_out[2]),
		.in4(generator_out[3]),
		.in5(mixer_out),
		.in6(adsr_out),
		.in7(echo_out),
		.in8(compressor_out),
		.in9(mod_out),
		.in10(in_l),
		.in11(in_r),
  		.in12(biquad_out),

		.out1(mixer_in[0]),
		.out2(mixer_in[1]),
		.out3(mixer_in[2]),
		.out4(mixer_in[3]),
		.out5(adsr_in),
		.out6(compressor_in),
		.out7(echo_in),
		.out8(out_r),
		.out9(out_l),
		.out10(mod_in1),
		.out11(mod_in2),
		.out12(biquad_in),

		.sel_out8(matrix_1[31 -: 4]),
		.sel_out7(matrix_1[27 -: 4]),
		.sel_out6(matrix_1[23 -: 4]),
		.sel_out5(matrix_1[19 -: 4]),
		.sel_out4(matrix_1[15 -: 4]),
		.sel_out3(matrix_1[11 -: 4]),
		.sel_out2(matrix_1[7 -: 4]),
		.sel_out1(matrix_1[3 -: 4]),

		.sel_out12(matrix_2[15 -: 4]),
		.sel_out11(matrix_2[11 -: 4]),
		.sel_out10(matrix_2[7 -: 4]),
		.sel_out9(matrix_2[3 -: 4]),
	);

endmodule
