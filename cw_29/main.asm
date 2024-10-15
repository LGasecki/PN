.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

Reset:
    ldi r16, 0xFF       ;Declare pins as output
    out DDRD, r16
    
    ldi r16, 0x02       ;Declare pin 1 portB, as output   
    out DDRB, r16         

    ldi r17, 0x02       ;Declare pin 1, as 1 to light up
    out PORTB, r17       
MainLoop:
    ldi r16, 0x3F       ;Light 0
    out PORTD, r16
    rcall DelayInMs
    nop
    ldi r16, 0x06       ;Light 1
    out PORTD, r16
    rcall DelayInMs

    rjmp MainLoop


DelayInMs: 
    LOAD_CONST R30, R31, $FA
    rcall DelayOneMs
    ret
DelayOneMs:
    push r30
    push r31
    LOAD_CONST R30, R31, $07CB
    InsideDelayOneMs:
        sbiw r30, 1
        brcc InsideDelayOneMs
        pop r31
        pop r30
        dec R30
        brne DelayOneMs
        ret