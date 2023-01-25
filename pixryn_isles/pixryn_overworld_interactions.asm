.ifndef PIXRYN_OVERWORLD_INTERACTIONS_ASM
PIXRYN_OVERWORLD_INTERACTIONS_ASM = 1

.include "messages.inc"

;==================================================
; pixryn_overworld_interaction_handler
;
; void pixryn_overworld_interaction_handler()
;==================================================
.proc pixryn_overworld_interaction_handler

	; check if the b button was pressed
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the b button is currently down, and wasn't before
	bne @auto_interactions

	; NOTE: We are using unnamed labels here so that we don't care which
	; section is which.  When the condition doesn't hit, we just advance to the
	; next label.  This allows us to reorder these handlers without recoding
	; them.

; these interactions only trigger when the user has pressed the b button on the tile
@b_button_interactions:
	jsr button_interactions
	cmp #0
	bne @return


; these interactions happen automatically by entering a tile, and do not
; require the user to hit any other buttons
@auto_interactions:

	lda interaction_id
	cmp #$7
	bne :+
	; jsr load_pixryn_tavern
	jsr fall_down_cave
	bra @return

:	; end the auto_interactions section with an unnamed label

@return:
	rts

;==================================================
; button_interactions
;
; Interactions that require a button to initiate.
; If it returns non-zero, stop checking all other
; interactions.
;
; void button_interactions(
;					out byte return_immediate: A)
;==================================================
button_interactions:

	lda interaction_id
	cmp #$1
	bne :+
	jsr load_pixryn_tavern
	lda #1
	rts
:
	lda interaction_id
	cmp #$2
	bne :+
	jsr load_pixryn_home
	lda #1
	rts
:
	lda interaction_id
	cmp #$3
	bne :+
	jsr load_pixryn_dirigible_shop
	lda #1
	rts
:
	lda interaction_id
	cmp #$4
	bne :+
	lda #PI_locked_door
	jsr captured_message
	lda #1
	rts
:
	lda interaction_id
	cmp #$5
	bne :+
	lda #PI_locked_door
	jsr captured_message
	lda #1
	rts
:
	lda interaction_id
	cmp #$6
	bne :+
	lda #PI_locked_door
	jsr captured_message
	lda #1
	rts
:
	lda interaction_id
	cmp #$10
	bne :+
	lda #PI_campfire_sign
	jsr captured_message
	lda #1
	rts
:
	lda interaction_id
	cmp #$11
	bne :+
	lda #PI_welcome_1
	ldx #8
	ldy #2
	jsr message_dialog
	lda #1
	rts
:
	lda interaction_id
	cmp #$12
	bne :+
	lda #PI_tavern_sign
	jsr captured_message
	bra :+
:
	lda interaction_id
	cmp #$13
	bne :+
	jsr trapdoor_to_cave
	bra :+
:
	lda interaction_id
	cmp #$14
	bne :+
	lda #PI_wheres_grandma
	jsr captured_message
	bra :+
:
	lda interaction_id
	cmp #$15
	bne :+
	lda #PI_dagnols_sign_1
	ldx #5
	ldy #1
	jsr message_dialog
	bra :+

:	; end the b_button_interactions section with an unnamed label

@return:
	lda #0
	rts

;==================================================
; fall_down_cave
;==================================================
fall_down_cave:

	jsr load_pixryn_cave
	jsr player_to_cave_entrance

	; Call a tick directly so that the user doesn't see the map loaded, but the
	; player unpositioned
	jsr pixryn_cave_tick_handler

	lda #PI_fell_down_cave
	jsr captured_message

@return:
	rts

;==================================================
; trapdoor_to_cave
;==================================================
trapdoor_to_cave:

	lda #0
	sta playerdir
	jsr load_pixryn_cave
	jsr player_to_field_ladder

	; Call a tick directly so that the user doesn't see the map loaded, but the
	; player unpositioned
	jsr pixryn_cave_tick_handler

	lda #PI_found_a_trapdoor
	jsr captured_message

@return:
	rts

.endproc		; pixryn_overworld_interaction_handler

.endif ; PIXRYN_OVERWORLD_INTERACTIONS_ASM
