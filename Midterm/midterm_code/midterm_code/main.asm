.include "m328pdef.inc"				;อ่านค่าจากคลังโปรแกรมซึ่งเก็บในแฟ้ม m328pdef.inc
.def clear_in = R16				;กำหนดชื่อสัญลักษณ์ให้ R16 แทนด้วยตัวแปร clear_in
.def counter = R17				;กำหนดชื่อสัญลักษณ์ให้ R17 แทนด้วยตัวแปร counter
.def temp = R18					;กำหนดชื่อสัญลักษณ์ให้ R18 แทนด้วยตัวแปร temp
.def input = R19				;กำหนดชื่อสัญลักษณ์ให้ R19 แทนด้วยตัวแปร input
.equ input8bit = 0x00				;ค่าสำหรับกำหนดพอร์ตเป็นทิศทางนำเข้าข้อมูลทั้ง 8 บิต
.equ output8bit = 0xFF				;ค่าสำหรับกำหนดพอร์ตเป็นทิศทางส่งออกข้อมูลทั้ง 8 บิต
.equ up_btn = 0x20				;กำหนดให้ up_btn หมายถึงค่า 0x20
.equ rst_btn = 0x40				;กำหนดให้ rst_btn หมายถึงค่า 0x40
.equ dwn_btn = 0x80				;กำหนดให้ dwn_btn หมายถึงค่า 0x80

.cseg						;เริ่มต้น code segment
.org 0x0000					;กำหนดเริ่มต้นโปรแกรมที่ตำแหน่ง 0x0000
	rjmp SETUP				;กระโดดไปทำงานที่ SETUP
SETUP:						;ส่วนคำสั่งที่ใช้กำหนดค่าเริ่มต้นให้กับวงจร
	ldi temp, output8bit			;ค่าสำหรับกำหนดให้พอร์ตเป็นเอาท์พุตทั้ง 8 บิต
	out DDRB, temp				;กำหนดให้พอร์ต B เป็นเอาท์พุตทั้ง 8 บิต
	ldi temp, input8bit			;ค่าสำหรับกำหนดให้พอร์ตเป็นอินพุตทั้ง 8 บิต
	out DDRD, temp				;กำหนดให้พอร์ต D เป็นอินพุตทั้ง 8 บิต
	ldi counter, 0x00			;กำหนดค่าเริ่มต้นให้ตัวแปร counter มีค่า 0
	ldi clear_in, 0b11100000		;กำหนดให้ตัวแปร clear_in มีค่าเป็น 0b11100000
MAIN_LOOP:					;ส่วนคำสั่งวนซ้ำการทำงานหลัก
	in input, PIND				;อ่านค่าจาก PIND มาเก็บในตัวแปร input
	and input, clear_in			;ทำการเคลียร์ต่าอินพุตที่ไม่ต้องการออก
	cpi input, rst_btn			;ตรวจสอบว่าอินพุตที่ได้เป็นการกดปุ่ม rst_btn หรือไม่
	breq RESET				;ถ้าใช่ กระโดดไปทำงานที่ส่วนคำสั่ง RESET
	cpi input, up_btn			;ตรวจสอบว่าอินพุตที่ได้เป็นการกดปุ่ม up_btn หรือไม่
	breq UP_VAL				;ถ้าใช่ กระโดดไปทำงานที่ส่วนคำสั่ง UP_VAL
	cpi input, dwn_btn			;ตรวจสอบว่าอินพุตที่ได้เป็นการกดปุ่ม dwn_btn หรือไม่
	breq DOWN_VAL				;ถ้าใช่ กระโดดไปทำงานที่ส่วนคำสั่ง DOWN_VAL
SHOW_OUT:					;ส่วนคำสั่งที่ทำหน้าที่แสดงค่าออกทาง LED
	mov temp, counter			;คัดลอกค่า counter ไปเก็บไว้ใน temp
	out PORTB, temp				;ส่งค่าที่เก็บใน temp ไปแสดงค่าใน PORTB
	rjmp MAIN_LOOP				;กระโดดกลับไปทำงานที่ MAIN_LOOP
DELAY_F:					;ส่วนคำสั่งย่อย สำหรับการหน่วงเวลา
	ldi r31,41				;กำหนดค่าให้ R31 มีค่าเท่ากับ 41
	ldi r30,150				;กำหนดค่าให้ R30 มีค่าเท่ากับ 150
	ldi r20, 128				;กำหนดค่าให้ R20 มีค่าเท่ากับ 128
L1: dec r20					;ลดค่าใน R20 ลง 1 ค่า
	brne L1					;ถ้าค่าใน R20 ไม่เท่ากับ 0 กระโดดกลับไปยัง L1
	dec r30					;ลดค่า R30 ลง 1 ค่า
	brne L1					;ถ้าค่าใน R30 ไม่เท่ากับ 0 กระโดดกลับไปยัง L1
	dec r31					;ลดค่า R31 ลง 1 ค่า
	brne L1					;ถ้าค่าใน R31 ไม่เท่ากับ 0 กระโดดกลับไปยัง L1
	ret					;รีเทิร์นกลับไปทำงานคำสั่งหลัง Subroutine call 

RESET:						;ส่วนการทำงาน ปุ่ม rst_btn ถูกกด
	ldi counter, 0x00			;กดหนดค่าของตัวแปร counter ให้มีค่าเท่ากับ 0
	rcall DELAY_F				;เรียกใช้ subroutine ชื่อ DELAY_F
	rjmp SHOW_OUT				;กระโดดไปทำงานที่ส่วนของการแสดงผลออกทาง LED
UP_VAL:
	inc counter				;เพิ่มค่าในตัวแปร counter ขึ้น 1 ค่า
	call DELAY_F				;เรียกใช้ subroutine ชื่อ DELAY_F
	rjmp SHOW_OUT				;กระโดดไปทำงานที่ส่วนของการแสดงผลออกทาง LED
DOWN_VAL:
	dec counter				;ลดค่าในตัวแปร counter ลง 1 ค่า 
	rcall DELAY_F				;เรียกใช้ subroutine ชื่อ DELAY_F
	rjmp SHOW_OUT				;กระโดดไปทำงานที่ส่วนของการแสดงผลออกทาง LED

