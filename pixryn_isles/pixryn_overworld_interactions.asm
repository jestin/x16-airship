.ifndef PIXRYN_OVERWORLD_INTERACTIONS_ASM
PIXRYN_OVERWORLD_INTERACTIONS_ASM = 1

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

	lda u0L
	cmp #$1
	bne :+
	jsr load_pixryn_tavern
	bra @return

:
	lda u0L
	cmp #$2
	bne :+
	jsr load_pixryn_home
	bra @return
:
	lda u0L
	cmp #$3
	bne :+
	lda #10
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$4
	bne :+
	lda #10
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$5
	bne :+
	lda #10
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$6
	bne :+
	lda #10
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$10
	bne :+
	lda #0					; campfire sign
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$11
	bne :+
	lda #1					; home sign
	jsr captured_message
	bra @return

:
	lda u0L
	cmp #$12
	bne :+
	lda #2					; tavern sign
	jsr captured_message
	bra :+
:
	lda u0L
	cmp #$13
	bne :+
	jsr trapdoor_to_cave
	bra :+

:	; end the b_button_interactions section with an unnamed label

; these interactions happen automatically by entering a tile, and do not
; require the user to hit any other buttons
@auto_interactions:

	lda u0L
	cmp #$7
	bne :+
	; jsr load_pixryn_tavern
	jsr fall_down_cave
	bra @return

:	; end the auto_interactions section with an unnamed label

@return:
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

	lda #3
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

	lda #4
	jsr captured_message

@return:
	rts

.endproc		; pixryn_overworld_interaction_handler

.endif ; PIXRYN_OVERWORLD_INTERACTIONS_ASM
