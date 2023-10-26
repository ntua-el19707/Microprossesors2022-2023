.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
 .equ DEL_mS =4000
 .equ delay =  FOSC_MHZ*DEL_mS
 .equ refresh = 500*FOSC_MHZ
 .equ delaysmall = 5*FOSC_MHZ 
.org 0x0
rjmp reset

.org 0x4
rjmp ISR1
reset:
    ;stack
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ;PORT and pins
    ser r24
    out DDRB,r24 ;portb is outoput
    ;set interupt on rising edge 
    ldi r24,(1 << ISC11) |(1 << ISC10) 
    sts EICRA,r24
    
    ;enable pd3 int 0
    ldi r24,(1 << INT1)
    out EIMSK,r24
    sei ;Set the Hlobal iterutp Flag
      ldi r26,0x01
    clr r24
    clr r25
    start:
    cp r24,r25
    brne not_restart
    cpi r24,0x00
    breq clear_restart
    not_restart:
    out PORTB,r26
    call wait_x_sec
    clr r27
    clr r24
    clr r25
    clear_restart:
    out PORTB,r24
    rjmp start

ISR1:
    ;r27 0xFF refersh 
    
  
    push r26
    in r26,SREG
    push r24
    begin:
	ldi r24, (1 << INTF1)
	out EIFR,r24
	ldi r24,low(delaysmall) ;
        ldi r25,high(delaysmall) ; us 
        rcall wait_x_sec ;3cycles 5ms
	in r24,EIFR
	cpi r24,0x00
	brne begin
    ;body
   cpi r27,0xFF
   brne not_refr 
    out PORTB,r27
   rcall refresh_custom
   not_refr:
   ldi r24,low(delay)
   ldi r25,high(delay)
   ser r27
  
    ; 
    pop r26
    out SREG,r26
    pop r26
    reti
;notmal
light:
        push r24
	ser r27 ;in case of an interupt
	ldi r24,0x01
	out PORTB,r24
    	ldi r24,low(delay)
	ldi r25,high(delay)
	rcall wait_x_sec
	clr r24
	out PORTB,r24
	POP r24
	ret
refresh_custom:
  push r26

 
  ldi r24,low(refresh)
  ldi r25,high(refresh)
  rcall wait_x_sec

  ldi r24,low(delay)
  ldi r25,high(delay)
  ldi r26,0x01
  out PORTB,r26
  clr r27
  pop r26
  ret
;wait_x_sec
wait_x_sec:
   PUSH r24
   PUSH r25 ; 3+4 = 7  + ypoxreaotika 4 + 4 = 8 (15 mandatory)
   loop_x:
   sbiw r24,0x01 ;2 cycles 
   rcall wait  ;980 cycles
   cp r24,r25 ;1 cycle
   brne continue ;   1 cycle 2kikli
   ;4cycles 
   cpi r24,0x00 ;1 brne 1/2 1 no jump  2  jump ;5 Cycles
   breq cor  
   ;6 cycles
   ;wrong cosuming 2+1+2+1+2 =6 +3 =9 
   call wait4u ;
   jmp eat3
   eat3:
    nop
    nop
   jmp loop_x ;4cycles control 4 delay +3 gor origina;
  continue: ;+6cycles = 8  
    call wait4u; 5+7 =12 (jmp loo 3 15)
    jmp consume ;3
    consume:
    jmp consume2
    consume2:
     ;1
    jmp loop_x ;3cycles (20) 20+980 =10000
cor: 
    ;7 consume  + 7 begin + 8 mandatory =22 cycles produce cycles must <978
    POP r25
    POP r24
    ret
wait4u: 
    ret ;4us
 ;dalay 978 cycles
wait:
    PUSH r26 ;cycles  
    ldi r26,80; 2 
loop:
    rcall wait4u ;7
    dec r26 ;1
    nop ;1
    nop ; 1
    brne loop ; 2
    ; 79*12 =948 +11(80 time) =958 cycles(loop)
    ;959 +13(mandatory) =972 cycles
    POP r26 ; 2cycles
    ;i want 978 cycles 978-972 6cyles
    ; PUSH & POP  & ldi  &ret +&cal  13cycles
    jmp cwait1 ;3cycles
    cwait1:
    jmp cwait2 ; 3cycles  (6)
    cwait2:
    nop
    ret    
ret ;4cycles  
    
 


