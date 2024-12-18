.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

; inputs 
.def XL=R16 ; divident   
.def XH=R17  
.def YL=R18 ; divisor 
.def YH=R19  
; outputs 
.def RL=R16 ; remainder  
.def RH=R17  
.def QL=R18 ; quotient 
.def QH=R19  
; internal 
.def QCtrL=R24 
.def QCtrH=R25

; internals 
.def Dig0=R22 ; Digits temps 
.def Dig1=R23 ;  
.def Dig2=R24 ;  
.def Dig3=R25 ; 

.macro SET_DIGIT
    push R16
    ldi r16, @0
    rcall DigitToPin
    out Digits_P, r16   ;Init Seg_0
    mov R16, Digit_@0  
    rcall DigitTo7segCode  
    out Segments_P, R16 ;Light Dig_0
    rcall DelayInMs

    pop R16
.endmacro

.equ Digits_P = PORTB
.equ Segments_P = PORTD

.def Digit_0=R2
.def Digit_1=R3
.def Digit_2=R4
.def Digit_3=R5

ldi R18, $0
mov Digit_0, R18
ldi R18, $0
mov Digit_1, R18
ldi R18, $0
mov Digit_2, R18
ldi R18, $0
mov Digit_3, R18

ldi r16, 0xFF       ;Declare pins as output
out DDRD, r16
ldi r16, 0x1E       ;Declare pin 1-4 portB, as output   
out DDRB, r16         

MainLoop: 
LOAD_CONST XL,XH, 9864
rcall NumberToDigits

SET_DIGIT 3
inc Digit_3
ldi R20, $A
cp R20, Digit_3
brne MainLoop
clr Digit_3

SET_DIGIT 2
inc Digit_2
ldi R20, $A
cp R20, Digit_2
brne MainLoop
clr Digit_2

SET_DIGIT 1
inc Digit_1
ldi R19, $A
cp R20, Digit_1
brne MainLoop
clr Digit_1

SET_DIGIT 0 
inc Digit_0
ldi R20, $A
cp R20, Digit_0
brne MainLoop
clr Digit_0

rjmp MainLoop 

DelayInMs:
    push R30
    push R31 
    LOAD_CONST R30, R31, $F ;5ms  200Hz Segment (50Hz ca�y)
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

Divide:
push R24
push R25
clr r24
clr r25
Compare:
    cp  XL, YL     
    cpc XH, YH    
    brcs end_div  
    sub XL, YL    
    sbc XH, YH   
    adiw QCtrL, 1  
    rjmp Compare  
end_div:
    movw RL, XL
    movw QL, QCtrl
pop R25
pop R24
    ret


NumberToDigits:
push Dig0
push Dig1
push Dig2
push Dig3
LOAD_CONST YL, YH, 1000 ;Thousand
rcall Divide
mov Dig0,QL
LOAD_CONST YL, YH, 100  ;Hundreds
rcall Divide
mov Dig1, QL
LOAD_CONST YL, YH, 10   ;Tens
rcall Divide
mov Dig2, QL
mov Dig3, RL
mov R16,Dig0
mov R17,Dig1
mov R18,Dig2
mov R19,Dig3
pop Dig3
pop Dig2
pop Dig1
pop Dig0
ret
