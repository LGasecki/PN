MainLoop:  
ldi R23, 2
rcall DelayInMs 

rjmp  MainLoop 

DelayInMs: 
    nop
    rcall DelayOneMs
    ret

DelayOneMs:
    ldi r25, $07
    ldi r24, $CD
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        dec R23
        brne DelayOneMs
        ret