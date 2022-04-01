.ifndef JOYSTICK_ASM
JOYSTICK_ASM = 1

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

	; get joystick data
	lda #1
	jsr joystick_get
	sta joystick_data
	stx joystick_data+1
	sty joystick_data+2

	; compare against previous values, save a bitmask of the state change (1 means changed)
	lda joystick_data
	eor u0L
	sta joystick_changed_data
	lda joystick_data+1
	eor u0H
	sta joystick_changed_data+1
	lda joystick_data+2
	eor u1L
	sta joystick_changed_data+2

	rts

.endif ; JOYSTICK_ASM
