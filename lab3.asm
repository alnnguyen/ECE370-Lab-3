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

		rcall LCDClr                  ; writes $20 (space) to $0100-$011F, could be garbage there

		clr r23 ;initialize the flag to 0 so that we are not scrolling

		; Initialize the I/O ports
		ldi mpr, $00
		out DDRD, mpr          ; set PORTD to input

		ldi  mpr, (1<<PD4)|(1<<PD5)|(1<<PD7) ; set PORTD pins 4,5,7 to pull-up, using << to make it into a bit pattern, then or'ing them together to make a single byte
		out  PORTD, mpr

		rcall RestoreStrings              ; initial copy of the strings into the buffers


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

		in   mpr, PIND          ; read all of port D
		andi mpr, (1<<PD4)      ; keep only bit 4; everything else becomes 0
		brne check_PD5          ; if PD4 is 1 (not pressed), skip to check_PD5
		rcall PD4_pressed        ; result is 0 only if PD4 was 0 (pressed)
		
check_PD5:
		in   mpr, PIND          ; read all of port D
		andi mpr, (1<<PD5)      ; keep only bit 5; everything else becomes 0
		brne check_PD7          ; if PD5 is 1 (not pressed), skip to check_PD7
		rcall PD5_pressed        ; result is 0 only if PD5 was 0 (pressed)
		
check_PD7:
		in   mpr, PIND          ; read all of port D
		andi mpr, (1<<PD7)      ; keep only bit 7; everything else becomes 0
		brne scroll        ; if PD7 is 1 (not pressed), skip to scroll_check
		rcall PD7_pressed        ; result is 0 only if PD7 was 0
scroll_check:
		;r23 will be the flag to see if we are supposed to scroll or not, if it is 1 we are scrolling, if it is 0 we are not
       tst r23
	   breq main_loop ;if the flag is 0, we are not scrolling, so skip the scroll step
	   rcall ScrollStep ;if the flag is 1, we are scrolling, so scroll





	
	main_loop:
				rjmp	MAIN	; jump back to main and create an infinite						
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


;-----------------------------------------------------------
; Func: PD4_pressed
; Desc: Checks if PD4 is pressed and clears the LCD if it is.
; In:   none
; Out:  none
; Uses: mpr
;-----------------------------------------------------------
PD4_pressed:
		ldi r23 , 0 ;set the flag to 0 so that we are not scrolling
		rcall LCDClr    
		ret						; End a function with RET


;-----------------------------------------------------------
; Func: RestoreStrings
; Desc: Restores the original strings in the data memory buffers.
; In:   none
; Out:  none
; Uses: mpr, Z, Y, r17 (r17 is changed)
;-----------------------------------------------------------
RestoreStrings:
	
	 rcall LCDClr            ; blank both lines first, so no leftover characters
	; Point Z at the first character of STRING1 in program memory.
		; <<1 will convert the word address to a byte address
		ldi  ZL, low(STRING1_BEG<<1)    ; low byte of the byte address
		ldi  ZH, high(STRING1_BEG<<1)   ; high byte of the byte address

		; Point Y at the first position of line 1 in data memory.
		ldi  YL, low($0100)          
		ldi  YH, high($0100)      
		
		ldi  r17, (STRING1_END-STRING1_BEG)*2 ; doubling length because of the word address to byte address conversion
		rcall CopyString

		; string 2 -> line 2
		ldi  ZL, low(STRING2_BEG<<1)
		ldi  ZH, high(STRING2_BEG<<1)
		ldi  YL, low($0110)
		ldi  YH, high($0110)
		ldi  r17, (STRING2_END-STRING2_BEG)*2
		rcall CopyString  


		ret						; End a function with RET

;-----------------------------------------------------------
; Func: PD5_pressed
; Desc: Displays the original strings on the LCD when PD5 is pressed.
; In:   none
; Out:  none
; Uses: mpr 
;-----------------------------------------------------------
PD5_pressed:
		ldi r23 , 0 ;set the flag to 0 so that we are not scrolling
		rcall RestoreStrings ;restore the original text in the buffers that could have been scrolled
		rcall LCDWrite ;uses the buffers already full of the original strings to write to the LCD
		ret						; End a function with RET


;-----------------------------------------------------------
; Func: PD7_pressed
; Desc: Displays orginal strings on the LCD and scrolls them when PD7 is pressed.
; In:   none
; Out:  none
; Uses: mpr
;-----------------------------------------------------------
PD7_pressed:
	cpi  r23, 1             ; is the scroll flag already high
    breq PD7_Done           ; if yes, skip the rest of this function

    rcall RestoreStrings      ; no
    rcall LCDWrite          
    ldi  r23, 1             ; set the flag high
	rcall Delay_250ms          ; wait a bit before scrolling

PD7_Done:
    ret                     ; both paths end here


;-----------------------------------------------------------
; Func: ScrollStep
; Desc: Scrolls the text in the data memory buffers by one position to the right.
; In:   none
; Out:  none
; Uses: mpr, Z, Y
;-----------------------------------------------------------
ScrollStep:
        ldi  YH, high($011F)    ; Y starts at the last byte
        ldi  YL, low($011F)
        ld   r18, Y             ; save the last byte, it wraps to $0100

        ldi  r17, 31            ; move 31 bytes
shift_loop:
        ld   mpr, -Y            ; step down, read the byte there
        std  Y+1, mpr           ; write it one position higher
        dec  r17
        brne shift_loop

        st   Y, r18             ; Y is now $0100; put the wrapped byte there
        rcall LCDWrite
        rcall Delay_250ms
        ret

;-----------------------------------------------------------
; Func: Delay_250ms
; Desc: Busy-waits about 0.25 s at 16 MHz (4,000,000 cycles).
; In:   none
; Out:  none
; Uses: r18, r19, r24 (all changed)
;-----------------------------------------------------------
Delay_250ms:
    ldi  r18, 26            ; outer loop count
D_outer:
    ldi  r19, 200           ; middle loop count
D_middle:
    ldi  r24, 255           ; inner loop count
D_inner:
    dec  r24                ; 1 cycle
    brne D_inner            ; 2 cycles when taken, 1 when not
    dec  r19
    brne D_middle
    dec  r18
    brne D_outer
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

