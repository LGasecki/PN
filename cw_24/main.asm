MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    ldi R24, 3
    rcall DelayOneMs
    ret

DelayOneMs:
    ldi r25, $07
    ldi r24, $CC
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        dec R24
        brne DelayOneMs
        ret