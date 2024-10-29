.cseg         
.macro LOAD_CONST
ldi @0, low(@2)
ldi @1, high(@2)
.endmacro

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

.def Digit_0=R2
.def Digit_1=R3
.def Digit_2=R4
.def Digit_3=R5

.equ Digits_P = PORTB
.equ Segments_P = PORTD

.def PulseEdgeCtrL=R0 
.def PulseEdgeCtrH=R1

.org 0 rjmp _main

.org OC1Aaddr rjmp _timer_isr

.org 0x000B rjmp _PB0_isr

_PB0_isr:
push r16
push r17
push r24
push r25
in r16, SREG
inc PulseEdgeCtrL
brne ENDINT0
inc PulseEdgeCtrH
    EndINT0:
    out SREG, r16
    pop r25
    pop r24
    pop r17
    pop r16
    
reti

_timer_isr: 
movw R16:R17,PulseEdgeCtrL:PulseEdgeCtrH
rcall NumberToDigits
movw Digit_0:Digit_1, XL:XH
movw Digit_2:Digit_3, YL:YH
reti                        

_main:
ldi R18, $0
mov Digit_0, R18
ldi R18, $0
mov Digit_1, R18
ldi R18, $0
mov Digit_2, R18
ldi R18, $0
mov Digit_3, R18
clr r18   
ldi r16, 0x7F       ;Declare pins as output
out DDRD, r16
ldi r16, 0x1E    ; Set PB0 as input (clear bit 0), others as output
out DDRB, r16
clr r16

Int_0_Init:
push R16
ldi R16, (1 << INT0) | (1 << PCIE0)
out GIMSK, R16
ldi R16, (1 << ISC01) | (1 << ISC00)
out MCUCR, R16
ldi R16, (1 << PCINT0)
out PCMSK0, R16
pop R16

TimerInit:
push r16
push r17
ldi r17, 12
ldi r16,  18          ;wpisaujemy wartoœc dla którego nast¹pi interrupt, skoro jest ustawiony na 256 to musimy tu ustawic na 0-99(100x)
out OCR1AH, r17
out OCR1AL, r16
ldi R16, (1 << WGM12) | (1 << CS12)  ;ustawia CRC
out TCCR1B, R16         ; Wpisujemy w komórke pamiêci, a nie w jeden bit
ldi r16, (1 << OCIE1A)  ;Compare T1 with OCR1A
out TIMSK, r16
pop r17
pop r16

sei
MainLoop:

SET_DIGIT 0
SET_DIGIT 1
SET_DIGIT 2
SET_DIGIT 3
    LOAD_CONST XL,XH, 9999
cp PulseEdgeCtrH, XH      
    brlo ContinueLoop         
    brne ResetCounter         
    cp PulseEdgeCtrL, XL      
    brsh ResetCounter         
ContinueLoop:
    rjmp MainLoop             
ResetCounter:
    clr PulseEdgeCtrL         
    clr PulseEdgeCtrH         
rjmp MainLoop             
DelayInMs:
    push R30
    push R31 
    LOAD_CONST R30, R31, $5 ;5ms  200Hz Segment (50Hz ca³y)
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
mov XL,Dig0
mov XH,Dig1
mov YL,Dig2
mov YH,Dig3
pop Dig3
pop Dig2
pop Dig1
pop Dig0
ret
