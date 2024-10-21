DigitTo7segCode:
push R30
push R31
ldi R30, low(Table<<1)   
ldi R31, high(Table<<1) 

adiw R30:R31, 6
lpm R16, Z    
 
Table: .db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x4F 
pop R31
pop R30
ret