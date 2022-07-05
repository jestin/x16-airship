.ifndef JOYSTICK_ASM
JOYSTICK_ASM = 1

.segment "DATA"
joystick_data:		.res 3
joystick_changed_data:		.res 3

.segment "CODE"

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
