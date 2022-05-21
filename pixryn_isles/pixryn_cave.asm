.ifndef PIXRYN_CAVE_ASM
PIXRYN_CAVE_ASM = 1

;==================================================
; load_pixryn_cave
;
; void load_pixryn_cave()
;==================================================
load_pixryn_cave:

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
	; load one pixel smaller to avoid maps bleeding on edges
	LoadW map_width, 511
	LoadW map_height, 1023

	; initialize player location on screen
	LoadW xplayer, $0050
	LoadW yplayer, $00a8

	; initialize scroll variables
	LoadW xoff, $0000
	LoadW yoff, $0300

	LoadW u0, cave_l0_map_file
	LoadW u1, end_cave_l0_map_file-cave_l0_map_file
	jsr load_l0_map

	LoadW u0, cave_l1_map_file
	LoadW u1, end_cave_l1_map_file-cave_l1_map_file
	jsr load_l1_map

	LoadW u0, cave_collision_map_file
	LoadW u1, end_cave_collision_map_file-cave_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_cave_interaction_map_file
	LoadW u1, end_pixryn_cave_interaction_map_file-pixryn_cave_interaction_map_file
	jsr load_interaction_map

	; set the l0 tile mode
	lda #%01000011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_cave_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

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
; pixryn_cave_interaction_handler
;
; void pixryn_cave_interaction_handler()
;==================================================
pixryn_cave_interaction_handler:

; putting everything (except the symbol of this routine) into a proc means we
; don't have to worry about symbol collisions with other handlers
.proc PIXRYN_CAVE_INTERACTIONS

	lda u0L
	cmp #0
	beq @return

@return:
	rts

.endproc		; PIXRYN_CAVE_INTERACTIONS

.endif ; PIXRYN_CAVE_ASM
