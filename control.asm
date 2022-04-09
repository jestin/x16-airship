.ifndef CONTROL_ASM
CONTROL_ASM = 1

;==================================================
; character_overworld_control
;
; Handles UI interactions while the player is in
; character overword mode.
;
; void character_overworld_control()
;==================================================
character_overworld_control:

	; check if they are reading message text
	lda player_status
	bit #%00000010
	beq @return
	jsr reading_message_control

@return:
	rts

;==================================================
; reading_message_control
;
; Handles the player's UI choices while reading
; text from the screen.
;
; void reading_message_control()
;==================================================
reading_message_control:

	; check if the button was pushed
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return

	; here we need to turn off the sprites in the message and allow the user to move again

	lda player_status
	and #%11111100
	sta player_status

	; disable message sprites
	LoadW u0, message_sprites
@disable_sprite_loop:
	lda (u0)
	cmp #$80
	bcs @end_disable_sprite_loop
	tax
	lda #0
	sprstore 6
	IncW u0
	bra @disable_sprite_loop
@end_disable_sprite_loop:

@return:
	rts

.endif ; CONTROL_ASM
