.ifndef CONTROL_ASM
CONTROL_ASM = 1

.include "pixryn_isles/pixryn.asm"
.include "akoko_mountains/akoko.asm"

.segment "CODE"

;==================================================
; character_overworld_control
;
; Handles UI interactions while the player is in
; character overword mode.
;
; void character_overworld_control()
;==================================================
character_overworld_control:

	; check if they are viewing a dialog
	lda player_status
	bit #player_status_reading_dialog
	beq :+
	jsr dialog_control
	bra @return
:
	; check if they are reading message text
	lda player_status
	bit #player_status_reading_text
	beq :+
	jsr reading_message_control
:
@return:
	rts

;==================================================
; title_screen_control
;
; Handles the UI interactions while on the title
; screen
;
; void title_screen_control()
;==================================================
title_screen_control:

	lda joystick_data
	eor $ff
	and joystick_changed_data
	cmp #joystick_0_STA				; checks if the button is currently down, and wasn't before
	bne @return

	; disable message sprites
	LoadW u0, message_sprites
	jsr clear_text_sprites

	jsr player_to_pixryn_home
	jsr load_pixryn
	; jsr player_to_akoko_home
	; jsr load_akoko

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
	cmp #joystick_0_B				; checks if the button is currently down, and wasn't before
	bne @return

	; here we need to turn off the sprites in the message and allow the user to move again

	lda player_status
	and #!(player_status_reading_text | player_status_unable_to_move)
	sta player_status

	; disable message sprites
	LoadW u0, message_sprites
	jsr clear_text_sprites

@return:
	rts

;==================================================
; dialog_control
;
; Handles the player's UI choices while reading
; text from a dialog
;
; void dialog_control()
;==================================================
dialog_control:

	; check if the button was pushed
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #joystick_0_B				; checks if the button is currently down, and wasn't before
	bne @return

	; advance the page and check if it is already on the last page
	inc cur_dialog_page
	lda cur_dialog_page
	cmp dialog_pages
	bcc @advance_page

	lda player_status
	and #!(player_status_reading_dialog | player_status_unable_to_move)
	sta player_status
	bra @return

@advance_page:
	jsr clear_dialog_message
	ldx messages_per_dialog_page
	jsr display_dialog_page

@return:
	rts

.endif ; CONTROL_ASM
