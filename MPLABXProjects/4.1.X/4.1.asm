.include "m328PBdef.inc"
 .def counter = r26 
.org 0x00
    jmp reset
.org  0x2A ;ADC Conversion complete Interrupt
     push r16
     push r17
     lds r21,ADCL
     lds r20,ADCH 
     ldi r16,10
     loop1:
       ROR r21
       ror r20
       subi r16,1
       cpi r16,0
       brne loop1 
     ;div ision with 1024 has happen 
     ;first 10bit adc
     ;adc9  -adc0,dekatika
     MOVW r16,r20 ; copy register pair
     ROL r20
     ROL r21 ; *2     
     add r20,r16
     adc r21,r17
     ;+1  *5
     pop r16
     pop r17
    reti
reset:
    ldi r24,high(RAMEND)
    out SPH,r24
    ldi r24,low(RAMEND)
    out SPL,r24 ;set stack  initializations 
    ldi r24,0x60 ; ADLAR : left agustmeny REF:01 vref =5V mode ADC0 0000
    sts ADMUX,r24 
    ldi r24,0x8F
    sts ADCSRA,r24 
    ldi r24,0x3F ;
    out DDRB,r24 ; set pB0 - pB5 outputs    
    clr counter 
    sei ;         
start:
        sbi PORTD ,PIND3
        lds r24, ADCSRA ;	
        ori r24, (1<<ADSC) ; Set ADSC flag of ADCSRA
        sts ADCSRA, r24
	wait_adc:
	    lds r24,ADCSRA 
	   ;   andi r24,0xBF
	   ; sts ADCSRA, r24
	    sbrc r24,ADSC
	    rjmp wait_adc
	;delay 
	ldi r24,low(2)
	ldi r25,high(2) ;wait 2ms
	rcall wait_msec
	;r20 ,r21 answer < 5 pd2 - pd0
	andi  r21,0x01 ;
	ROL r20
	ROL r21
	ROL r20
	ROL r21;
	;r21 has decimal r20 digits
	rcall  build_digits
	rcall build_decimals2
	;r16 r17 decimals
	display:
	    rcall lcd_init ; ???????????? ??????
	    ldi r24, low(2)
	    ldi r25, high(2) ; ??????? 2 msec
	    rcall wait_msec
            rcall call_digits
	   ; mov r24,r20
	   ldi r24,'A'
            rcall lcd_data ; ????????  ???? byte ????????? ???? ??????? ??? ?????? lcd
	    ldi r24, low(2)
	    ldi r25, high(2) ; ??????? 2 msec
	    rcall wait_msec
	   ; ldi r24,'.'
	    ;rcall lcd_data 
	    ldi r24, low(2)
	    ldi r25, high(2) ; ??????? 2 msec
	    rcall wait_msec
	    mov r20,r16
	    rcall call_digits
	    rcall lcd_data 
	       ldi r24, low(2)
	    ldi r25, high(2) ; ??????? 2 msec
	    rcall wait_msec
	    mov r20,r17
	   ; rcall call_digits
	    rcall lcd_data 	    
ldi r24, low(2)
ldi r25, high(2) ; ??????? 2 sec
rcall wait_msec
	    ;pb ;
	    rcall portbcounter 	    	    
ldi r24, low(1000)
ldi r25, high(1000) ; ??????? 1 sec
rcall wait_msec
rjmp start
call_digits:
    cpi r20,0x00 
    brne nextop
    ldi r20,'0'
    ret
    nextop:
    cpi r20,0x01 
    brne nextop1
    ldi r20,'1'
    ret
    nextop1:
     cpi r20,0x02 
    brne nextop2
    ldi r20,'2'
    ret
    nextop2:
     cpi r20,0x03 
    brne nextop3
    ldi r20,'3'
    ret
    nextop3:
    cpi r20,0x04 
    brne nextop4
    ldi r20,'4'
    ret
    nextop4:
    cpi r20,0x05 
    brne nextop5
    ldi r20,'5'
    ret
    nextop5:
     cpi r20,0x06 
    brne nextop6
    ldi r20,'6'
    ret
    nextop6:
     cpi r20,0x07 
    brne nextop7
    ldi r20,'7'
    ret
    nextop7:
    cpi r20,0x08 
    brne nextop8
    ldi r20,'8'
    ret
    nextop8:
    cpi r20,0x08 
    brne nextop9
    ldi r20,'8'
    ret
     nextop9:
    cpi r20,0x09 
    brne nextop10
    ldi r20,'9'
    ret
    nextop10:
    ret 
    build_digits:
	push r16
	push r17
	push r18
	push r19
	clr r16
	ldi r17,0x32 ;50
	ldi r18,6;
	mov r19,r21 
	loopdigits:
	  andi r19,0x80
	  cpi r19,0x80
	  brne notaddr17
	  add r16,r17
	  notaddr17:
	  lsr r17 ;/2
	  lsl r21
	  mov r19,r21 
	  subi r18,1
	  cpi r18,0
	  brne loopdigits
	  mov r21,r16	  
        pop r19  
	pop r18
	pop r17
	pop r16
    ret
	write_2_nibbles:
	    push r24 ; ??????? ?? 4 MSB
	    in r25 ,PIND ; ??????????? ?? 4 LSB ??? ?? ?????????????
	    andi r25 ,0x0f ; ??? ?? ??? ????????? ??? ????? ??????????? ?????????
	    andi r24 ,0xf0 ; ????????????? ?? 4 MSB ???
	    add r24 ,r25 ; ???????????? ?? ?? ???????????? 4 LSB
	    out PORTD ,r24 ; ??? ???????? ???? ?????
	    sbi PORTD ,PIND3;  ????????????? ?????? Enable ???? ????????? PD3
	    cbi PORTD ,PIND3 ; PD3=1 ??? ???? PD3=0
	    pop r24 ; ??????? ?? 4 LSB. ????????? ?? byte.
	    swap r24 ; ????????????? ?? 4 MSB ?? ?? 4 LSB
	    andi r24 ,0xf0 ; ??? ?? ??? ????? ???? ?????????????
	    add r24 ,r25
	    out PORTD ,r24
	    sbi PORTD ,PIND3 ; ???? ?????? Enable
	    nop 
	    nop
	    cbi PORTD ,PIND3
	    nop
	    nop
            ret
	    lcd_data:
		sbi PORTD ,PIND2 ; ??????? ??? ?????????? ????????? (PD2=1)
		rcall write_2_nibbles ; ???????? ??? byte
		ldi r24 ,43 ; ??????? 43?sec ????? ?? ??????????? ? ????
		ldi r25 ,0 ; ??? ????????? ??? ??? ??????? ??? lcd
		rcall wait_usec	
		ret
            
            lcd_command:
		cbi PORTD ,PIND2 ; ??????? ??? ?????????? ??????? (PD2=1)
		rcall write_2_nibbles ; ???????? ??? ??????? ??? ??????? 39?sec
		ldi r24 ,39 ; ??? ??? ?????????? ??? ????????? ??? ??? ??? ??????? ??? lcd.
		ldi r25 ,0 ; ???.: ???????? ??? ???????, clear display ??? return home,
		rcall wait_usec ; ??? ???????? ????????? ?????????? ??????? ????????.
		ret
	lcd_init:
ldi r24 ,40 ; ???? ? ???????? ??? lcd ????????????? ??
ldi r25 ,0 ; ????? ??????? ??? ???? ??? ????????????.
rcall wait_msec ; ??????? 40 msec ????? ???? ?? ???????????.
ldi r24 ,0x30 ; ?????? ????????? ?? 8 bit mode
out PORTD ,r24 ; ?????? ??? ???????? ?? ??????? ???????
 sbi PORTD ,PIND3;?? ?? ?????????? ??????? ??? ???????
cbi PORTD ,PIND3 ; ??? ??????, ? ?????? ???????????? ??? ?????
ldi r24 ,39
ldi r25 ,0 ; ??? ? ???????? ??? ?????? ????????? ?? 8-bit mode
rcall wait_usec ; ??? ?? ?????? ??????, ???? ?? ? ???????? ???? ??????????
 ; ??????? 4 bit ?? ??????? ?? ?????????? 8 bit
 ldi r24 ,0x30
out PORTD ,r24
 sbi PORTD ,PIND3
cbi PORTD ,PIND3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x20 ; ?????? ?? 4-bit mode
out PORTD ,r24
 sbi PORTD ,PIND3
cbi PORTD ,PIND3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
 ldi r24 ,0x28 ; ??????? ?????????? ???????? 5x8 ????????
 rcall lcd_command ; ??? ???????? ??? ??????? ???? ?????
ldi r24 ,0x0c ; ???????????? ??? ??????, ???????? ??? ???????
 rcall lcd_command
 ldi r24 ,0x01 ; ?????????? ??? ??????
rcall lcd_command
ldi r24 ,low(1530)
ldi r25 ,high(1530)
rcall wait_usec
 ldi r24 ,0x06 ; ???????????? ????????? ??????? ???? 1 ??? ??????????
rcall lcd_command ; ??? ????? ???????????? ???? ??????? ??????????? ???
 ; ?????????????? ??? ????????? ????????? ??? ??????
ret
 stall7:
    ret
wait_msec:
    push r24 ;
    push r25 ;
    push r26
    push r27 ; 8 + 3 = ]
    loopmsec:
        sbiw r24,0x01 ; 2
	movw r26,r24 ;  3 
	ldi r24,low(997) ;
	ldi r25,high(997) ;5
	rcall wait_usec ; 
	movw r24,r26 ;6
	cp r24,r25 ; 7
	breq contition2 ;8
        ;8
	rcall stall7
	rcall stall7
	rcall stall7
	rcall stall7
	rcall stall7
	nop
	nop
	jmp loopmsec ; 1000usec
	contition2:
        ;9
	cpi r24,0
	breq endloopmsec
	;11 failed
	;stall 21
	rcall stall7
        rcall stall7
	rcall stall7
	rcall stall7
	nop
	nop
	nop
	nop
	nop
	nop
	jmp loopmsec	
    endloopmsec:
    ;12 
    rcall stall7 ;7 i need 6 more
    jmp eatpls3     
    eatpls3:
    jmp eatpls32
    eatpls32:
    pop r27
    pop r26
    pop r25 ;
    pop r24 ;
    ret ; 23usec
wait_usec:
    ;clock 16MHZ
    ;16cycles = 1ms  ;
    push r24;
    push r25 ; 4 + 3 calesma =  7
    loopu:
    sbiw r24,0x01 ; 2 
    cpi r24,0x01 ;  1 
    breq maystop ; 
    ;4 cycles  anonther 12
    jmp nonstop1 ; 3
    nonstop1:
    jmp nonstop2 ;3
    nonstop2:
    jmp nonstop3 ;3
    nonstop3:
    jmp loopu ; 3 +9 + 4 =16
    maystop:
    ;5 another 11
    cpi r25,0x0 ;1
    breq endloop ; 1
    ;failed 7
    ;16 -7  = 9
    jmp nonstop4 
    nonstop4:
    jmp nonstop5
    nonstop5:
    jmp loopu
    endloop:
    ;8 + 8
    jmp nonstop6
    nonstop6:
    jmp nonstop7
    nonstop7:
    nop
    nop
    nop
    pop r25 ; 4+4 =8 +7(begin) = 15 +nop =16 1us
    pop r24 ;
    ret ;
    build_decimals2:
    ;r21 has it
    push r21
    clr r16 
    loopbuildd1:
        cpi r21,10
	brlo exitbuildloop
	subi r21,10
	inc r16
	jmp loopbuildd1
    exitbuildloop:
	
	mov r17,r21
	pop r21
    ret
 portbcounter:
    push r16 
    ldi r16,1
    add counter,r16 
    cpi counter,64
    brne not_ini
    clr counter
    not_ini:
    out PORTB,counter 
    pop r16
    ret
    
 
    