.ifndef MAP_ASM
MAP_ASM = 1

;==================================================
; load_map
;
; Loads map data
;
; void load_map(tile_file_name: u0,
;				tile_file_size: u1,
;				l0_map_file_name: u2,
;				l0_map_file_size: u3,
;				l1_map_file_name: u4,
;				l1_map_file_size: u5,
;				collision_map_file_name: u6,
;				collision_map_file_size: u7)
;==================================================
load_map:
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

rts

.endif ; MAP_ASM
