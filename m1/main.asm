.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    LOAD_CONST R24, R25, $1
    rcall DelayOneMs
    ret
DelayOneMs:
    sts 0x61, r25
    sts 0x60, r24
    LOAD_CONST R24, R25, $07C9
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        lds r24, 0x60
        lds r25, 0x61
        dec R24
        brne DelayOneMs
        ret