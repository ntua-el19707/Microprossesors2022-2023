.include "m328PBdef.inc"
.equ delay = 0x000A
reset:
    ldi r24,low(RAMEND)
     out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ldi r24,0x03 ;
    ldi r25,0x00 ; 8us 
main:
    ;rcall wait1m 
  ; rjmp main
;wait4:
 ;   ret ;4cycles 4 usec
;wait1m:
 ;   ldi r26,99
;loop:
 ;   rcall wait4
  ;  dec r26
   ; brne loop
    ;nop
    
    
 ;ret
ldi r27,0x00
ldi r24,low(delay) ;
ldi r25,high(delay) ; us 
rcall wait_x_sec ;3cycles
jmp main
 
 wait_x_sec:
    
   mov r28,r24 ;
   mov r29,r25 ; 3+2+4+1 =10 usec 
   nop ;
   loop_x:
   sbiw YL,0x01 ;2 cycles + 2+ 4  8
   rcall wait  ;980 cycles
   
   cp r28,r29 ;1 cycle
   brne continue ;   1 cycle 2kikli
   cp r28,r27 ;1 brne 1/2 1 no jump  2  jump 
   breq cor  ;5
   ;wrong cosuming 2+1+2+1+2 =6 +3 =9
   call wait4u ;
   
   nop
   jmp eat3
   eat3:
   jmp loop_x ;4cycles control 4 delay +3 gor origina;
  continue: ;+6cycles = 8 
    
    call wait4u; 5+7 =12 (jmp loo 3 15)
    jmp consume ;3
    consume:
    nop ;1
     ;1
    jmp loop_x ;3cycles (20) 20+980 =10000
cor: 
    ;7 consume  + 10 begin  +2
    nop
    nop
    nop
    ret
wait4u:
    
    ret ;4us
wait:
    ldi r26,88; 2
loop:
    rcall wait4u ;7
    dec r26 ;1
    nop ;1
    brne loop ; 2
    jmp return ;
    
    return:
    nop
    nop
    ret
    
    
    
    
  
  
  
  
  
  
    
ret ;4cycles
    
    
End:
    
 

