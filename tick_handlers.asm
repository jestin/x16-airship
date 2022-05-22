.ifndef TICK_HANDLERS_ASM
TICK_HANDLERS_ASM = 1

;==================================================
; character_overworld_tick
;
; Custom tick handler for the character overworld
; map.
;
; void character_overworld_tick()
;==================================================
character_overworld_tick:

	jsr update_joystick_data
	jsr animate_map

	; check if player can move
	lda player_status
	bit #%00000001
	bne @control

	jsr animate_player
	jsr move
	lda #3
	jsr apply_scroll_offsets
	jsr set_player_tile
	jsr check_interactions

@control:
	jsr character_overworld_control

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
