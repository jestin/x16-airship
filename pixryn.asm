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

	; read tile file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_pixryn_tile_file-pixryn_tile_file)
	ldx #<pixryn_tile_file
	ldy #>pixryn_tile_file
	jsr SETNAM
	lda #(^vram_tile_data + 2)
	ldx #<vram_tile_data
	ldy #>vram_tile_data
	jsr LOAD

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_pixryn_l0_map_file-pixryn_l0_map_file)
	ldx #<pixryn_l0_map_file
	ldy #>pixryn_l0_map_file
	jsr SETNAM
	lda #(^vram_l0_map_data + 2)
	ldx #<vram_l0_map_data
	ldy #>vram_l0_map_data
	jsr LOAD

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_pixryn_l1_map_file-pixryn_l1_map_file)
	ldx #<pixryn_l1_map_file
	ldy #>pixryn_l1_map_file
	jsr SETNAM
	lda #(^vram_l1_map_data + 2)
	ldx #<vram_l1_map_data
	ldy #>vram_l1_map_data
	jsr LOAD

	; read collision tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_pixryn_collision_map_file-pixryn_collision_map_file)
	ldx #<pixryn_collision_map_file
	ldy #>pixryn_collision_map_file
	jsr SETNAM
	lda #0
	ldx #<collision_map_data
	ldy #>collision_map_data
	jsr LOAD

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

	; read tile file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_interior_tile_file-interior_tile_file)
	ldx #<interior_tile_file
	ldy #>interior_tile_file
	jsr SETNAM
	lda #(^vram_tile_data + 2)
	ldx #<vram_tile_data
	ldy #>vram_tile_data
	jsr LOAD

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tavern_l0_map_file-tavern_l0_map_file)
	ldx #<tavern_l0_map_file
	ldy #>tavern_l0_map_file
	jsr SETNAM
	lda #(^vram_l0_map_data + 2)
	ldx #<vram_l0_map_data
	ldy #>vram_l0_map_data
	jsr LOAD

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tavern_l1_map_file-tavern_l1_map_file)
	ldx #<tavern_l1_map_file
	ldy #>tavern_l1_map_file
	jsr SETNAM
	lda #(^vram_l1_map_data + 2)
	ldx #<vram_l1_map_data
	ldy #>vram_l1_map_data
	jsr LOAD

	rts

.endif ; PIXRYN_ASM
