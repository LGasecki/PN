 ;### MACROS & defs (.equ)###

; Macro LOAD_CONST loads given registers with immediate value, example: LOAD_CONST  R16,R17 1234 
.MACRO LOAD_CONST  
    ldi @0, low(@2)
    ldi @1, high(@2)
.ENDMACRO 

/*** Display ***/
.equ DigitsPort = PORTB            
.equ SegmentsPort = PORTD       
.equ DisplayRefreshPeriod = 5 

; SET_DIGIT diplay digit of a number given in macro argument, example: SET_DIGIT 2
.MACRO SET_DIGIT  
  push R16
    ldi r16, @0
    rcall DigitToPin
    out DigitsPort, r16   ;Init Seg_0
    mov R16, Dig_@0  
    rcall DigitTo7segCode  
    out SegmentsPort, R16 ;Light Dig_0
    rcall DelayInMs
    pop R16
.ENDMACRO 

; ### GLOBAL VARIABLES ###

.def PulseEdgeCtrL=R0
.def PulseEdgeCtrH=R1

.def Dig_0=R2
.def Dig_1=R3
.def Dig_2=R4
.def Dig_3=R5

; ### INTERRUPT VECTORS ###
.cseg		     ; segment pamiêci kodu programu 

.org	 0      rjmp	_main	 ; skok do programu g³ównego
.org OC1Aaddr	rjmp  _Timer_ISR
.org PCIBaddr   rjmp  _ExtInt_ISR

; ### INTERRUPT SEERVICE ROUTINES ###

_ExtInt_ISR: 	 ; procedura obs³ugi przerwania zewnetrznego
/**/
    push R24
    push R25
    in R24, SREG
    in R25, PINB
    sbrc R25, 0
    rjmp Increment
    rjmp NoOverflow
Increment:
    inc PulseEdgeCtrL
    brne NoOverflow
    inc PulseEdgeCtrH
    rjmp NoOverflow
NoOverflow:
    out SREG, R24
    pop R25
    pop R24
/**/
reti   ; powrót z procedury obs³ugi przerwania (reti zamiast ret)      

_Timer_ISR:
    push R16
    push R17
    push R18
    push R19
    push r24
    push r25

        movw XL:XH, PulseEdgeCtrL:PulseEdgeCtrH
        rcall _NumberToDigits
        movw Dig_0:Dig_1, XL:XH
        movw Dig_2:Dig_3, YL:YH
        clr PulseEdgeCtrL
        clr PulseEdgeCtrH

    pop r25
    pop r24
	pop R19
    pop R18
    pop R17
    pop R16

  reti

; ### MAIN PROGAM ###

_main: 
    ; *** Initialisations ***

    ;--- Ext. ints --- PB0
    push R16
    ldi R16, (1 << PCIE0)    /* pin change interrupt enable*/
    out GIMSK, R16
    ldi R16, (1 << PCINT0)    /*pin change interrupt enable on corresponding I/0 pin*/
    out PCMSK0, R16
    pop R16

	;--- Timer1 --- CTC with 256 prescaller
    push r16
    push r17

    ldi r16, (1 << WGM12) | (1 << CS12)  ; CTC mode, prescaler 256
    out TCCR1B, r16
    ldi r16, (1 << OCIE1A)  ; Enable Timer1 compare interrupt
    out TIMSK, r16
    ldi R17, 122
    ldi R16, 17
    out OCR1AH, R17  /* high musi byæ wpisany przed low */
    out OCR1AL, R16

    pop r17
    pop r16
			
	;---  Display  --- 
    ldi R18, $0
    mov Dig_0, R18
    ldi R18, $0
    mov Dig_1, R18
    ldi R18, $0
    mov Dig_2, R18
    ldi R18, $0
    mov Dig_3, R18
    clr r18   
    ldi r16, 0x7F      
    out DDRD, r16
    ldi r16, 0x1E   
    out DDRB, r16
    clr r16
	; --- enable gloabl interrupts
    SEI

MainLoop:   ; presents Digit0-3 variables on a Display
			SET_DIGIT 0
			SET_DIGIT 1
			SET_DIGIT 2
			SET_DIGIT 3

			RJMP MainLoop

; ### SUBROUTINES ###

;*** NumberToDigits ***
;converts number to coresponding digits
;input/otput: R16-17/R16-19
;internals: X_R,Y_R,Q_R,R_R - see _Divider

; internals
.def Dig0=R22 ; Digits temps
.def Dig1=R23 ; 
.def Dig2=R24 ; 
.def Dig3=R25 ; 

_NumberToDigits:

	push Dig0
	push Dig1
	push Dig2
	push Dig3

	; thousands 
    LOAD_CONST YL, YH, 1000 
    rcall _Divide
    mov Dig0,QL

	; hundreads 
    LOAD_CONST YL, YH, 100  
    rcall _Divide
    mov Dig1, QL    

	; tens 
    LOAD_CONST YL, YH, 10   ;Tens
    rcall _Divide
    mov Dig2, QL
	; ones 
    mov Dig3, RL

	; otput result
	mov R16,Dig0
	mov R17,Dig1
	mov R18,Dig2
	mov R19,Dig3

	pop Dig3
	pop Dig2
	pop Dig1
	pop Dig0

	ret

;*** Divide ***
; divide 16-bit nr by 16-bit nr; X/Y -> Qotient,Reminder
; Input/Output: R16-19, Internal R24-25

; inputs
.def XL=R16 ; divident  
.def XH=R17 

.def YL=R18 ; divider
.def YH=R19 

; outputs

.def RL=R16 ; reminder 
.def RH=R17 

.def QL=R18 ; quotient
.def QH=R19 

; internal
.def QCtrL=R24
.def QCtrH=R25

_Divide:push R24 ;save internal variables on stack
        push R25
		
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

		pop R25 ; pop internal variables from stack
		pop R24

		ret

; *** DigitTo7segCode ***
; In/Out - R16

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

Table: .db 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0xff,0x6f

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

; *** DelayInMs ***
; In: R16,R17
DelayInMs:  
            push R24
			push R25

    LOAD_CONST R24, R25, DisplayRefreshPeriod ;5ms  200Hz Segment (50Hz ca³y)
    InsideDelayInMs:
    rcall OneMsLoop
    sbiw r24, 1
    brne InsideDelayInMs

			pop R25
			pop R24
			ret

; *** OneMsLoop ***
OneMsLoop:	
			push R24
			push R25 
			
			LOAD_CONST R24,R25,2000                    

L1:			SBIW R24:R25,1 
			BRcc L1

			pop R25
			pop R24

			ret



