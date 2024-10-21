.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

.equ Digits_P = PORTB
.equ Segments_P = PORTD

ldi R18, $3F
mov R2, R18
ldi R18, $06 
mov R3, R18
ldi R18, $5B
mov R4, R18
ldi R18, $4F
mov R5, R18
Reset:
    ldi r16, 0xFF       ;Declare pins as output
    out DDRD, r16

    ldi r16, 0x1E       ;Declare pin 1-4 portB, as output   
    out DDRB, r16         

MainLoop:    
    out Segments_P, r2 ;Light 0 on 1pin
    ldi r17, $2     
    out Digits_P, r17   
    rcall DelayInMs
     
    out Segments_P, r3 ;Light 1 on 2pin
    ldi r17, $4        
    out Digits_P, r17   
    rcall DelayInMs
    
    out Segments_P, r4 ;Light 2 on 3pin
    ldi r17, $8         
    out Digits_P, r17   
    rcall DelayInMs
     
    out Segments_P, r5 ;Light 3 on 4pin
    ldi r17, $10        
    out Digits_P, r17   
    rcall DelayInMs

    rjmp MainLoop


DelayInMs:
    push R30
    push R31 
    LOAD_CONST R30, R31, $5 ;5ms  200Hz Segment (50Hz ca³y)
    InsideDelayInMs:
    rcall DelayOneMs
    sbiw r30, 1
    brne InsideDelayInMs
    pop R31
    pop R30
    ret
DelayOneMs:
    push r30
    push r31
    LOAD_CONST R30, R31, $07CB ;1995us
    InsideDelayOneMs:
        sbiw r30, 1
        brcc InsideDelayOneMs
        pop r31
        pop r30
        ret