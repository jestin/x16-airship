.ifndef ANIMATION_ASM
ANIMATION_ASM = 1

;==================================================
; animate_player
;==================================================
animate_player:
	; put direction offset byte in y
	lda joystick_data
	bit#$8
	beq @up
	bit#$4
	beq @down
	bit#$2
	beq @left
	bit #$1
	beq @right

	ldy #0
	lda #0
	bra @set_sprite

@down:
	ldy #0
	bra @calculate_frame
@right:
	ldy #3
	bra @calculate_frame
@left:
	ldy #6
	bra @calculate_frame
@up:
	ldy #9

@calculate_frame:
	; returns the correct animation frame in A
	jsr animation_calculate_frame

@set_sprite:
	; Player
	ldx #0
	jsr set_sprite_frame

@return:
	rts

;==================================================
; animation_calculate_frame
; Based on the current tick count, calculates which
; frame animations should use.
;
; void animation_calculate_frame(
; 					out byte animation_frame: a)
;==================================================
animation_calculate_frame:
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
; void animation_calculate_frame(
; 					byte animation_frame: a
; 					byte sprite_index: x
; 					byte sprite_direction: y)
;==================================================
set_sprite_frame:
	pha			; push to preseve the frame

	; This first part calculates the additional offset to apply determined by
	; which animation frame is needed

	; Because each sprite tile is 256 bytes, and the tiles are sequential, we
	; need to add (animation_frame * $0100) to the address.

	; multiply using asl so it can be used as the high byte, effectively adding
	; (index * 256) to the address
	asl
	asl
	; add to high byte of vram_player_sprites
	clc
	adc #>vram_player_sprites
	asl

	; push result to stack for later
	pha

	; Because tiles are 256 bytes apiece, Y is essentially the H byte of the
	; address offset, so we store it in memory as such for further calculations
	tya
	sta u15H
	stz u15L

	; Shift the address right 5, since the VERA doesn't store the lower 5 bits
	; of the tile address for sprites
	LsrW u15
	LsrW u15
	LsrW u15
	LsrW u15
	LsrW u15

	; add to the pre-shifted address of the start of the sprite tiles
	AddW u15, (vram_player_sprites >> 5)

	; u15 now has the VERA sprite-shifted address of the first frame of an animation set
	
	; pull high byte back from stack to apply the offset for the animation frame
	pla

	; Add to offset
	clc
	adc u15L
	
	; A now contains the address of the correct frame of the correct sprite set

	; NOTE: We are not bothering with the highest 4 bits of a sprite that can
	; be specifed with byte 1 of a sprite.  It's simply not needed or worth it
	; yet.

	sprstore 0
	pla			; pull to restore the frame

	rts

.endif ; ANIMATION_ASM
