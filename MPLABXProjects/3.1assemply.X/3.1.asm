.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
.equ DEL_mS =4000
.equ delay =  FOSC_MHZ*DEL_mS
.equ refresh = 500*FOSC_MHZ
.equ delaysmall = 5*FOSC_MHZ 
.equ timerset = 3036
.org 0x0
rjmp reset

.org 0x4
rjmp ISR1
 
.org 0x1A
rjmp ISR_TIMER1_OVF ; xronistis turn off the lights
 
reset:
    ;initilizations 
    ;stack
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ;PORT and pins
    ser r24
    out DDRB,r24 ;portb is outoput
    clr r24
    out DDRC,r24 ;portc is input
    ;set interupt on rising edge 
    ldi r24,(1 << ISC11) |(1 << ISC10) 
    sts EICRA,r24
    
    ;enable pd3 int 0
    ldi r24,(1 << INT1)
    out EIMSK,r24
    ;sei ;Set the Hlobal iterutp Flag
    ;initilize timer
    ldi r24,(1<<TOIE1)
    sts TIMSK1,r24
    ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10) ;CK /1024  evry 1024 cycles => ++TCINT 
    sts TCCR1B, r24
    sei
    start:
    rcall checkpress ; check and execute pc5 press 
    rjmp start ; infinite loop program never stops
;interupt 1
ISR1:
    ;r27 0xFF refersh 
    push r26
    in r26,SREG
    push r24
    push r25
    ;apfigi fainomainoy spinthirismou
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
    cpi r27,0xff ;use  like boolean if light on => refresh 
    brne exitISR1
    ;refresh 
    ;to do 
    out PORTB,r27
    ldi r24,low(refresh) ;
    ldi r25,high(refresh) ; us 
    rcall wait_x_sec ;3cycles 5ms
    exitISR1:
    rcall Timer ;time for  turn 0f the lights
    ser r27
    ldi r26 ,0x01
    out PORTB,r26 ; lights on 
    ; 
    pop  r25
    pop r24
    out SREG,r26
    pop r26
    reti
ISR_TIMER1_OVF:
    ;turn of the light 
    ;pd3 or pc5 set timer in 4 sec and then light off
    push r26 
    clr r26
    out PORTB,r26
    clr r27
    pop r26
    reti
    ;delay 

 ;Timer 1
 Timer:
    ;set timer for 4 seconds 
    push r24
    ;16bits => 2^16 65536 cycles after iperxilisi
    ;1024 => ++TINT1
    ;16Mhz =>16M /1024 15625
    ; se 1 sec +> 1 * 15625
    ;syo TCNT1 => 65536 -156254*4 => 4sec (3036)
    ;49111 = C2f7hex
    ldi r24,high(timerset)
    sts TCNT1H,r24
    ldi r24,low(timerset)
    sts TCNT1L,r24
    pop r24   
    ret
checkpress:
    push r24
    in r24,PINC
    andi r24,0x20 ; pc5 
    cpi r24,0x00; reverse logic
    breq press ; press set timer and turn light  on 
    pop r24 
    ret 
    press:
    rcall Timer
    ser r27 
    ldi r24,0x01
    out PORTB,r24 ;set light on 
    pop r24
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
    
 





