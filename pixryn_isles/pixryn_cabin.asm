.ifndef PIXRYN_CABIN_ASM
PIXRYN_CABIN_ASM = 1

;==================================================
; load_pixryn_cabin
;
; void load_pixryn_cabin()
;==================================================
load_pixryn_cabin:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites
	sta veradcvideo

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; initialize map width and height
	LoadW map_width, 512
	LoadW map_height, 512

	; initialize player location on screen
	LoadW xplayer, $0090
	LoadW yplayer, $00a8

	; initialize scroll variables
	LoadW xoff, $0090
	LoadW yoff, $0050

	LoadW u0, cabin_l0_map_file
	LoadW u1, end_cabin_l0_map_file-cabin_l0_map_file
	jsr load_l0_map

	LoadW u0, cabin_l1_map_file
	LoadW u1, end_cabin_l1_map_file-cabin_l1_map_file
	jsr load_l1_map

	LoadW u0, cabin_collision_map_file
	LoadW u1, end_cabin_collision_map_file-cabin_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_cabin_interaction_map_file
	LoadW u1, end_pixryn_cabin_interaction_map_file-pixryn_cabin_interaction_map_file
	jsr load_interaction_map

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_cabin_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

	; manually setup the animated tiles for the map
	lda #74
	sta u0L
	jsr add_animated_tile

 	; set the tile base address
	lda #(<(vram_tile_data >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	sta veral1tilebase

	; set the l0 tile map base address
	lda #<(vram_l0_map_data >> 9)
	sta veral0mapbase

	; set the l1 tile map base address
	lda #<(vram_l1_map_data >> 9)
	sta veral1mapbase

	; clear loading message
	LoadW u0, message_sprites
	jsr clear_text_sprites

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	; set player sprite
	ldx #player_sprite
	lda #%00001000
	sprstore 6

	rts

;==================================================
; pixryn_cabin_interaction_handler
;
; void pixryn_cabin_interaction_handler()
;==================================================
pixryn_cabin_interaction_handler:

; putting everything (except the symbol of this routine) into a proc means we
; don't have to worry about symbol collisions with other handlers
.proc PIXRYN_CABIN_INTERACTIONS

	lda u0L
	cmp #0
	beq @return

	cmp #1
	bne @return

	; on the cabin exit door, now check if they pressed B
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return

	jsr player_to_pixryn_cabin
	jsr load_pixryn

@return:
	rts

.endproc		; PIXRYN_CABIN_INTERACTIONS

.endif ; PIXRYN_CABIN_ASM
