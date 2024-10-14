MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    ldi R24, 1
    rcall DelayOneMs
    ret
DelayOneMs:
    sts 0x60, r24
    ldi r25, $07
    ldi r24, $CA
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        lds r24, 0x60
        dec R24
        brne DelayOneMs
        ret