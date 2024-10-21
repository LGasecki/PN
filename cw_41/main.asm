.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

.macro SET_DIGIT
    push R16
    ldi r16, @0
    rcall DigitToPin
    out Digits_P, r16   ;Init Seg_0
    mov R16, Dig_@0  
    rcall DigitTo7segCode  
    out Segments_P, R16 ;Light Dig_0
    rcall DelayInMs

    pop R16
.endmacro

.equ Digits_P = PORTB
.equ Segments_P = PORTD

.def Dig_0=R2
.def Dig_1=R3
.def Dig_2=R4
.def Dig_3=R5

ldi R18, $0
mov Dig_0, R18
ldi R18, $0
mov Dig_1, R18
ldi R18, $0
mov Dig_2, R18
ldi R18, $0
mov Dig_3, R18

ldi r16, 0xFF       ;Declare pins as output
out DDRD, r16
ldi r16, 0x1E       ;Declare pin 1-4 portB, as output   
out DDRB, r16         

MainLoop: 
SET_DIGIT 0 
inc Dig_0
ldi R19, $A
cp R19, Dig_0
brne MainLoop
clr Dig_0
SET_DIGIT 1 
inc Dig_1
ldi R19, $A
cp R19, Dig_1
brne MainLoop
clr Dig_1
SET_DIGIT 2 
inc Dig_2
ldi R19, $A
cp R19, Dig_2
brne MainLoop
clr Dig_2
SET_DIGIT 3 
inc Dig_3
ldi R19, $A
cp R19, Dig_3
brne MainLoop
clr Dig_3

rjmp MainLoop 

DelayInMs:
    push R30
    push R31 
    LOAD_CONST R30, R31, $F ;5ms  200Hz Segment (50Hz ca³y)
    InsideDelayInMs:
    rcall DelayOneMs
    sbiw r30, 1
    brne InsideDelayInMs
    pop R31
    pop R30
    ret
DelayOneMs:
    push r30
    push r31
    LOAD_CONST R30, R31, $07CB ;1995us
    InsideDelayOneMs:
        sbiw r30, 1
        brcc InsideDelayOneMs
        pop r31
        pop r30
        ret

DigitTo7segCode:
push R30
push R31
ldi R30, low(Table<<1)   
ldi R31, high(Table<<1) 
add R30, R16
lpm R16, Z    
pop R31
pop R30
ret
Table: .db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F 

DigitToPin:
push R30
push R31
ldi R30, low(Table1<<1)   
ldi R31, high(Table1<<1) 
add R30, R16
lpm R16, Z    
pop R31
pop R30
ret
Table1: .db $2,$4,$8,$10