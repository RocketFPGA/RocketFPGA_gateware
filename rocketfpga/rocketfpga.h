#ifndef _ROCKETFPGA_H
#define _ROCKETFPGA_H

// Global configuration
#define MEM_LEN  32768  // 32 kB
#define CLK_HZ  12000000  // 12 MHz
#define PHASE_SIZE  16  
#define SAMPLING_FREQ  48000  

#define POWTWO(EXP) (1 << (EXP))

// Memory mapped GPIO
#define gpio  (*(volatile uint32_t*) 0x02000000)
#define GPIO_LED  	 0x1
#define GPIO_BUTTON  0x2

// Memory mapped UART
#define reg_uart_data (*(volatile uint32_t*)0x04000000)

// Memory mapped timer
#define timer (*(volatile uint32_t*)0x08000000)

// Memory mapped oscillators
static uint32_t * oscs = 0x10000000;
#define osc1 (*(volatile uint32_t*)0x10000000)
#define osc2 (*(volatile uint32_t*)0x10000004)
#define osc3 (*(volatile uint32_t*)0x10000008)
#define osc4 (*(volatile uint32_t*)0x1000000C)

#define osc_type (*(volatile uint32_t*)0x10000028)
#define OSC1_TYPE 30
#define OSC2_TYPE 28
#define OSC3_TYPE 26
#define OSC4_TYPE 24

#define SINE_TYPE 0
#define RAMP_TYPE 1
#define SQUARE_TYPE 2
#define TRIANGLE_TYPE 3

#define set_osc_type(x,a) 	osc_type = 	(osc_type & ~(0x3 << x)) | ((a & 0x3) << x)

// Memory mapped echo
#define echo_delay (*(volatile uint32_t*)0x10000014)

// Memory mapped triggers and enablers
#define triggers (*(volatile uint32_t*)0x10000010)
#define ADRS_TRIGGER 0
#define OSC1_ENABLE 1
#define OSC2_ENABLE 2
#define OSC3_ENABLE 3
#define OSC4_ENABLE 4
#define ECHO_ENABLE 5

#define enable_trigger(n)		triggers |= 1UL << n
#define disable_trigger(n)		triggers &= ~(1UL << n)
#define toogle_trigger(n)		triggers ^= 1UL << n
#define get_trigger(n)			(triggers >> n) & 1U
#define set_trigger(n,v)		(v) ? enable_trigger(n) : disable_trigger(n)

// Memory mapped matrix
#define matrix_1 (*(volatile uint32_t*)0x10000018)
#define matrix_2 (*(volatile uint32_t*)0x1000001C)
#define MATRIX_IN 10
#define MATRIX_OUT 12

#define MATRIX_MIXER4_IN_1 1
#define MATRIX_MIXER4_IN_2 2
#define MATRIX_MIXER4_IN_3 3
#define MATRIX_MIXER4_IN_4 4
#define MATRIX_MULT_IN_1   5
#define MATRIX_MULT_IN_2   6
#define MATRIX_ECHO_IN     7
#define MATRIX_OUTPUT_R    8
#define MATRIX_OUTPUT_L    9
#define MATRIX_MOD_IN_1    10
#define MATRIX_MOD_IN_2    11

static const char *matrix_out_names[MATRIX_OUT+1] = {"", "MATRIX_MIXER4_IN_1",
                                          "MATRIX_MIXER4_IN_2",
                                          "MATRIX_MIXER4_IN_3",
                                          "MATRIX_MIXER4_IN_4",
                                          "MATRIX_MULT_IN_1",
                                          "MATRIX_MULT_IN_2",
                                          "MATRIX_ECHO_IN",
                                          "MATRIX_OUTPUT_R",
                                          "MATRIX_OUTPUT_L",
                                          "MATRIX_MOD_IN_1",
                                          "MATRIX_MOD_IN_2"};

#define MATRIX_NONE         0
#define MATRIX_OSC_1        1
#define MATRIX_OSC_2        2
#define MATRIX_OSC_3        3
#define MATRIX_OSC_4        4
#define MATRIX_MIXER4_OUT   5
#define MATRIX_MULT_OUT     6
#define MATRIX_ECHO_OUT     7
#define MATRIX_ENVELOPE_OUT 8
#define MATRIX_MOD_OUT      9
#define MATRIX_LINE_MIC     10

static const char *matrix_in_names[MATRIX_IN] = {"MATRIX_NONE",
                                                    "MATRIX_OSC_1",
                                                    "MATRIX_OSC_2",
                                                    "MATRIX_OSC_3",
                                                    "MATRIX_OSC_4",
                                                    "MATRIX_MIXER4_OUT",
                                                    "MATRIX_MULT_OUT",
                                                    "MATRIX_ECHO_OUT",
                                                    "MATRIX_ENVELOPE_OUT",
                                                    "MATRIX_MOD_OUT",
                                                    "MATRIX_LINE_MIC"};



#define set_matrix_1(in, out) 	 matrix_1 = ((matrix_1 & ~(0xF << (4*(out-1)))) | ((in & 0xF) << (4*(out-1))))
#define set_matrix_2(in, out) 	 matrix_2 = ((matrix_2 & ~(0xF << (4*(out-1)))) | ((in & 0xF) << (4*(out-1))))
#define set_matrix(in, out) 	 if(out <= 8){set_matrix_1(in, out);}else{set_matrix_2(in, out-8);};

// Memory mapped ADSR
static uint32_t * adsr1 = 0x10000020;

#define set_attack(x,a) 	x[0] = 	(x[0] & 0x0000FFFF) 	| ((a & 0x0000FFFF) << 16)
#define set_decay(x,a) 		x[0] = 	(x[0] & 0xFFFF0000) 	| (a & 0x0000FFFF)
#define set_sustain(x,a) 	x[1] = 	(x[1] & 0x0000FFFF) 	| ((a & 0x0000FFFF) << 16)
#define set_release(x,a) 	x[1] = 	(x[1] & 0xFFFF0000) 	| (a & 0x0000FFFF)

// Memory mapped ADC
#define adc_1 (*(volatile uint32_t*)0x10010000)

// Memory mapped modulator
#define modulator1 (*(volatile uint32_t*)0x1000002C)

#define set_modulation_gain(a) 	    modulator1 = 	(modulator1 & 0x0000FFFF) 	| ((a & 0x0000FFFF) << 16)
#define set_modulation_offset(a) 	modulator1 = 	(modulator1 & 0xFFFF0000) 	| (a & 0x0000FFFF)


#endif  // _ROCKETFPGA_H