.ifndef PIXRYN_ASM
PIXRYN_ASM = 1
;==================================================
; load_pixryn
;
; void load_pixryn()
;==================================================
load_pixryn:

	; initialize map width and height
	LoadW map_width, 2048
	LoadW map_height, 1024

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW u0, pixryn_tile_file
	LoadW u1, end_pixryn_tile_file-pixryn_tile_file

	LoadW u2, pixryn_l0_map_file
	LoadW u3, end_pixryn_l0_map_file-pixryn_l0_map_file

	LoadW u4, pixryn_l1_map_file
	LoadW u5, end_pixryn_l1_map_file-pixryn_l1_map_file

	LoadW u6, pixryn_collision_map_file
	LoadW u7, end_pixryn_collision_map_file-pixryn_collision_map_file

	LoadW u8, pixryn_interaction_map_file
	LoadW u9, end_pixryn_interaction_map_file-pixryn_interaction_map_file

	jsr load_map

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_overworld_interaction_handler

	; always clear anim_tiles_count
	stz anim_tiles_count

	; manually setup the animated tiles for the map
	lda #1
	sta u0L
	jsr add_animated_tile
	lda #74
	sta u0L
	jsr add_animated_tile
	lda #213
	sta u0L
	jsr add_animated_tile

	rts

;==================================================
; player_to_pixryn_tavern
;
; void player_to_pixryn_tavern()
;==================================================
player_to_pixryn_tavern:

	; initialize player location on screen
	LoadW xplayer, $00ac
	LoadW yplayer, $0040

	; initialize scroll variables
	LoadW xoff, $0144
	LoadW yoff, $0000

	rts

;==================================================
; player_to_pixryn_home
;
; void player_to_pixryn_home()
;==================================================
player_to_pixryn_home:

	; initialize player location on screen
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0144
	LoadW yoff, $00bf

	rts

;==================================================
; pixryn_overworld_interaction_handler
;
; void pixryn_overworld_interaction_handler()
;==================================================
pixryn_overworld_interaction_handler:

	lda u0L
	cmp #0
	beq @return

	cmp #$1
	bne @campfire_sign

	; on the tavern door, now check if they pressed B
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return
	jsr load_pixryn_tavern

@campfire_sign:
	cmp #$10
	bne @return

	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return
	LoadW u0, test_string
	LoadW u1, 100
	LoadW u2, 100
	LoadW u3, message_sprites
	jsr draw_string					; draw message text
	lda player_status				; set the player status to restrained and reading
	ora #%00000011
	sta player_status

@return:
	rts

;==================================================
; load_pixryn_tavern
;
; void load_pixryn_tavern()
;==================================================
load_pixryn_tavern:
	; initialize map width and height
	LoadW map_width, 512
	LoadW map_height, 512

	; initialize player location on screen
	LoadW xplayer, $00b0
	LoadW yplayer, $0080

	; initialize scroll variables
	LoadW xoff, $0070
	LoadW yoff, $0070

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW u0, interior_tile_file
	LoadW u1, end_interior_tile_file-interior_tile_file

	LoadW u2, tavern_l0_map_file
	LoadW u3, end_tavern_l0_map_file-tavern_l0_map_file

	LoadW u4, tavern_l1_map_file
	LoadW u5, end_tavern_l1_map_file-tavern_l1_map_file

	LoadW u6, tavern_collision_map_file
	LoadW u7, end_tavern_collision_map_file-tavern_collision_map_file

	LoadW u8, pixryn_tavern_interaction_map_file
	LoadW u9, end_pixryn_tavern_interaction_map_file-pixryn_tavern_interaction_map_file

	jsr load_map

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_tavern_interaction_handler

	; always clear anim_tiles_count
	stz anim_tiles_count

	rts

;==================================================
; pixryn_tavern_interaction_handler
;
; void pixryn_tavern_interaction_handler()
;==================================================
pixryn_tavern_interaction_handler:

	lda u0L
	cmp #0
	beq @return

	cmp #1
	bne @return

	; on the tavern exit door, now check if they pressed B
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return

	jsr player_to_pixryn_tavern
	jsr load_pixryn

@return:
	rts
.endif ; PIXRYN_ASM
