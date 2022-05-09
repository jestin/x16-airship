.ifndef ANIMATION_ASM
ANIMATION_ASM = 1

;==================================================
; animate_player
;==================================================
animate_player:
	; check if the dpad was pressed
	lda joystick_data
	bit#$8
	beq @calculate_frame
	bit#$4
	beq @calculate_frame
	bit#$2
	beq @calculate_frame
	bit #$1
	beq @calculate_frame

	lda #0
	bra @set_sprite

@calculate_frame:
	; returns the correct animation frame in A
	jsr animation_calculate_player_frame

@set_sprite:
	; Player
	ldx #player_sprite
	jsr set_sprite_frame

@return:
	rts

;==================================================
; animation_calculate_player_frame
; Based on the current tick count, calculates which
; frame animations should use.
;
; void animation_calculate_player_frame(
; 					out byte animation_frame: a)
;==================================================
animation_calculate_player_frame:
	; calculate frame and sprite - 0-0, 1-1, 2-0, 3-2
	lda tickcount
	lsr			; shift down a bit
	and #$0f	; take lower nibble
	cmp #$0c
	bcs @fourth
	cmp #$08
	bcs @third
	cmp #$04
	bcs @second
	cmp #$00
	bcs @first
@first:
	lda #0
	bra @return
@second:
	lda #1
	bra @return
@third:
	lda #0
	bra @return
@fourth:
	lda #2

@return:
	rts

;==================================================
; set_sprite_frame
; Sets the sprite to the current frame
;
; sprite_direction -
;					0 - forward facing
;					3 - right facing
;					6 - left facing
;					9 - rear facing
;
; void set_sprite_frame(byte animation_frame: a
; 						byte sprite_index: x)
;==================================================
set_sprite_frame:
	pha			; push to preseve the frame

	; This first part calculates the additional offset to apply determined by
	; which animation frame is needed

	; Because each sprite tile is 256 bytes, and the tiles are sequential, we
	; need to add (animation_frame * $0100) to the address.

	; Because tiles are 256 bytes apiece, playerdir is essentially the H byte
	; of the address offset, so we store it in memory as such for further
	; calculations
	clc
	adc playerdir
	sta u15H
	stz u15L

	; We've now added the player to direction and the animation frame, which
	; when used as the high byte make up the offset from the player sprite base
	; address

	; Shift the offset right 5, since the VERA doesn't store the lower 5 bits
	; of the tile address for sprites
	LsrW u15
	LsrW u15
	LsrW u15
	LsrW u15
	LsrW u15

	; add to the pre-shifted address of the start of the sprite tiles
	AddW u15, (vram_player_sprites >> 5)

	; u15 now contains the address of the correct frame of the correct sprite set

	lda u15L
	sprstore 0
	lda u15H
	ora #%10000000				; make sure to keep this sprite set to 8bpp
	sprstore 1
	pla			; pull to restore the frame

	rts

;==================================================
; add_animated_tile
; 
; Uses anim_tiles_count to add a tile index to the
; anim_tiles array and to copy the base tile to
; the correct place in ram.
;
; void add_animated_tile(byte tile_index: u0L)
;==================================================
add_animated_tile:

	; put the address of the animated tiles array in the zero page to use
	; (zp),y addressing
	LoadW u1, anim_tiles

	; load the current animated tile count
	lda anim_tiles_count
	tay
	lda u0L
	sta (u1),y

	; copy the base tile to ram so it can be reloaded after it is rewritten
	lda #0						; use data port 0 to point to the from tile
	sta veractl
	stz veralo
	lda u0L						; with 16x16 8bpp tiles, the index is the veramid address
	sta veramid
	lda #$10					; storing $10 in verahi sets the hi to 0 and the inc to 1
	sta verahi

	; switch to animation_tile_restore_data_bank
	lda #animation_tile_restore_data_bank
	sta $00

	; load the animation restore, and add the current anim_tiles_count to the
	; high byte, which will be the correct restore address
	LoadW u1, animation_tile_restore
	clc
	lda anim_tiles_count
	adc u1H
	sta u1H

	ldy #0
@copy_restore_tile_loop:
	lda veradat
	sta (u1),y
	iny
	bne @copy_restore_tile_loop

	; increment the animated tile count
	inc anim_tiles_count

	rts

;==================================================
; animate_map
;==================================================
animate_map:
	lda anim_tiles_count
	cmp #0
	beq @return

	; put the address of the animated tiles on the zero page so we can use
	; (zp),y addressing
	LoadW u1, anim_tiles

	; base the animation frame on tickcount

	lda tickcount
	lsr
	lsr
	lsr
	and #%00000011

	ldy #0
@tile_loop:
	pha							; need to push the frame num so we can load X properly
	lda (u1),y
	tax
	pla							; pull the frame num
	jsr set_tile_frame
	iny
	cpy anim_tiles_count
	bne @tile_loop

@return:
	rts
;==================================================
; set_tile_frame
; Sets the tile to the current frame
;
; Because only a small subset of all tiles can be
; animated, tile_index refers to the actual tile
; index, while anim_tile_index refers to which
; animated tile is being animated.
;
; void set_tile_frame(byte animation_frame: a
; 						byte tile_index: x
; 						byte anim_tile_index: y)
;==================================================
set_tile_frame:
	pha			; push to preseve the frame
	phy			; push to preseve the loop counter

	; first check if a is zero.  If so, we need to restore the original tile
	; from ram
	cmp #0
	beq @restore

	; animated tiles need to be stored consecutively and in order, so A+X is
	; the correct tile to copy

	stx u0L		; store x in a u0 so we can add it to A
	clc
	adc u0L
	sta u0L

	; u0L now contains the correct index of the tile to copy from.  Because we
	; only ever have 256 tiles, this addition must fit instead the lower byte.
	; If it doesn't the animation is invalid and the behavior undefined.

	; Now we need to calculate and set the vram addresses to copy from and to
	; copy to.  For simplicity, we are going to assume that tile data is stored
	; right at the front, at $00000.  This is convenient, because it means we
	; never have to worry about the high vram byte that is available.  All
	; calculations can stay within the 16-bit address space.

	; If we treat u0L as the mid byte of vram, it's the same as multiplying it
	; by 256 (the number of bytes per tiles).

	lda #1						; use data port 1 to point to the from tile
	sta veractl
	stz veralo
	lda u0L
	sta veramid
	lda #$10					; storing $10 in verahi sets the hi to 0 and the inc to 1
	sta verahi

	lda #0						; use data port 0 to point to the to tile
	sta veractl
	lda #0
	sta veralo
	txa							; the raw value in X is the index of the to tile
	sta veramid
	lda #$10					; storing $10 in verahi sets the hi to 0 and the inc to 1
	sta verahi

	ldx #0						; the previous value of X is no longer needed
@vram_copy_loop:
	lda veradat2
	sta veradat
	inx
	bne @vram_copy_loop

	bra @return					; skip over the restore loop

@restore:
	; no need to preserve A since if we are here, we know that it's 0

	; switch to animation_tile_restore_data_bank
	lda #animation_tile_restore_data_bank
	sta $00

	; add the anim_tile_index in Y to the animation_tile_restore address's high
	; byte to get the address of the copy from address
	LoadW u0, animation_tile_restore
	clc
	tya
	adc u0H
	sta u0H

	; u0 now contains the address of the correct tile to restore

	lda #0						; use data port 0 to point to the to tile
	sta veractl
	stz veralo
	txa							; the raw value in X is the index of the to tile
	sta veramid
	lda #$10					; storing $10 in verahi sets the hi to 0 and the inc to 1
	sta verahi

	ldy #0
@restore_loop:
	lda (u0),y
	sta veradat
	iny
	bne @restore_loop

@return:
	ply			; pull to restore the loop counter
	pla			; pull to restore the frame
	rts

.endif ; ANIMATION_ASM
