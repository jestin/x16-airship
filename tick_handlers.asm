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

	; move old joystick data to last_joystick_data
	lda joystick_data
	sta last_joystick_data
	lda joystick_data+1
	sta last_joystick_data+1
	lda joystick_data+2
	sta last_joystick_data+2

	; get joystick data
	lda #1
	jsr joystick_get
	sta joystick_data
	stx joystick_data+1
	sty joystick_data+2

	jsr animate_player
	jsr move
	jsr set_player_tile
	jsr check_interactions

	; Manually push the address of the jmp to the stack to simulate jsr
	; instruction.
	; NOTE:  Due to an ancient 6502 bug, we need to make sure that tick_fn
	; doesn't have $ff in the low byte.  It's a slim chance, but will happen
	; sooner or later.  When it does, just fix by putting in a nop somewhere to
	; bump the address foward.
	lda #>(@jmp_interaction_return)
	pha
	lda #<(@jmp_interaction_return)
	pha
	jmp (interaction_fn)				; jump to whatever the current screen defines
@jmp_interaction_return:
	nop

@return: 
	rts

.endif ; TICK_HANDLERS_ASM
