.ifndef AKOKO_OVERWORLD_INTERACTIONS_ASM
AKOKO_OVERWORLD_INTERACTIONS_ASM = 1

;==================================================
; akoko_overworld_interaction_handler
;
; void akoko_overworld_interaction_handler()
;==================================================
.proc akoko_overworld_interaction_handler

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


@return:
	lda #0
	rts

.endproc		; akoko_overworld_interaction_handler

.endif ; AKOKO_OVERWORLD_INTERACTIONS_ASM
