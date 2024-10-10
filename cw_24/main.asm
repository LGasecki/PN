MainLoop:  
ldi R23, 2
rcall DelayInMs 
rcall DelayOneMs
rjmp  MainLoop 

DelayInMs: 
    ldi r25, $07
    ldi r24, $CD
    nop
    InsideDelay:
        sbiw r24, 1
        brcc InsideDelay
        dec R23
        brne DelayInMs
        nop
        ret

DelayOneMs:
    ldi r25, $07
    ldi r24, $CD
    nop
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        ret