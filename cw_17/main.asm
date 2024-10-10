ldi R22, 1    
ldi R21, 200        //40CC is 5us
    Loop1:
    ldi R20, 12       //750cc 
        Loop:
        dec R20
        brne Loop
    dec R21
    nop
    brne  Loop
    dec R22
rjmp 0                    