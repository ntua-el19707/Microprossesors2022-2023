.include "m328PBdef.inc"
.equ FOSC_MHZ = 16
.equ NUM = 0 
  reset:   
    ;stack
    ;initilozation
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    ;PORT and pins
    ldi r24,0xF0 ;pd0 -pd3 input  else output
    out DDRD,r24
    ldi r24,(0<<WGM10)|(1<<WGM11)|(1<<COM1A1) ;fpw 8 -bit prescale 1024
    sts TCCR1A, r24
    ldi r24,(1<<wgm12)|(1<<wgm13)|(0<<cs11)|(1<<cs12)|(1<<cs10);
    sts TCCR1B,r24
    sei
    SER r24
    out DDRB,r24;
    ;set fpw
    ldi r21,NUM
    rcall setregistersr22r23
    rcall settopbotoms
    start:
       ;check buttons and act 
        rcall checkpress_PD0
	rcall checkpress_PD1
	rcall checkpress_PD2
	rcall checkpress_PD3        
	rcall checkNone
	;repeat for ever
	jmp start
    

setregistersr22r23:
    ;r22:ICR1:top,r23:OCR1:bottom
    push r20
    push r30
    push r31
    push r18
    push r0 ; push to stack 
    
    ldi zh, high(TabletopsBottoms*2)
    ldi zl,low(TabletopsBottoms*2)
    mov r20,r21 ; store index 
    lsl r21 ;2*index to get to the context of the index
    clr r18
    add zl,r21
    adc zh,r18 ; navigate through table
    lpm
    mov r22,r0 ; put context(top) to r22  
    ldi zh, high(TabletopsBottoms*2)
    ldi zl,low(TabletopsBottoms*2)
    ldi r21,0x5 ;
    add r21,r20 ; 
    lsl r21 ; r21 has now the index of bottom
    
    add zl,r21 
    adc zh,r18 ; navigate
    lpm  ; 
    mov r23,r0 ;put context(boottom) to r23
    pop r0
    pop r18
    pop r31
    pop r30
    pop r20
    ret
settopbotoms:
    ;move r22 ,r33 ro ocr1a icr1 for the fpw
    push r18
    clr r18
    sts OCR1AH,r18 
    sts OCR1AL,r23 
   
    sts ICR1H,r18
    sts ICR1L,r22
    pop r18
    ret 
    
checkpress_PD0:
    ;check press id pd0 if press => fpw 125 hz 
    push r24
    push r21
    in r24,PIND
    com r24 
    andi r24,0x01
    cpi r24,0x01;
    breq press_pd0
    pop r21
    pop r24 
    ret 
press_pd0: 
   ;set buttom and top
   ldi r21,0x01
   rcall setregistersr22r23
   rcall settopbotoms
    ;rcall Timer
 loop_pd0:
   in r24,PIND
   com r24
   andi r24,0x01
   cpi r24,0x01;
   breq loop_pd0 ;stay here unrill pd0 unpressed
  
    pop r21
    pop r24
    ret    
checkpress_PD1:
    ;same logig with pd0
    push r24
    push r21
    in r24,PIND
    com r24
    andi r24,0x02
    cpi r24,0x02;
    breq press_pd1
    pop r21
    pop r24 
    ret 
press_pd1: 
   ldi r21,0x02
   rcall setregistersr22r23
   rcall settopbotoms
   loop_pd1:
    ;rcall Timer
   in r24,PIND
   com r24
   andi r24,0x02
   cpi r24,0x02;
   breq loop_pd1
  
    pop r21
    pop r24
    ret
checkpress_PD2:
    push r24
    push r21
    in r24,PIND
    com r24
    andi r24,0x04
    cpi r24,0x04;
    breq press_pd2
    pop r21
    pop r24 
    ret 
press_pd2: 
   ldi r21,0x03
   rcall setregistersr22r23
   rcall settopbotoms
    ;rcall Timer
    loop_pd2:
    in r24,PIND
   com r24
   andi r24,0x04
   cpi r24,0x04;
   breq loop_pd2
  
    pop r21
    pop r24
    ret    
   checkpress_PD3:
    push r24
    push r21
    in r24,PIND
    com r24
    andi r24,0x08
    cpi r24,0x08;
    breq press_pd3
    pop r21
    pop r24 
    ret 
press_pd3: 
   ldi r21,0x04
   rcall setregistersr22r23
   rcall settopbotoms
    ;rcall Timer
  loop_pd3:
   in r24,PIND
   com r24
   andi r24,0x08
   cpi r24,0x08;
   breq loop_pd3
  
    pop r21
    pop r24
    ret    
checkNone:
    ;if none press => fpw freq = 0  load zeros
    push r21 
    push r24
    in r24,PIND
    com r24
    andi r24,0x0f
    cpi r24,0x00 
    brne not_zero
    ldi r21,0
    rcall setregistersr22r23
    rcall settopbotoms
    not_zero:
    pop r21
    pop r24
    ret
   
    
    
    
    
TabletopsBottoms:
    .dw 0,0x7c,0x3D,0x1E,0x0f ;124,61,30,15
    .dw 0,0x3E,0x1F,0x0f,0x08 ;62,31,15,8
;for duty cycle =50%
;bottom = Top/2
;Tops f =125Hz prescale 1024 fclc 16Mhz => 1+TOP = (16Mhz)/(1024 * 125) => top =124
;f = 250 => top 61 bottom 31
; f = 500 top 30 , bottom 15
;f =1000 top 15 bottom 8
    