ldi R20, 10
loop: dec R20   
nop
nop             
brbc 1, loop    
nop        //Cycles=(R20*5)
nop
nop
nop
nop
nop
rjmp 0