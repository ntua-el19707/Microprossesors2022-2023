.include "m328PBdef.inc"

.equ A=0x55
.equ B=0x43
.equ C=0x22
.equ D=0x02
.equ Times = 0x06
reset:
    ldi r24,low(RAMEND)
    out SPL,r4 
    ldi r24,high(RAMEND)
    out SPH,r24
    
    ldi r24,A ;load A,b,c,d
    ldi r26,B 
    ldi r28,c
    ldi r30,D 
    ldi r23,Times ;load times for looping
start: 
    MOV r25,r24
    MOV r27,r26
    MOV r31,r30 ;Mov A,B,D to that pair for making them Complements 
    ;(i do not require a coplement for c that is why ido not move it)
    COM r25
    COM r27
    COM r31 ; create A' ,B',C'
    rcall F0
    rcall F1
    rcall Change
    DEC r23
    CPI r23,0
    BRNE start
    jmp END
    
F0:
    ;r20 output
    PUSH r25
    PUSH r27 ;use  of stack 
    AND r25,r27 ; A'B' in r25
    AND r27,r30 ; B'D in r27
    OR  r25,r27 ;A'B' + B'D in r25
    COM r25 ;r25' in r25
    MOV r20,r25 ; now  in r20 =(A'B' + B'D)'
    POP r27
    POP r25
    ret
F1:
    PUSH r24
    PUSH r26
    OR r24,r28
    OR r26,r31
    AND r24,r26
    MOV r21,r24
    POP r26
    POP r24
    RET
Change:
    ;change a,b,c,d 
    ldi r25,0x02
    ADD r24,r25
    ldi r27,0x03
    ADD r26,r27
    ldi r29,0x04
    ADD r28,r29
    ldi r31,0x05
    ADD r30,r31
    RET
END:
    
    
    
    
    
    
  
    


