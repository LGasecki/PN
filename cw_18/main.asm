 ldi R22, 1 
Delay_1ms:
    ldi R24, $F4
    ldi R25, $FA    

IncrementLoop:
    adiw R24:R25, 1
    brcc IncrementLoop
    dec R22
    brne Delay_1ms
    nop
    nop
    rjmp Delay_1ms

 /*   ldi R23, 1
    Loop:
    ldi r24, low($F831)  ; M�odszy bajt licznika ustawiony na warto�� 8000
    ldi r25, high($F831) ; Starszy bajt licznika ustawiony na warto�� 8000
    nop
        Loop2:
        adiw r24, 1
        brcc Loop2
        dec R23
        brne Loop
        nop
rjmp loop*/