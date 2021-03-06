.ifndef TICK_HANDLERS_ASM
TICK_HANDLERS_ASM = 1

.include "control.asm"
.include "interaction.asm"
.include "movement.asm"
.include "animation.asm"
.include "joystick.asm"

.segment "BSS"

; interaction function
interaction_fn:		.res 2

; tick function
tick_fn:		.res 2

.segment "CODE"

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
	jsr update_npcs
	jsr move
	lda #3
	jsr apply_scroll_offsets
	jsr set_player_tile
	jsr check_interactions

@control:
	jsr character_overworld_control

@music:
	jsr playmusic

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

;==================================================
; title_screen_tick
;
; Custom tick handler for the title screen
;
; void title_screen_tick()
;==================================================
title_screen_tick:
@music:
	jsr playmusic
	jsr update_joystick_data
	jsr title_screen_control

@return: 
	rts

.endif ; TICK_HANDLERS_ASM
