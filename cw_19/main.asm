ldi R23, 1
    Loop:
    ldi r25, $07
    ldi r24, $CE
    nop
        Loop2:
        sbiw r24, 1
        brcc Loop2
        dec R23
        brne Loop
        nop
rjmp loop