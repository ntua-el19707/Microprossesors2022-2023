.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
.equ NUM = 6 ;50%

reset:
    ;initialization 
    ;stack
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ;PORT and pins
    ldi r24,0xFF ;pb0 && pb1 input  else output
    out DDRB,r24
    CLR r24
     ;ldi r24,0xFF ;
    out DDRD,r24
    ldi r24,(1<<WGM10)|(1<<COM1A1) ;fpw 8 -bit
    sts TCCR1A, r24
    ldi r24,(1<<wgm12)|(1<<cs11);
    sts TCCR1B,r24
    sei 
    ldi r20,NUM ;set initialize r20
    rcall dutyclcset ;set dutycycle
    start:
    rcall checkpress_PD1
    rcall checkpress_PD2
    jmp start 
    
    

    
dutyclcset:
    push r28 
    push r30
    push r31
    push r0 ;stacks
    
    ldi zh, high(Table*2)
    ldi zl,low(Table*2)
    mov r21,r20 ; r20 thepossition inside the table that we are
    lsl r21 ; double it
    clr r18  ;clr r18
    add zl,r21
    adc zh,r18 ; navicated to that place  
    lpm ;r0 has now the dutycycle
    mov r22,r0 ; r22 = r0 (r21:possition(doubled), r22:context of index )
    sts OCR1AL,r22 ; set duty cycle 
    pop r0 ;stacks 
    pop r31
    pop r30
    pop r18
    ret 
checkpress_PD2:
    push r24
    in r24,PIND ;check PD1 pressed
    andi r24,0x04
    cpi r24,0x00;
    breq press_pd2
    pop r24 
    ret 
press_pd2:
    in r24,PIND
    andi r24,0x04
    cpi r24,0x00;
    breq press_pd2 ; keep here until button unpussed
   
   cpi r20,0 
   breq quitop2 ;if possition 0  then do not --possition
   subi r20,0x01 ; go to previous dutycycle -8%
  
   quitop2:
     rcall dutyclcset ;set duty cycle 
    pop r24
    ret
checkpress_PD1:
    push r24
    in r24,PIND
    andi r24,0x02
    cpi r24,0x00;
    breq press_pd1
    pop r24 
    ret 
press_pd1:
    in r24,PIND
    andi r24,0x02
    cpi r24,0x02;
    brne press_pd1 ; wait until pd1 is unpussed
    ;rcall Timer
   cpi r20,12 ;if we are a top 98% do not increase
   breq quitop1
   ldi r24,0x01 ;+8%
   add r20,r24 
       rcall dutyclcset ; set duty cycle
   quitop1:

    pop r24
    ret
    
 Table:
.dw 0x05,0x1A,0x2E,0x42,0x57,0x6B,0x80,0x94,0xA8,0xBD,0xD1,0xE6,0xFA 
  ;duty cycles  = 5(2%),26,46,66,87,107,128(50%),148,168,189,209,230,250(98%)




