ldi R21, 250
    Loop1:
    ldi R20, 12
        Loop:
        dec R20
        brne Loop
    dec R21
    nop
    brne  Loop1
rjmp 0                                                                                