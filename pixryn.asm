.ifndef PIXRYN_ASM

.include "pixryn_overworld_interactions.asm"

PIXRYN_ASM = 1

;==================================================
; load_pixryn
;
; void load_pixryn()
;==================================================
load_pixryn:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites and l0 enabled
	sta veradcvideo

	; load palette first so that the loading message is correct
	LoadW u0, pixryn_pal_file
	LoadW u1, end_pixryn_pal_file-pixryn_pal_file
	jsr load_palette

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; initialize map width and height
	LoadW map_width, 2048
	LoadW map_height, 1024

	LoadW u0, pixryn_tile_file
	LoadW u1, end_pixryn_tile_file-pixryn_tile_file
	jsr load_tiles

	LoadW u0, pixryn_l0_map_file
	LoadW u1, end_pixryn_l0_map_file-pixryn_l0_map_file
	jsr load_l0_map

	LoadW u0, pixryn_l1_map_file
	LoadW u1, end_pixryn_l1_map_file-pixryn_l1_map_file
	jsr load_l1_map

	LoadW u0, pixryn_collision_map_file
	LoadW u1, end_pixryn_collision_map_file-pixryn_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_interaction_map_file
	LoadW u1, end_pixryn_interaction_map_file-pixryn_interaction_map_file
	jsr load_interaction_map

	LoadW u0, pixryn_message_file
	LoadW u1, end_pixryn_message_file-pixryn_message_file
	jsr load_messages

	; set the l0 tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

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

	; set player sprite
	ldx #player_sprite
	lda #%00001000
	sprstore 6

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo


	rts

;==================================================
; player_to_pixryn_tavern
;
; void player_to_pixryn_tavern()
;==================================================
player_to_pixryn_tavern:

	; initialize player location on screen
	LoadW xplayer, $00ac
	LoadW yplayer, $0048

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
; load_pixryn_tavern
;
; void load_pixryn_tavern()
;==================================================
load_pixryn_tavern:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites and l0 enabled
	sta veradcvideo

	; load palette first so that the loading message is correct
	LoadW u0, pixryn_pal_file
	LoadW u1, end_pixryn_pal_file-pixryn_pal_file
	jsr load_palette

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
	LoadW xplayer, $00b0
	LoadW yplayer, $0080

	LoadW u0, interior_tile_file
	LoadW u1, end_interior_tile_file-interior_tile_file
	jsr load_tiles

	LoadW u0, tavern_l0_map_file
	LoadW u1, end_tavern_l0_map_file-tavern_l0_map_file
	jsr load_l0_map

	LoadW u0, tavern_l1_map_file
	LoadW u1, end_tavern_l1_map_file-tavern_l1_map_file
	jsr load_l1_map

	LoadW u0, tavern_collision_map_file
	LoadW u1, end_tavern_collision_map_file-tavern_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_tavern_interaction_map_file
	LoadW u1, end_pixryn_tavern_interaction_map_file-pixryn_tavern_interaction_map_file
	jsr load_interaction_map

	; initialize scroll variables
	LoadW xoff, $0070
	LoadW yoff, $0070

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_tavern_interaction_handler

	; always clear anim_tiles_count
	stz anim_tiles_count

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


	; set player sprite
	ldx #player_sprite
	lda #%00001000
	sprstore 6

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

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
