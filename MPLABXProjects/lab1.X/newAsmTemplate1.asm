


.include "m328PBdef.inc"
;contains all mneomigs for the  name registers Rammend 
    
reset:
     ldi r24, low(RAMEND) ; initilaise stack pointer 
    out SPL ,r24 
    ldi r24,high(RAMEND)
    out SPH,r24


start:

;wait_m_sec => wait r25r24 secs (for  f =1MHz)
    rcall wait1m ;
 jmp start
 
wait4:
    ret ; 4cylces 4 usec 
wait1m:
    ldi r26,99 ;1 cycle(1 usec)
loop2:
    rcall wait4 ;
    dec r26 ;
    brne loop2 
    
    nop 
    nop 
    nop 
    ret 

    
    