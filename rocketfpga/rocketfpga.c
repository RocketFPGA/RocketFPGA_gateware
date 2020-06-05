#include <stdint.h>
#include "rocketfpga.h"

uint32_t phase_from_freq(uint32_t freq){
	return freq * POWTWO(PHASE_SIZE) / SAMPLING_FREQ;  
}

uint32_t freq_from_phase(uint32_t phase){
	return phase *  SAMPLING_FREQ / POWTWO(PHASE_SIZE);
}

char getchar(){
	int32_t c = -1;
	while (c == -1) {
		c = reg_uart_data;
	}
	return c;
}

void _putchar(char c){
	reg_uart_data = c;
}

void delay(uint32_t d){
	for (uint32_t i = 0; i < d; i++){
		__asm__ ("nop");
	}
}

// IRQ 
void irq_enable(unsigned int irq)
{
	uint32_t mie;
	__asm__ volatile ("csrrs %0, mie, %1\n" : "=r" (mie) : "r" (1 << irq));
}

uint32_t irq_is_enabled(unsigned int irq)
{
	uint32_t mie;
	__asm__ volatile ("csrr %0, mie" : "=r" (mie));
	return !!(mie & (1 << irq));
}

void irq_global_disable(void)
{	
	uint32_t mstatus;
	__asm__ volatile ("csrrc %0, mstatus, %1" : "=r" (mstatus) : "r" (1 << 3) : "memory");
	__asm__ volatile ("csrwi mie, 0\n"
			          "csrwi mip, 0\n");
}

void irq_global_enable(void)
{	
	uint32_t mstatus;
	__asm__ volatile ("csrrs %0, mstatus, %1\n" : "=r" (mstatus) : "r" (1 << 3));
}