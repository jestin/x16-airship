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

	; at this point, u0 contains the map X and u1 contains map y

	; The collision tile can be determined from either 1 tile, 2 tiles, or 4
	; tiles.  We only need 1 tile when the player sprite is located squarely
	; in a single map tile.  We need 2 tiles when the playe sprite does not
	; cross a vertical tile boundary, or a horizontal tile boundary.  All other
	; cases require 4 map tiles.

	; First check if we can get away with a single tile, which happens when the
	; lower nibble of both x and y are 0.

	lda u0
	and #$0f
	bne @x_aligned

@x_aligned:
	lda u1
	and #$0f
	bne @xy_aligned

	; here we can get away with checking the active tile and the one below it
	jsr construct_collision_tile_x_aligned
	bra @return

	bra @check_y_aligned

@xy_aligned:
	; here we can get away with checking only the active tile
	jsr construct_collision_tile_xy_aligned
	bra @return

@check_y_aligned:
	lda u1
	and #$0f
	bne @y_aligned
	bra @not_aligned

@y_aligned:
	; here we can get away with checking the active tile and the one below it
	jsr construct_collision_tile_y_aligned
	bra @return

@not_aligned:

@return:
	rts

;==================================================
; construct_collision_tile_xy_aligned
; Create a 16x16 tile of collision map from the
; space occupied by the player sprite.
;
; void construct_collision_tile_xy_aligned()
;==================================================
construct_collision_tile_xy_aligned:

@return:
	rts

;==================================================
; construct_collision_tile_x_aligned
; Create a 16x16 tile of collision map from the
; space occupied by the player sprite.
;
; void construct_collision_tile_x_aligned()
;==================================================
construct_collision_tile_x_aligned:

@return:
	rts

;==================================================
; construct_collision_tile_y_aligned
; Create a 16x16 tile of collision map from the
; space occupied by the player sprite.
;
; void construct_collision_tile_y_aligned()
;==================================================
construct_collision_tile_y_aligned:

@return:
	rts

.endif ; COLLISION_ASM
