#include <avr/io.h>							//เรียกใช้คลังโปรแกรม io.h
#include <avr/interrupt.h>						//เรียกใช้คลังโปรแกรมสำหรับการขัดจังหวะ
#define F_CPU 16000000UL						//กำหนดค่าความถี่ของการประมวลผลเป็น 16MHz
#include <util/delay.h>							//เรียกใช้คลังโปรแกรมสำหรับการหน่วงเวลา			

unsigned char counter;							//ประกาศตัสแปรชื่อ counter

int main(void){								//ส่วนการทำงานหลักของโปรแกรมฟังก์ชัน main
	DDRB = 0xFF;							//กำหนดทิศทางของ PORTB ให้เป็น output ทั้งหมด
	DDRD = 0x00;							//กำหนดทิศทางของ PORTD ให้เป็น input ทั้งหมด
	PCICR = 0x04;							//เปิดทางการตอบรับการขัดจังหวะที่ PCINT[23:16]
	PCMSK2 = 0xE0;							//อนุญาให้เฉพาะ PCINT[23:21] เท่านั้นที่สามารถขัดจังหวะได้
	counter = 0;							//กำหนดค่าเรื่มต้นให้ตัวแปร counte
	sei();								//เปิดทางการขัดจังหวะส่วนกลาง
	while(1){}							//วนซ้ำแบบไม่รู้จบ
}

ISR(PCINT2_vect){							//ระบุว่าฟังก์ชันบริการการขัดจังหวะนี้เป็นของ PCINT2
	static unsigned char ucInput;					//ประกาศตัวแปร ucInput เพื่อเก็ค่าอินพุตที่อ่านได้
	_delay_ms(50);							//หน่วงเวลา 50 มิลลิวินาที
	ucInput = PIND;							//อ่านค่าจาก PIND มาเก็บในตัวแปร ucInput
	ucInput &= 0xE0;						//เคลียร์ค่าอินพุตส่วนเกินทิ้ง
	ucInput = ucInput >> 5;						//shift ค่า ucInput ไปทางขวา 5 ครั้ง
	switch(ucInput){						//ตรวจสอบกรณีต่าง ๆ ของการกดปุ่ม
		case 1:		counter++;				//กรณีปุ่มทางขวาสุดถูกกดให้เพิ่มค่า counter ขึ้น 1 ค่า
					if(counter>15)			//ถ้า counter มากกว่า 15 ให้วกค่ากลับไปเริ่มต้นที่ 0
						counter = 0;
					break;				//ออกจากการทำงาน switch
		case 2:		counter = 0;				//กรณีปุ่มกลางถูกกดให้ค่า counter กลับไปเป็น 0
					break;				//ออกจากการทำงาน switch
		case 4:		counter--;				//กรณีปุ่มทางซ้ายสุดถูกกดให้ลดค่า counter ลง 1 ค่า
					if(counter < 0)			//ถ้า counter น้อยกว่า 0 ให้วกค่ากลับไปเป็น 15
					counter = 15;
					break;				//ออกจากการทำงาน switch
	}
					
	PORTB = counter;						//ส่งค่าที่เก็บอยู่ในตัวแปร counter ไปแสดงผลที่ LED
	PCIFR = 1 << PCIF2;						//เคลียร์ค่าตัวบ่งชี้การขัดจังหวะจากกลุ่มขาสัญญาน PCINT[23:16]
}
