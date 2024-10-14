MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    ldi R24, 1
    rcall DelayOneMs
    ret
DelayOneMs:
    sts 0x61, r25
    sts 0x60, r24
    ldi r25, $07
    ldi r24, $C9
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        lds r24, 0x60
        lds r25, 0x61
        dec R24
        brne DelayOneMs
        ret