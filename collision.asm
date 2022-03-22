.ifndef COLLISION_ASM
COLLISION_ASM = 1

;==================================================
; check_collisions
;
; This should be called after movement is
; calculated, but before it is applied. It will
; indicate whether the calculation should be
; applied.
; 0 - don't apply
; 1 - apply
;
; void check_collisions(out apply: A)
;==================================================
check_collisions:
	jsr construct_collision_tile

	lda #1
@return:
	rts

;==================================================
; construct_collision_tile
; Create a 16x16 tile of collision map from the
; space occupied by the player sprite.
;
; void construct_collision_tile()
;==================================================
construct_collision_tile:

	; Before anything else, we should calculate the player's xy map location
	clc
	lda xplayer
	adc xoff
	sta u0L
	lda xplayer+1
	adc xoff+1
	sta u0H

	clc
	lda yplayer
	adc yoff
	sta u1L
	lda yplayer+1
	adc yoff+1
	sta u1H

	; First, load the 4 relevant tiles into our collision tile memory
	ldx #0
@construct_tile_loop:
	clc
	lda #<(collision_map_data)
	adc active_tile
	sta u2L
	lda #>(collision_map_data)
	adc active_tile+1
	sta u2H

	jsr calculate_collision_tile_address

	; u2 now holds the address of the relevant tile on the collision tilemap
	; NOTE: unlike VERA tilemaps, collision tilemaps are a single byte per tile

	; load the index of the correct collision tile and multiply by 32 (bytes
	; per tile)
	LoadW u3, 0						; zero out u3
	lda (u2)
	sta u3							; store in u3 to perform shift
	AslW u3							; 5 left shifts multiplies by 32
	AslW u3
	AslW u3
	AslW u3
	AslW u3
	clc
	lda u3L							; add u3 to tile data address, store back in u3
	adc #<(collision_tile_data)
	sta u3L
	lda u3H
	adc #>(collision_tile_data)
	sta u3H

	; u3 now contains the address of the correct tile

	; load the base address of the constructed collision tile into u4
	LoadW u4, construct_tile

	; add X*32
	txa
	asl
	asl
	asl
	asl
	asl
	clc
	adc u4L
	sta u4L
	lda #0
	adc u4H
	sta u4H

	; u4 now contains the address of the current construct collision tile

	; copy the tile
	ldy #0
@copy_loop:
	clc
	lda (u3),y
	sta (u4),y
	iny
	cpy #32							; 16px*16px*1bpp = 32 bytes
	bcc @copy_loop
@copy_loop_end:

	inx
	cpx #4
	bcc @construct_tile_loop
@construct_tile_loop_end:

@return:
	rts

;==================================================
; calculate_collision_tile_address
; Create a 16x16 tile of collision map from the
; space occupied by the player sprite.
;
; void calculate_collision_tile_address(
;							tile_number: x
;							active_tile_address: u2,
;							out collision_tile_index_address: u2)
;==================================================
calculate_collision_tile_address:
	; if X == 0 || X == 1, add X to the active tile address
	; if X == 2, add map_width/16; if X = 3, add (map_width/16)+1
	cpx #2
	bcs @add_map_width				; use this case for both X==2 and x==3

	; add X to the active tile address
	txa								; multiply by 32
	clc
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H

	bra @return

@add_map_width:

	; add (map_width/16)*32 to the active tile address (u3 as scratch pad)
	lda map_width
	sta u3L
	lda map_width+1
	sta u3H

	; divide by 16 to be a tile count instead of a pixel count
	LsrW u3
	LsrW u3
	LsrW u3
	LsrW u3

	cpx #3
	bne @add_offset

	IncW u3

@add_offset:
	clc
	lda u3L
	adc u2L
	sta u2L
	lda u3H
	adc u2H
	sta u2H

@return:
	rts

.endif ; COLLISION_ASM
