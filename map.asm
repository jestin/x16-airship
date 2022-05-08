.ifndef MAP_ASM
MAP_ASM = 1

;==================================================
; load_tiles
;
; Loads tile data
;
; void load_tiles(word tile_file_name: u0,
;					byte tile_file_size: u1)
;==================================================
load_tiles:

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
; Loads l1 map data
;
; void load_collision_map(word collision_map_file_name: u0,
;							byte collision_map_file_size: u1)
;==================================================
load_collision_map:

	; switch to the collision map bank
	lda #collision_map_data_bank
	sta $00

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
	ldx #<collision_map_data
	ldy #>collision_map_data
	jsr LOAD

	rts

;==================================================
; load_interaction_map
;
; Loads l1 map data
;
; void load_interaction_map(word interaction_map_file_name: u0,
;							byte interaction_map_file_size: u1)
;==================================================
load_interaction_map:

	; switch to the interaction map bank
	lda #interaction_map_data_bank
	sta $00

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
	ldx #<interaction_map_data
	ldy #>interaction_map_data
	jsr LOAD

	rts

;==================================================
; load_messages
;
; Loads l1 map data
;
; void load_messages(word message_file_name: u0,
;						byte message_file_size: u1)
;==================================================
load_messages:

	; switch to the map message bank
	lda #map_message_data_bank
	sta $00

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
	ldx #<map_message_lookup
	ldy #>map_message_lookup
	jsr LOAD

	rts

;==================================================
; load_palette
;
; Loads l1 map data
;
; void load_palette(word palette_file_name: u0,
;					byte palette_file_size: u1)
;==================================================
load_palette:

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u0L
	ldy u0H
	jsr SETNAM
	lda #(^vram_palette + 2)
	ldx #<vram_palette
	ldy #>vram_palette
	jsr LOAD

	rts

.endif ; MAP_ASM
