.include "m328PBdef.inc"
;contains all mneomigs for the  name registers Rammend 
    
reset:
     ldi r24, low(RAMEND) ; initilaise stack pointer 
    out SPL ,r24 
    ldi r24,high(RAMEND)
    out SPH,r24


start:
    ldi r24,0x01 ;low byte
    ldi r25,0x00 ;high Byte 
;wait_m_sec => wait r25r24 secs (for  f =1MHz)
    rcall wait1m ;
 jmp start
wait_x_msec:
    
  loop: 
	;7 cycles built in in evry loop
	sbiw r24,1 ; Substruct from r25:24 ;1 (2 cylces);
	;create a call fir 992us
	CP r24,r25 ; if(r24 == r25 == 0) => break else loop +1
	brne continue;  +1
        cpi r24,0x00 ; +1
	brne loop ; cycle +1
	nop ; +1
	ret
continue:
       jmp loop ; 3cycles
       

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

    
    
