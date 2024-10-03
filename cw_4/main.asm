ldi R20, 100
ldi R21, 200
mov R1, R20
mov R0, R21
add R0, R1
add R0, R2
loop: nop
rjmp loop