#include <avr/io.h>
#include <avr/interrupt.h>
#define F_CPU 16000000UL
#include <util/delay.h>

unsigned char counter;

int main(void){
	DDRB = 0xFF;
	DDRD = 0x00;
	PCMSK2 = 0xE0;
	PCICR = 0x04;
	counter = 0;
	sei();
	while(1){}
}

ISR(PCINT2_vect){
	static unsigned char ucInput;
	_delay_ms(50);
	ucInput = PIND;
	ucInput &= 0xE0;
	ucInput = ucInput >> 5;
	switch(ucInput){
		case 1:		counter++;
					if(counter>15)
						counter = 0;
					break;
		case 2:		counter = 0;
					break;
		case 4:		counter--;
					if(counter < 0)
					counter = 15;
					break;
	}
					
	PORTB = counter;
	PCIFR = 1 << PCIF2;
}