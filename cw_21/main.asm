MainLoop:  
rcall DelayNCycles ;  
rjmp  MainLoop 
DelayNCycles: 
    nop
    rcall AnotherDelay
    nop 
    nop 
    ret     
        AnotherDelay:
        nop
        nop
        ret
;powr�t do miejsca wywo�ania 