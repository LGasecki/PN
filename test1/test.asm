 ;### MACROS & defs (.equ)###

; Macro LOAD_CONST loads given registers with immediate value, example: LOAD_CONST  R16,R17 1234 
.MACRO LOAD_CONST  
 ldi @0, low(@2)
 ldi @1, high(@2)
.ENDMACRO 

/*** Display ***/
.equ DigitsPort  = PORTB         ; TBD
.equ SegmentsPort   =  PORTD        ; TBD
.equ DisplayRefreshPeriod = 5   ; TBD

; SET_DIGIT diplay digit of a number given in macro argument, example: SET_DIGIT 2
.MACRO SET_DIGIT  
 push r16
 ldi r16, (1<<(@0+1))
 out DigitsPort, r16
 mov r16, Dig_@0
 rcall DigitTo7segCode
 out SegmentsPort, r16
 rcall DelayInMs
 pop r16
.ENDMACRO 

; ### GLOBAL VARIABLES ###

.def PulseEdgeCtrL=R0
.def PulseEdgeCtrH=R1

.def Dig_0=R2
.def Dig_1=R3
.def Dig_2=R4
.def Dig_3=R5

; ### INTERRUPT VECTORS ###
.cseg		     ; segment pami�ci kodu programu 

.org	 0      rjmp	_main	 ; skok do programu g��wnego
.org OC1Aaddr	rjmp _Timer_ISR ; TBD
.org 0x0B   rjmp  _ExtInt_ISR; TBD ; skok do procedury obs�ugi przerwania zenetrznego 

; ### INTERRUPT SEERVICE ROUTINES ###

_ExtInt_ISR: 	 ; procedura obs�ugi przerwania zewnetrznego

push R24
push R25
in R24, SREG
Increment:
inc PulseEdgeCtrL
brne NoOverflow
inc PulseEdgeCtrH
rjmp NoOverflow
NoOverflow:
out SREG, R24
pop R25
pop R24
 ; TBD

reti   ; powr�t z procedury obs�ugi przerwania (reti zamiast ret)      

_Timer_ISR:
    push R16
    push R17
    push R18
    push R19

    push r20
    in r20, SREG
        movw r16,PulseEdgeCtrL
        clr PulseEdgeCtrL
        clr PulseEdgeCtrH
        rcall _NumberToDigits
        movw Dig_0, r16
        movw Dig_2, r18
        out SREG, r20
    pop r20

	pop R19
    pop R18
    pop R17
    pop R16

  reti

; ### MAIN PROGAM ###

_main: 
    ; *** Initialisations ***

    ;--- Ext. ints --- PB0
    ; TBD
    push r16
    cli
    ldi r16,(1<<PCIE0)
    out GIMSK, r16
    ldi R16, (1<<ISC00)
    out PCMSK0, r16
    sei
    pop r16
	;--- Timer1 --- CTC with 256 prescaller
    ; TBD
    push r16
    push r17
    ldi r16, (1<<WGM12) | (1<<CS12)
	out TCCR1B, r16
    ldi r16, (1<<OCIE1A)
    out TIMSK, r16
    ldi r17, 61
    ldi r16, 8
    out OCR1AH, r17
    out	OCR1AL, r16
    pop r17
    pop r16	
	;---  Display  --- 
ldi R18, $0
mov Dig_0, R18
mov Dig_1, R18
mov Dig_2, R18
mov Dig_3, R18 
ldi r16, 0x7F      
out DDRD, r16
ldi r16, 0x1E    
out DDRB, r16
clr r16

	; --- enable gloabl interrupts
    SEI
    ; TBD

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
_NumberToDigits:

	push Dig0
	push Dig1
	push Dig2
	push Dig3

	; thousands 
    LOAD_CONST YL,YH, 1000
    rcall _Divide
    mov Dig0, QL
    ; TBD

	; hundreads 
    LOAD_CONST YL,YH, 100
    rcall _Divide
    mov Dig1, QL
    ; TBD     

	; tens 
    LOAD_CONST YL,YH, 10
    rcall _Divide
    mov Dig2, QL
    ; TBD    

	; ones 
    mov Dig3, RL
    ; TBD

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



_Divide:
        push R24 ;save internal variables on stack
        push R25
		clr r24
        clr r25
        Compare:
        cp XL, YL
        cpc XH, YH
        brcs end_div
        sub XL, YL
        sbc XH, YH
        adiw QCtrl, 1
        rjmp Compare
        end_div:
        movw RL, XL
        mov QL, QCtrl
        ; TBD

		pop R25 ; pop internal variables from stack
		pop R24

		ret

; *** DigitTo7segCode ***
; In/Out - R16

Table: .db 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

DigitTo7segCode:

push R30
push R31

ldi R30, low(Table<<1)
ldi R31, high(Table<<1)
add r30, r16
lpm R16, Z
    ; TBD

pop R31
pop R30

ret

; *** DelayInMs ***
; In: R16,R17
DelayInMs:  
            push R24
			push R25

            LOAD_CONST R24, R25, DisplayRefreshPeriod
            L2:
            rcall OneMsLoop
            sbiw r24, 1
            brne L2

            ; TBD

			pop R25
			pop R24

			ret

; *** OneMsLoop ***
OneMsLoop:	
			push R24
			push R25 
			
			LOAD_CONST R24,R25,2000                    

L1:			SBIW R24:R25,1 
			BRNE L1

			pop R25
			pop R24

			ret



