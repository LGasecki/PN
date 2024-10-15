.equ Digits_P = PORTB
.equ Segments_P = PORTD

.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

Reset:
    ldi r16, 0xFF       ;Declare pins as output
    out DDRD, r16
    
    ldi r16, 0x3F       ;Light 0
    out Segments_P, r16

    ldi r16, 0x1E       ;Declare pin 1 portB, as output   
    out DDRB, r16         

MainLoop:
    ldi r17, $2     
    out Digits_P, r17   
    rcall DelayInMs
    ldi r17, $4     
    out Digits_P, r17   
    rcall DelayInMs
    ldi r17, $8     
    out Digits_P, r17   
    rcall DelayInMs
    ldi r17, $10     
    out Digits_P, r17   
    rcall DelayInMs

    rjmp MainLoop


DelayInMs: 
    LOAD_CONST R30, R31, $3E8 ;1s
    InsideDelayInMs:
    rcall DelayOneMs
    sbiw r30, 1
    brne InsideDelayInMs
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