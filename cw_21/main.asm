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
;powrót do miejsca wywo³ania 