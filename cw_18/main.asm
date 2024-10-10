ldi R23, 1
    Loop:
    ldi r24, low($F831)  ; M³odszy bajt licznika ustawiony na wartoœæ 8000
    ldi r25, high($F831) ; Starszy bajt licznika ustawiony na wartoœæ 8000
    nop
        Loop2:
        adiw r24, 1
        brcc Loop2
        dec R23
        brne Loop
        nop
rjmp loop