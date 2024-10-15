.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    LOAD_CONST R24, R25, $FA
    rcall DelayOneMs
    ret
DelayOneMs:
    push r24
    push r25
    LOAD_CONST R24, R25, $07CB
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        pop r25
        pop r24
        dec R24
        brne DelayOneMs
        ret