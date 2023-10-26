.include "m328PBdef.inc"
.equ stop = 0x03E8 ;1000
.equ delay = 0x1F4 ; 500
.equ start =0x80 ;
reset:
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ser r24
    out DDRD,r24 ;initialize DDRD for using PORTD as an  output r24 FFhex
    ldi r20,start ;r20 holod possition  to output to PORTD
    bset 6 ;set T -flag 1 => right shifting
main:
   ;
    ldi r24,low(delay)
    ldi r25,high(delay)
    rcall wait_x_sec
    ;delay :05 sec
    brts right ;
    rcall shft_L
    jmp main
  right:
    rcall shft_R
    jmp main
    
    
    
shft_L:
    lsl r20
    cpi r20,0x80
     out PORTD,r20 
    breq to_right
    ret
 to_right:
    bset 6 ;set Flag T
    ;1sec delay
    ldi r24,low(stop)
    ldi r25,high(stop)
    rcall wait_x_sec
    ret
shft_R:
    lsr r20
    cpi r20,0x01
     out PORTD,r20 
    breq to_left
    ret
 to_left:
    bclr 6 ; T=0 clear T flag
     ldi r24,low(stop)
    ldi r25,high(stop)
    rcall wait_x_sec
    ;1sec delay 
    ret

    
;wait

 
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