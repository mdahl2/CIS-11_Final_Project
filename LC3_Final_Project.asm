.ORIG X3000
LEA R0,MESSAGE 
PUTS				; Get inputs
LD R0,SPACE			; New line
OUT


;R4-PRODUCT OF R0*10
;R2-COUNTER
;R5-HOLDS ADDITION OF BOTH CHARACTERS
;R0-HOLDS 2ND CHARACTER
LD R3,ARRAY        ; load x4000 in R3 as array base address
LD R2,COUNT        ; load #5 in R2 as counter from 5 to 1
AND R1,R1,#0        ;Clear R1

LOOP
;------------------------------------------------------------------
;CLEAR REGISTERS
AND R0,R0,#0
AND R5,R0,#0
AND R4,R0,#0

GETC		;CHAR 1
OUT
JSR DECODE		;Convert to Decimal
STI R0,HOLD1
JSR MULT



AND R0,R0,#0
GETC		;CHAR 2 
OUT
JSR DECODE		;Convert to Decimal

STI R4, TEMP
LDI R4,HOLD1
STI R0,HOLD2
JSR GRADES
RES LDI R4,TEMP
LDI R0,HOLD2

AND R5,R5,#0
ADD R5,R4,R0	;R5 = CHAR1 +CHAR2

ADD R1,R1,R0           ;R1 = char1 +char2
ADD R1,R1,R4           ;R1 = char1 +char2

STI R5,VALUE	;VALUE = CHAR1 +CHAR2
LD R0, SPACE
OUT
AND R0,R0,#0
LDI R0,VALUE	;R0 = PRODUCT

;ARRAY-------------------------------------------------------------- 
STR R0,R3,#0       ; store inputted chatacter in mem addr stored in R3
ADD R3,R3,#1       ; increment R3 (mem location)
ADD R2,R2,#-1      ; decrement R2 (counter)
BRp LOOP

STI R1,TEMP
AND R4,R4,#0
AND R2,R2,#0
ADD R2,R2,#5	; counter 
AND R3,R3,#0

;OUTPUTS THE AVERAGE
JSR DIVISION
STI R3,AVERAGE
LEA R0,MESSAGE2		;OUTPUTS THE AVERAGE TEST SCORE
PUTS
LDI R0,AVERAGE; 
JSR SPLIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;AVERAGE

;R1 IS OUR 1ST DIGIT
AND R0,R0,#0
ADD R0,R1,#0
ADD R4,R1,#0
JSR ENCODE
OUT

;R2 IS OUR 2ND DIGIT
AND R0,R0,#0
ADD R0,R2,#0
JSR ENCODE
OUT
JSR GRADES			; get grade
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JSR STACK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUTS THE HIGHEST NUMBER
JSR MAX
LD R0,SPACE
OUT
LEA R0,MESSAGE3
PUTS
LDI R0,MAX_VAL
JSR SPLIT

;R1 IS OUR 1ST DIGIT
AND R0,R0,#0
ADD R0,R1,#0
ADD R4,R1,#0
JSR ENCODE
OUT

;R2 IS OUR 2ND DIGIT
AND R0,R0,#0
ADD R0,R2,#0
JSR ENCODE
OUT
JSR GRADES		; get grade

; OUTPUT THE LOWEST SCORE
JSR MIN
LD R0,SPACE
OUT
LEA R0,MESSAGE4
PUTS
LDI R0,MIN_VAL
JSR SPLIT

;R1 IS OUR 1ST DIGIT
AND R0,R0,#0
ADD R0,R1,#0
ADD R4,R1,#0
JSR ENCODE
OUT

;R2 IS OUR 2ND DIGIT
AND R0,R0,#0
ADD R0,R2,#0
JSR ENCODE
OUT
JSR GRADES		; get grade

HALT


;**************************************************************
;*     The multiplicand is in R0 
;*     the multiplier   is in R2
;*     PRODUCT 		is in R4       
;**************************************************************
MULT    
	 LD R6,COUNTER
	 AND R4, R4, #0
MULTLOOP ADD R4, R4, R0      	; Add multiplicand to product
             ADD R6, R6, #-1    		; Decrement multiplier
             BRp MULTLOOP        	;If multiplier is positive, continue loop
	     	
	 RET                 ; Return from subroutine

;**************************************************************
;*     The divisor is in  R2
;*     The DIVIDENT  is in R1
;*     ANSWER		is in R3       
;**************************************************************
DIVISION
      NOT R2,R2
      ADD R2,R2,#1
      DIVISIONLOOP         ADD R3,R3,#1		;Update Quotient by 1
			   ADD R1,R1,R2	            ;R1-R2
		           
      BRp	          DIVISIONLOOP 
			           
		          RET     

;**************************************************************
;*     Grades
;      Convert 1st digit of number to output grade value    
;**************************************************************
GRADES      
	    ST R7, SAVE
	    AND R0, R0, #0
            LEA R0, STRINGZ_ARRAY   ; ADDRESS OF LETTERS ARRAY
            ADD R4, R4, #0
    LOOPL   BRz DISPLAY              ; If R4 is negative or zero, go to DISPLAY
            ADD R0, R0, #2           ; Move to the next element in the array
            ADD R4, R4, #-1          ; Decrement R4 by 1
            BR LOOPL               
    DISPLAY PUTS
	    LD R7,SAVE
            RET
		

;**************************************************************
;*     	Stack   
;*	POINTER-R6
;*	VALUE-R0
;*	COUNTER-R1
;*	ADDRESS-R2
;**************************************************************

STACK 	AND R1,R1,#0
	AND R2,R2,#0

	ST R7,SAVE1
      	LD R2,ARRAY
	ADD R1,R1,#5

LOOPS	LDR R0,R2,#0
	ADD R2,R2,#1       ; increment R2 (mem location)
	JSR PUSH
	ADD R1,R1,#-1
	BRp LOOPS
	LD R7,SAVE1
	RET

PUSH	
	LD R6,STACK_LOC
	ADD R6, R6, #-1		;move one location up the stack
	STR R0, R6, #0		;push element
	ST R6 STACK_LOC		;update the pointer location
	RET


POP	LD R6,STACK_LOC
	LDR R0,R6,#0	;pop
	ADD R6,R6,#1
	ST R6,STACK_LOC
	RET

RESET	LD R6,STACK_LOC
	ADD R6,R6,#-5
	STI R6,CHECK

;**************************************************************
;	DECODE FUNCTION   
;**************************************************************
DECODE  ADD R0,R0,#-15
	ADD R0,R0,#-15
	ADD R0,R0,#-15
	ADD R0,R0,#-3
	RET

;**************************************************************
;	ENCODE FUNCTION   
;**************************************************************
ENCODE  ADD R0,R0,#15
	ADD R0,R0,#15
	ADD R0,R0,#15
	ADD R0,R0,#3
	RET

;**************************************************************
;	SPLIT FUNCTION   
;	R0 - CONTAINS WHOLE NUMBER
;	R1- CONTAINS 1ST DIGIT
;	R2-CONTAINS 2ND DIGIT
;	R3-Counter
;**************************************************************

SPLIT
AND R3,R3,#0
AND R1,R1,#0
AND R2,R2,#0
STI R0, REACH

	LOOP_SPLIT	
	ADD R3, R3, #1	   	; Update Quotient by 1
	ADD R0, R0, #-10	; R0 - 10
	BRzp LOOP_SPLIT

	ADD R1, R3, #-1		; R1 gets the quotient
	STI R1, X			; Store the quotient in X
	ADD R2, R0, #10		; R2 gets the remainder
	STI R2, Y			; Store the remainder in Y
	RET
	
X	.FILL X3505
Y	.FILL X3506



;**************************************************************
;	MAX FUNCTION   
;	LOAD the first element initialize it as a max 
; 	Loop: ADD both element 
;		if it’s > 0 then branch to new_max: change loop 
;	R0-VALUE FROM POP
;	R3-TEMP VALUE
;	R5-COUNTER
;	R1-MIN
;;**************************************************************
MAX 	
ST R7,SB
AND R0,R0,#0
AND R1,R1,#0
AND R3,R3,#0
AND R5,R5,#0
AND R2,R2,#0
ADD R5,R5,#4	;COUNTER
JSR POP		;R0 INITIALIZED WITH STACK VALUE
STI R0,MAX_VAL
LDI  R1,MAX_VAL	;1ST VALUE TO COMPARE WITH IN MIN FUNCTION
ADD R3,R3,R0	;R3=R0(CONTAINS MAX)
;51 , 4000
LOOP_MAX	JSR MIN
		AND R2,R2,#0
		ADD R5,R5,#-1	;DECREASE COUNTER	
		AND R0,R0,#0	;CLEAR R0
		JSR POP		;R0 = POPPED VALUE
				;R3=MAX	R0 = POPPED VALUE
		NOT R3,R3
		ADD R3,R3,#1
		ADD R2,R3, R0	;  R0 = 40, R3 = 10
		
BRn MAX_V		
STI R0,MAX_VAL
MAX_V		LDI R3,MAX_VAL
 		ADD R5,R5,#0
		BRp LOOP_MAX
		LD R7,SB
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**************************************************************
;	MIN FUNCTION   
;	LOAD the first element initialize it as a MIN
; 	Loop: ADD both element 
;		if it’s <  0 then branch to new_max: change loop 
;	R0-VALUE FROM POP 
;	R1-TEMP VALUE		(ANY R3->R1)
;	R4-COMP
;
;;**************************************************************
MIN
ST R7,SA
;MIN_VAL - 1ST VALUE TO COMPARE
AND R4,R4,#0
				
		NOT R1,R1
		ADD R1,R1,#1
		ADD R4,R1, R0	;  R0 = 40, R1 = 10
		BRp MIN_V
		STI R0,MIN_VAL

		MIN_V LDI R1,MIN_VAL
		LD R7,SA
		      RET
				
;;;;;;;;;;;;;;;;;;;;;;

CHECK .FILL X3515
MAX_VAL .FILL X3510
MIN_VAL .FILL X3511
ABS 	    .FILL X3512


SA	.FILL X0
SB	.FILL X0

AVERAGE   .FILL x3402
TEMP 	 .FILL x3400
LETTER	 .FILL x3403
VALUE    .FILL X3401
HOLD1	.FILL X3406
HOLD2	.FILL X3407
ARRAY	.FILL x3500
COUNTER .FILL #10
COUNT 	.FILL #5  
SPACE 	.FILL xA
SAVE	.FILL x0
SAVE1	.FILL x0
STACK_LOC .FILL X4000
REACH  .FILL X3517
MESSAGE .STRINGZ "ENTER TEST SCORES"
MESSAGE2 .STRINGZ "AVERAGE TEST SCORE :"
MESSAGE3 .STRINGZ "THE HIGHEST TEST SCORE :"
MESSAGE4  .STRINGZ "THE LOWEST TEST SCORE :"





LF	.FILL X000A

;.STRINGZ array

STRINGZ_ARRAY   .STRINGZ "F"
		.STRINGZ "F"
		.STRINGZ "F"
		.STRINGZ "F"
		.STRINGZ "F"
		.STRINGZ "F"
                .STRINGZ "D"
                .STRINGZ "C"
                .STRINGZ "B"
                .STRINGZ "A"



.END







