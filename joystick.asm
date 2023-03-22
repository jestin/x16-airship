.ifndef JOYSTICK_ASM
JOYSTICK_ASM = 1

; Button States
joystick_0_B	= %10000000
joystick_0_Y	= %01000000
joystick_0_SEL	= %00100000
joystick_0_STA	= %00010000
joystick_0_UP	= %00001000
joystick_0_DN	= %00000100
joystick_0_LT	= %00000010
joystick_0_RT	= %00000001

joystick_1_A	= %10000000
joystick_1_X	= %01000000
joystick_1_L	= %00100000
joystick_1_R	= %00010000

.segment "BSS"

joystick_data:		.res 3
joystick_changed_data:		.res 3

.segment "CODE"

;==================================================
; initialize_joystick_memory
;
; void initialize_joystick_memory()
;==================================================
initialize_joystick_memory:
	stz joystick_data
	stz joystick_data+1
	stz joystick_data+2
	stz joystick_changed_data
	stz joystick_changed_data+1
	stz joystick_changed_data+2

	rts

;==================================================
; update_joystick_data
;
; Custom tick handler for the character Pixryn
; overworld map.
;
; void update_joystick_data()
;==================================================
update_joystick_data:

	; move old joystick data to temp location
	lda joystick_data
	sta u0L
	lda joystick_data+1
	sta u0H
	lda joystick_data+2
	sta u1L

	; get joystick data from keyboard
	lda #0
	jsr joystick_get
	sta joystick_data
	stx joystick_data+1
	sty joystick_data+2

	; get joystick data
	lda #1
	jsr joystick_get
	cpy #0
	bne @calculate_changed_data

	; AND the values with what was read from the keyboard before storing
	; This is a little non-intuitive, but because 0 is used when the button is
	; pressed, this is essentially an OR for button presses
	and joystick_data
	sta joystick_data
	txa
	and joystick_data+1
	sta joystick_data+1

	; for Y, just overwrite what the keyboard returned.  This now becomes an
	; indicator for the joystick alone
	sty joystick_data+2


@calculate_changed_data:
	; compare against previous values, save a bitmask of the state change (1 means changed)
	lda joystick_data
	eor u0L
	sta joystick_changed_data
	lda joystick_data+1
	eor u0H
	sta joystick_changed_data+1

	; there's no reason to invert byte 2 of the joystick data, since it only
	; tells if the joystick is present

	rts

.endif ; JOYSTICK_ASM
