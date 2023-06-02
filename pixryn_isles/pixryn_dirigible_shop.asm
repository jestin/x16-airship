.ifndef PIXRYN_DIRIGIBLE_SHOP_ASM
PIXRYN_DIRIGIBLE_SHOP_ASM = 1

;==================================================
; load_pixryn_dirigible_shop
;
; void load_pixryn_dirigible_shop()
;==================================================
load_pixryn_dirigible_shop:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites
	jsr set_dcvideo

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; stop music
	jsr stopmusic

	; initialize map width and height
	LoadW map_width, 512
	LoadW map_height, 512

	; set the scroll layers
	lda #3
	sta map_scroll_layers

	; initialize player location on screen
	LoadW xplayer, $0090
	LoadW yplayer, $00a8

	; initialize scroll variables
	LoadW xoff, $0060
	LoadW yoff, $0070

	LoadW u0, pixryn_dirigible_shop_l0_map_file
	LoadW u1, end_pixryn_dirigible_shop_l0_map_file-pixryn_dirigible_shop_l0_map_file
	jsr load_l0_map

	LoadW u0, pixryn_dirigible_shop_l1_map_file
	LoadW u1, end_pixryn_dirigible_shop_l1_map_file-pixryn_dirigible_shop_l1_map_file
	jsr load_l1_map

	LoadW u0, pixryn_dirigible_shop_collision_map_file
	LoadW u1, end_pixryn_dirigible_shop_collision_map_file-pixryn_dirigible_shop_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_dirigible_shop_interaction_map_file
	LoadW u1, end_pixryn_dirigible_shop_interaction_map_file-pixryn_dirigible_shop_interaction_map_file
	jsr load_interaction_map

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	jsr use_overworld_irq_handler
	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_dirigible_shop_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

	; clear any NPC sprites from other maps
	jsr clear_npc_sprites
	jsr clear_npc_groups
	jsr clear_npc_paths

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
	jsr set_dcvideo

	; set player sprite
	ldx #player_sprite
	lda #(%00001000 | player_sprite_collision_mask)
	sprstore 6

	rts

;==================================================
; pixryn_dirigible_shop_interaction_handler
;
; void pixryn_dirigible_shop_interaction_handler()
;==================================================
.proc pixryn_dirigible_shop_interaction_handler

	lda interaction_id
	cmp #0
	beq @return

	cmp #1
	bne @return

	; on the dirigible_shop exit door, now check if they pressed B
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the button is currently down, and wasn't before
	bne @return

	jsr player_to_pixryn_dirigible_shop
	jsr load_pixryn

@return:
	rts

.endproc		; pixryn_dirigible_shop_interaction_handler

.endif ; PIXRYN_DIRIGIBLE_SHOP_ASM
