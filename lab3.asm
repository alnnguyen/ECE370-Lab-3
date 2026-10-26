;***********************************************************
;*	This is the skeleton file for Lab 3 of ECE 375
;*
;*	 Author: Enter your name
;*	   Date: Enter date
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register is required for LCD Driver




;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp INIT				; Reset interrupt

.org	$0056					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine
		; Initialize Stack Pointer
		ldi  mpr, high(RAMEND)   ; mpr = high byte of top address
		out  SPH, mpr           ; SPH now holds the high byte
		ldi  mpr, low(RAMEND)    ; overwrite mpr with the low byte
		out  SPL, mpr           ; SPL now holds the low byte
		; Initialize LCD Display
		rcall LCDInit

		rcall LCDClr                    ; writes $20 (space) to $0100-$011F, could be garbage there

		; Point Z at the first character of STRING1 in program memory.
		; <<1 will convert the word address to a byte address
		ldi  ZL, low(STRING1_BEG<<1)    ; low byte of the byte address
		ldi  ZH, high(STRING1_BEG<<1)   ; high byte of the byte address

		; Point Y at the first position of line 1 in data memory.
		ldi  YL, low($0100)          
		ldi  YH, high($0100)      
		
		ldi  r17, (STRING1_END-STRING1_BEG)*2
		rcall CopyString

		; string 2 -> line 2
		ldi  ZL, low(STRING2_BEG<<1)
		ldi  ZH, high(STRING2_BEG<<1)
		ldi  YL, low($0110)
		ldi  YH, high($0110)
		ldi  r17, (STRING2_END-STRING2_BEG)*2
		rcall CopyString  




		; NOTE that there is no RET or RJMP from INIT,
		; this is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Main function design is up to you. Below is an example to brainstorm.

		; Move strings from Program Memory to Data Memory

		; Display the strings on the LCD Display

		MAIN:
    loop forever:
        if PD4 pressed:
            LCDClr()                ; blank both lines
        if PD5 pressed:
            CopyStrings()           ; restore the original text in the buffers
            LCDWrite()              ; send both lines to the display
        if PD7 pressed:
            repeat until PD7 released (or let it run continuously):
                ScrollStep()        ; shift the text one position
                LCDWrite()          ; show the new positions
                Delay(0.25 s)       ; long enough to read
        ; (PD6 is not used)




		rjmp	MAIN			; jump back to main and create an infinite
								; while loop.  Generally, every main program is an
								; infinite while loop, never let the main program
								; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the
;		beginning of your functions
;-----------------------------------------------------------
FUNC:							; Begin a function with a label
		; Save variables by pushing them to the stack

		; Execute the function here

		; Restore variables by popping them from the stack,
		; in reverse order

		ret						; End a function with RET


;-----------------------------------------------------------
; Func: CopyString
; Desc: Copies a string from program memory to data memory.
; In:   Z = byte address of source string (label<<1)
;       Y = data memory destination
;       r17 = number of characters to copy
; Out:  none
; Uses: mpr, Z, Y, r17 (r17 is changed)
;-----------------------------------------------------------
CopyString:
copy_str_loop:
    lpm  mpr, Z+
    st   Y+, mpr
    dec  r17
    brne copy_str_loop
    ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING1_BEG:
.DB "Sawyer L"
STRING1_END:
STRING2_BEG:
.DB "HelloWorld"
STRING2_END:
;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver
