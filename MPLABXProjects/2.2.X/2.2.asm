.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
.equ DEL_mS = 600
.equ second = 1000*FOSC_MHZ
.equ delay =  FOSC_MHZ*DEL_mS
.equ delaysmall = 5*FOSC_MHZ 
.org 0x0
 rjmp reset
.org 0x2
 rjmp ISR0
reset:

ldi r24,low(RAMEND)
out SPL,r4 
ldi r24,high(RAMEND)
out SPH,r24
clr r24

    out DDRB,r24 ;initialize DDRD for using PORTD as an  input r24 00hex

ser r24
out DDRC,r24 ;portc is outoput
    ;set interupt on rising edge 
;interupt setup 
ldi r24,(1 << ISC00) |(1 << ISC01) 
sts EICRA,r24
    
;enable pd2 int 0
ldi r24,(1 << INT0)
out EIMSK,r24
sei
start:
    recount:
        clr r26
    count:
	out PORTC,r26
	ldi r24,low(delay)
	ldi r25,high(delay)
	rcall wait_x_sec
	inc r26
	cpi r26,0x20
	breq recount 
	rjmp count
	
;wait_X_seconds
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

;ISR 0
ISR0:
    push r25
    push r24
    in r24,SREG
    push r24
    begin:
	ldi r24, (1 << INTF0)
	out EIFR,r24
	ldi r24,low(delaysmall) ;
        ldi r25,high(delaysmall) ; us 
        rcall wait_x_sec ;3cycles 5ms
	in r24,EIFR
	cpi r24,0x00
	brne begin
    ;body
    clr r24
    in r25,PINB
    COM r25
    rcall count5
    out PORTC,r24
    ldi r24,low(second)
    ldi r25,high(second)
    rcall wait_x_sec
    
    ; 
    pop r24
    out SREG,r24
    pop r24
    pop r25
    reti
build:
    push r25
    andi r25,0x01
    cpi r25, 0x01
    brne not_one
    LSL r24
    adiw r24,0x01
    not_one:
    pop r25
    ret 
count5:
    push r26
    ldi r26,0x06
   bits5:
    rcall build
    LSR r25
    dec r26
    cpi r26,0x0
    brne  bits5
    pop r26
    ret 
    