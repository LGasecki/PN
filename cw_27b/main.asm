MainLoop: 
rcall DelayInMs 
rjmp  MainLoop 

DelayInMs: 
    ldi r16, 120
    ldi r17, 0
    movw r25:r24, r17:r16
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