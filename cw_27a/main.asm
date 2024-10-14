MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    ldi R24, 10
    rcall DelayOneMs
    ret
DelayOneMs:
    push r24
    push r25
    ldi r25, $07
    ldi r24, $CC
    InsideDelayOneMs:
        sbiw r24, 1
        brcc InsideDelayOneMs
        pop r25
        pop r24
        dec R24
        brne DelayOneMs
        ret