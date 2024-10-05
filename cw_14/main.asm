ldi R21, 5
    Loop1:
    ldi R20, 100
        Loop:
        dec R20
        nop
        brne Loop
    dec R21
    brne  Loop1
rjmp 0