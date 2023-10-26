.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
 .equ DEL_mS =5
 .equ delay =  FOSC_MHZ*DEL_mS
 .equ delay1 = 500*FOSC_MHZ
 .equ delay2 = 1000 *FOSC_MHZ

.org 0x0
rjmp reset

.org 0x4
rjmp ISR1


reset:

ldi r24,low(RAMEND)
out SPL,r4 
ldi r24,high(RAMEND)
out SPH,r24
    clr r24
out DDRD,r24 ;initialize DDRD for using PORTD as an  input r24 00hex
ser r24
out DDRC,r24 ;portc is outoput
    ;set interupt on rising edge 
  

    
    ;set interupt on rising edge 
  
    ldi r24,(1 << ISC11) |(1 << ISC10) 
    sts EICRA,r24
    
    ;enable pd3 int 0
    ldi r24,(1 << INT1)
    out EIMSK,r24
    sei ;Set the Hlobal iterutp Flag
    ldi r26,0X00 ;COUNT INTERAPTS
       out PORTC,r26 
       clr r27  
 start:
    out PORTB,r27 
    inc r27
    ldi r24,low(delay1)
    ldi r25,high(delay1)
    rcall wait_x_sec ;3cycles 5ms
    cpi r27,16
    brne next 
    clr r27
    next:
    rcall pause
    jmp start;

    
ISR1:
    push r25
    push r24
    in r24,SREG
    push r24
    
    begin:
	ldi r24, (1 << INTF1)
	out EIFR,r24
	ldi r24,low(delay) ;
        ldi r25,high(delay) ; us 
        rcall wait_x_sec ;3cycles 5ms
	in r24,EIFR
	cpi r24,0x00
	brne begin
     inc r26
     
    cpi r26,0x20 ;r26 == 32
    brne notini ; 
    ldi r26,0x00
    
   
notini:
 out PORTC,r26
     ldi r24,low(delay1)
    ldi r25,high(delay1)
    rcall wait_x_sec ;3cycles 5ms
    pop r24
    out SREG,r24
    pop r24
    pop r25
    reti
pause:
    push r26
    looppause:
    in r26,PIND
    com r26
    
    andi r26,0x1
    cpi r26,0x1
    breq looppause
    pop r26
    ret
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