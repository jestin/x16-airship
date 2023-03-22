.ifndef COLLISION_ASM
COLLISION_ASM = 1

.segment "BSS"

; for 32 16x16 1bpp tiles this takes $800 bytes
collision_tile_data:		.res $800

; for the single constructed collision tile to be compared against the player
; this is stored in $20 bytes, but will take $80 to calculate
construct_tile:		.res $80

; player collision tile
player_collision_tile:		.res 32

.segment "CODE"

;==================================================
; initialize_collision_memory
;
; void initialize_collision_memory()
;==================================================
initialize_collision_memory:

	rts
;==================================================
; check_collisions
;
; This should be called after movement is
; calculated, but before it is applied. It will
; indicate whether the collision should be applied.
;
; 0 - don't apply
; 1 - apply
;
; void check_collisions(out apply: A)
;==================================================
check_collisions:
	jsr construct_collision_tile

	; loop backwards to save cycles comparing loop counter
	ldy #32
@collision_loop:

	; we need to subtract 2 and 1 to get to the correct bytes, since our loop
	; counter starts at the length of the data
	lda player_collision_tile-2,y
	sta u0L
	lda player_collision_tile-1,y
	sta u0H
	lda construct_tile-2,y
	sta u1L
	lda construct_tile-1,y
	sta u1H
	jsr check_row
	bne @collision

	dey		; decrement by 2
	dey
	bpl @collision_loop
@end_collision_loop:

	lda #1
	rts

@collision:
	lda #0
	rts

;==================================================
; check_row
; sets Z if no collision
;
; void check_row(word player_tile_row: u0,
;				word collision_tile_row: u1)
;==================================================
check_row:
	; left
	lda u0L
	and u1L
	cmp #0
	bne @return	; return early
	; right
	lda u0H
	and u1H
	cmp #0

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

	; switch to the collsion map bank of RAM
	lda #collision_map_data_bank
	sta $00

	; keep track of whether all 4 tiles are index 0
	stz u5L

	; First, load the 4 relevant tiles into our collision tile memory
	ldx #0
@populate_pad_loop:
	clc
	lda #<(hi_mem)
	adc active_tile
	sta u2L
	lda #>(hi_mem)
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
	ora u5L
	sta u5L
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
	bcc @populate_pad_loop
@populate_pad_loop_end:

	; if u5L is zero, that means each tile is the empty tile
	lda u5L
	bne :+
	rts

:

	; Now that we have populated the 4-tile "pad", we need to shift the correct
	; bits into the first tile.  This is the only tile that will be compared
	; against.  The lowest nibbles of u0 and u1 contain how far the tiles need
	; to be shifted.

	; shift X first, which will be simply be bit shifts

	lda u0L							; Move lower nibble of u0 into X
	and #$0f
	tax

@left_shift_loop:
	; each pass shifts the bits left once
	cpx #0
	beq @end_left_shift_loop

	; since we no longer need it, use u2L as a index counter
	lda u1L
	and #$0f						; skip the rows that will be shifted up off the final tile
	sta u2L

	lda #0
	sta u5L							; count how many passes we go through the loop
@row_shift_loop:
	; shift a single row left by one bit, twice (once for upper and lower pairs)

	; set u3 to the address of the row, which will be construct_tile + (u2L*2)
	lda u2L
	asl
	sta u3L							; u3L now contains u2L*2 (no reason to bother with high byte)
	clc
	adc #<(construct_tile)
	sta u3L
	lda #0
	adc #>(construct_tile)			; now u3 contains the address of the row
	sta u3H

	; on passes 0-15, this is the top pair, and 16-31 the bottom pair
	; the address of the last byte will be u3 + 32 + 1, which we can do through zp indirect y addressing
	ldy #(32+1)
	lda (u3),y
	asl
	sta (u3),y
	ldy #(32)
	lda (u3),y
	rol
	sta (u3),y
	ldy #1	
	lda (u3),y
	rol
	sta (u3),y
	ldy #0
	lda (u3),y
	rol
	sta (u3),y

	inc u5L							; update the loop counter u5L and the index counter u2L
	inc u2L

	; top pair row check
	lda u2L
	cmp #16
	bcc @row_shift_loop
	bne @bottom_pair_row_check

	; jump index counter to 32 to calculate the bottom pair
	lda #32
	sta u2L

@bottom_pair_row_check:
	lda u5L
	cmp #16
	bcc @row_shift_loop
@end_row_shift_loop:
	
	dex
	bra @left_shift_loop
@end_left_shift_loop:

	; now with the x shifted to the left, we need to move on to shifting
	; upwards

	; NOTE: we no longer have to deal with the right tiles, since they have been
	; shifted into the left tiles

	lda u1L							; Move lower nibble of u1 into X
	and #$0f
	tax

@up_shift_loop:
	; each pass shifts the bytes up once
	cpx #0
	beq @end_up_shift_loop

	; since we no longer need it, use u2L as a loop counter
	lda #0
	sta u2L
	LoadW u3, construct_tile		; initialize u3 to the start of the construct_tile
	ldy #2							; Y will be 2 for addressing purposes
@top_byte_shift_loop:
	; each byte needs to copy the byte 2 address down from it

	lda (u3),y						; load from 2 bytes down
	sta (u3)						; store in current byte

	IncW u3							; increment the current byte
	inc u2L
	lda u2L
	cmp #30							; don't bother with the last two bytes,
									; since those will be copied manually
	bcc @top_byte_shift_loop
@end_top_byte_shift_loop:

	; now the top byte is shifted, except the last row which gets copied from
	; different addresses, so we do them manually

	; u3 is already at the first of the two manual bytes, but Y needs to be set to (32+2)
	ldy #(32+2)
	lda (u3),y
	sta (u3)
	IncW u3
	lda (u3),y
	sta (u3)

	; we still need to shift the bottom tile so that it can be read from during
	; additional passes of the up shift loop

	; use u2L as a loop counter
	lda #0
	sta u2L
	; for the second byte loop, set Y back to 2 and u3 to construct_tile+64
	LoadW u3, construct_tile+64
	ldy #2
@bottom_byte_shift_loop:
	; each byte needs to copy the byte 2 address down from it

	lda (u3),y						; load from 2 bytes down
	sta (u3)						; store in current byte

	IncW u3							; increment the current byte
	inc u2L
	lda u2L
	cmp #30							; don't bother with the last two bytes,
									; since those will be copied manually
	bcc @bottom_byte_shift_loop
@end_bottom_byte_shift_loop:

	dex
	bra @up_shift_loop
@end_up_shift_loop:

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
