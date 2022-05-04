.ifndef MAP_ASM
MAP_ASM = 1

;==================================================
; load_map
;
; Loads map data
;
; void load_map(word tile_file_name: u0,
;				byte tile_file_size: u1,
;				word l0_map_file_name: u2,
;				byte l0_map_file_size: u3,
;				word l1_map_file_name: u4,
;				byte l1_map_file_size: u5,
;				word collision_map_file_name: u6,
;				byte collision_map_file_size: u7,
;				word interaction_map_file_name: u8,
;				byte interaction_map_file_size: u9,
;				word message_file_name: u10,
;				byte message_file_size: u11,
;				word pal_file_name: u12,
;				byte pal_file_size: u13)
;==================================================
load_map:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites and l0 enabled
	sta veradcvideo

	; load the palette first so that the text sprites look okay
@set_palette:

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u13
	ldx u12L
	ldy u12H
	jsr SETNAM
	lda #(^vram_palette + 2)
	ldx #<vram_palette
	ldy #>vram_palette
	jsr LOAD


	; push u0 - u4 to the stack
	lda u0L
	pha
	lda u0H
	pha
	lda u1L
	pha
	lda u1H
	pha
	lda u2L
	pha
	lda u2H
	pha
	lda u3L
	pha
	lda u3H
	pha
	lda u4L
	pha
	lda u4H
	pha

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; pull u0 - u4 from the stack
	pla
	sta u4H
	pla
	sta u4L
	pla
	sta u3H
	pla
	sta u3L
	pla
	sta u2H
	pla
	sta u2L
	pla
	sta u1H
	pla
	sta u1L
	pla
	sta u0H
	pla
	sta u0L

@load_tiles:

	; read tile file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_tile_data + 2)
	ldx #<vram_tile_data
	ldy #>vram_tile_data
	jsr LOAD

	; read l0 tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u3
	ldx u2L
	ldy u2H
	jsr SETNAM
	lda #(^vram_l0_map_data + 2)
	ldx #<vram_l0_map_data
	ldy #>vram_l0_map_data
	jsr LOAD

	; read l1 tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u5
	ldx u4L
	ldy u4H
	jsr SETNAM
	lda #(^vram_l1_map_data + 2)
	ldx #<vram_l1_map_data
	ldy #>vram_l1_map_data
	jsr LOAD

	; switch to the collision map bank
	lda #collision_map_data_bank
	sta $00

	; read collision tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u7
	ldx u6L
	ldy u6H
	jsr SETNAM
	lda #0
	ldx #<collision_map_data
	ldy #>collision_map_data
	jsr LOAD

	; switch to the interaction map bank
	lda #interaction_map_data_bank
	sta $00

	; read interaction tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u9
	ldx u8L
	ldy u8H
	jsr SETNAM
	lda #0
	ldx #<interaction_map_data
	ldy #>interaction_map_data
	jsr LOAD

	; check if there are messages to load
	lda u10L
	ora u10H
	beq @set_layers					; both bytes of u10 are 0, which would not be a valid place to store a filename

	; switch to the map message bank
	lda #map_message_data_bank
	sta $00

	; read messages file
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u11
	ldx u10L
	ldy u10H
	jsr SETNAM
	lda #0
	ldx #<map_message_lookup
	ldy #>map_message_lookup
	jsr LOAD

@set_layers:
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

@return:

	LoadW u0, message_sprites
	jsr clear_text_sprites

	rts

.endif ; MAP_ASM
