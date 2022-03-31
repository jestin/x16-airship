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

	; initialize player location on screen
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0144
	LoadW yoff, $00bf

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
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0000
	LoadW yoff, $0000

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

	jsr load_map

	rts

.endif ; PIXRYN_ASM
