.ifndef TICK_HANDLERS_ASM
TICK_HANDLERS_ASM = 1

;==================================================
; character_overworld_tick
;
; Custom tick handler for the character Pixryn
; overworld map.
;
; void character_overworld_tick()
;==================================================
character_overworld_tick:

	; get joystick data
	lda #1
	jsr joystick_get
	sta joystick_data
	stx joystick_data+1
	sty joystick_data+2

	jsr animate_player
	jsr move

@return: 
	rts

.endif ; TICK_HANDLERS_ASM
