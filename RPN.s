	AREA	ReversePolish, CODE, READONLY
	IMPORT	main
	EXPORT	start
start
		ldr r1, =rpnexp
		ldr r5, =0x0
		ldr r13, =0xA1000400	
		str r5, [r13], #4
		str r5, [r13]
			
read		ldrb r2, [r1], #1
		cmp r2, #0x0
		beq stop
		cmp r2, #0x20 ;space char
		beq spacechar
		cmp r2, #0x2f	
		ble getoperator
		cmp r2, #0x5e ;next value is power
		bge power_or_n
		sub r2, #0x30
		b pushstack
			
pushstack	ldr r4, [r13] ;load last entry in stack, multiply by 10, add new val
		ldr r3, =0xA
		mul r4, r3, r4
		add r4, r2
		str r4, [r13]
		b read
			
spacechar	ldr r6, [r13]
		ldr r0, [r13, #-4]
		add r13, #0x4
		b read
			
pushresult	str r5, [r13]
		str r5 , [r13, #-4]
		str r0, [r13, #-8]!
		b read

getoperator	cmp r2, #0x2A
		beq mul_power
		cmp r2, #0x2B
		beq addition
		cmp r2, #0x2D
		beq subtract
		cmp r2, #0x2F
		beq division
		mov r0, r6
		b factorial
		
power_or_n	cmp r2, #0x6e
		beq negation
		b prepower
		
addition	add r0, r6, r0
		b pushresult
prepower	mov r3, r6
		mov r6, r0			
mul_power	mul r0, r6, r0
		cmp r2, #0x5e
		bne pushresult
		sub r3, #0x1
		cmp r3, #0x1
		bne mul_power
		b pushresult
		
subtract	sub r0, r6
		cmp r2, #0x2F
		bne pushresult
		add r5, #0x1
division	cmp r0, r6	;call the subtraction subroutine in a loop	
		bge subtract
		mov r0, r5
		ldr r5, =0x0
		b pushresult
		
factorial	sub r0, #0x1
		mul r6, r0, r6
		cmp r0, #0x1
		bne factorial
		str r6, [r13, #-4]!
		b read

negation	neg r6, r6
		str r5, [r13]
		str r6, [r13, #-4]!
		b read
		
stop	B	stop
	AREA	ReversePolish, DATA, READWRITE
rpnexp	DCB	"33 3 3 ^ n + 1000 10 / 4 ! + *",0 
	END
