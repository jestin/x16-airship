.ifndef MAP_ASM
MAP_ASM = 1

.segment "BSS"

map_id:				.res 1
map_width:			.res 2
map_height:			.res 2
map_scroll_layers:	.res 1

.segment "CODE"

;==================================================
; initialize_map_memory
;
; void initialize_map_memory()
;==================================================
initialize_map_memory:
	stz map_id
	stz map_width
	stz map_height
	stz map_scroll_layers

	rts

;==================================================
; load_tiles
;
; Loads tile data
;
; void load_tiles(word tile_file_name: u0,
;					byte tile_file_size: u1)
;==================================================
load_tiles:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_tile_data + 2)
	ldx #<vram_tile_data
	ldy #>vram_tile_data
	jsr LOAD

	rts

;==================================================
; load_l0_map
;
; Loads l0 map data
;
; void load_l0_map(word map_file_name: u0,
;				byte map_file_size: u1)
;==================================================
load_l0_map:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_l0_map_data + 2)
	ldx #<vram_l0_map_data
	ldy #>vram_l0_map_data
	jsr LOAD

	rts

;==================================================
; load_l1_map
;
; Loads l1 map data
;
; void load_l1_map(word map_file_name: u0,
;				byte map_file_size: u1)
;==================================================
load_l1_map:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_l1_map_data + 2)
	ldx #<vram_l1_map_data
	ldy #>vram_l1_map_data
	jsr LOAD

	rts

;==================================================
; load_collision_map
;
; Loads collision map
;
; void load_collision_map(word collision_map_file_name: u0,
;							byte collision_map_file_size: u1)
;==================================================
load_collision_map:

	; switch to the collision map bank
	lda #collision_map_data_bank
	sta $00

	; set ROM bank to KERNAL
	lda #0
	sta $01

	; read collision tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
	jsr LOAD

	rts

;==================================================
; load_interaction_map
;
; Loads interaction map
;
; void load_interaction_map(word interaction_map_file_name: u0,
;							byte interaction_map_file_size: u1)
;==================================================
load_interaction_map:

	; switch to the interaction map bank
	lda #interaction_map_data_bank
	sta $00

	; set ROM bank to KERNAL
	lda #0
	sta $01

	; read interaction tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
	jsr LOAD

	rts

;==================================================
; load_messages
;
; Loads messages
;
; void load_messages(word message_file_name: u0,
;						byte message_file_size: u1)
;==================================================
load_messages:

	; switch to the map message bank
	lda #map_message_data_bank
	sta $00

	; set ROM bank to KERNAL
	lda #0
	sta $01

	; read messages file
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
	jsr LOAD

	rts

;==================================================
; load_palette
;
; Loads palette
;
; void load_palette(word palette_file_name: u0,
;					byte palette_file_size: u1)
;==================================================
load_palette:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_palette + 2)
	ldx #<vram_palette
	ldy #>vram_palette
	jsr LOAD

;==================================================
; load_player_sprites
;
; Loads player sprites
;
; void load_player_sprites(word palette_file_name: u0,
;					byte palette_file_size: u1)
;==================================================
load_player_sprites:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_player_sprites + 2)
	ldx #<vram_player_sprites
	ldy #>vram_player_sprites
	jsr LOAD

	rts
	
;==================================================
; cache_map_in_hi_mem
;
; Cache the overworld map data into hi ram banks
;
; Expects the VERA address to already be set
;
; void cache_map_in_hi_mem(byte bank1: x, byte bank2, y)
;==================================================
cache_map_in_hi_mem:

	stx $00

	LoadW u0, hi_mem
@bank_1_loop:
	lda u0H
	cmp #>(hi_mem+$2000)
	beq @bank_1_loaded
	lda veradat
	sta (u0)
	IncW u0
	bra @bank_1_loop

@bank_1_loaded:
	sty $00

	LoadW u0, hi_mem
@bank_2_loop:
	lda u0H
	cmp #>(hi_mem+$2000)
	beq @return
	lda veradat
	sta (u0)
	IncW u0
	bra @bank_2_loop

@return:
	rts

;==================================================
; load_map_from_cache
;
; Load the overworld cache from hi ram
;
; Expects the VERA address to already be set
;
; void load_map_from_cache(byte bank1: x, byte bank2, y)
;==================================================
load_map_from_cache:

	stx $00

	LoadW u0, hi_mem
@bank_1_loop:
	lda u0H
	cmp #>(hi_mem+$2000)
	beq @bank_1_loaded
	lda (u0)
	sta veradat
	IncW u0
	bra @bank_1_loop

@bank_1_loaded:
	sty $00

	LoadW u0, hi_mem
@bank_2_loop:
	lda u0H
	cmp #>(hi_mem+$2000)
	beq @return
	lda (u0)
	sta veradat
	IncW u0
	bra @bank_2_loop

@return:
	rts

.endif ; MAP_ASM
