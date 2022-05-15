.ifndef PIXRYN_OVERWORLD_INTERACTIONS_ASM
PIXRYN_OVERWORLD_INTERACTIONS_ASM = 1

;==================================================
; pixryn_overworld_interaction_handler
;
; void pixryn_overworld_interaction_handler()
;==================================================
pixryn_overworld_interaction_handler:

; putting everything (except the symbol of this routine) into a proc means we
; don't have to worry about symbol collisions with other handlers
.proc PIXRYN_OVERWORD_INTERACTIONS

	lda u0L
	cmp #0
	beq @return

	; check if the b button was pressed
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
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
	cmp #$10
	bne :+
	jsr campfire_sign
	bra @return

:
	lda u0L
	cmp #$11
	bne :+
	jsr home_sign
	bra @return

:
	lda u0L
	cmp #$12
	bne @return
	jsr tavern_sign
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
; campfire_sign
;==================================================
campfire_sign:

	lda #0
	jsr show_message

	lda player_status				; set the player status to restrained and reading
	ora #%00000011
	sta player_status

@return:
	rts

;==================================================
; home_sign
;==================================================
home_sign:

	lda #1
	jsr show_message

	lda player_status				; set the player status to restrained and reading
	ora #%00000011
	sta player_status

@return:
	rts
;==================================================
; home_sign
;==================================================
tavern_sign:

	lda #2
	jsr show_message

	lda player_status				; set the player status to restrained and reading
	ora #%00000011
	sta player_status

@return:
	rts

;==================================================
; fall_down_cave
;==================================================
fall_down_cave:

	; TODO: create a cave map and use it here
	jsr load_pixryn_tavern

	; Call a tick directly so that the user doesn't see the map loaded, but the
	; player unpositioned
	jsr character_overworld_tick

	lda #3
	jsr show_message

	lda player_status				; set the player status to restrained and reading
	ora #%00000011
	sta player_status

@return:
	rts

.endproc		; PIXRYN_OVERWORD_INTERACTIONS

.endif ; PIXRYN_OVERWORLD_INTERACTIONS_ASM
