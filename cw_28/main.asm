.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

Reset:
    ldi r16, 0x1E
    out DDRB, r16
    
MainLoop:
    ldi r16, 0x1E
    out PORTB, r16

    ldi r16, 0x00
    out PORTB, r16

    rjmp MainLoop

        
