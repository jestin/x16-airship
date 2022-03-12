.ifndef ANIMATION_ASM
ANIMATION_ASM = 1

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
; void animation_calculate_frame(
; 					byte animation_frame: a
; 					byte sprite_index: x
; 					byte sprite_tile_index: y)
;==================================================
set_sprite_frame:
	pha			; push to preseve the frame
	; multiply by $08 using asl so it can be used as the high byte, effectively
	; adding (index * 2048) to the address
	asl
	asl
	asl
	asl
	asl
	; add to high byte of base_sprite_tiles
	clc
	; adc u0H
	adc #>vram_sprites
	asl

	; push result to stack for later
	pha

	; Y is effectively the upper byte of the address offset, since it has 256 bit alignment
	tya
	sta u14H
	stz u14L
	LsrW u14
	LsrW u14
	LsrW u14
	LsrW u14
	LsrW u14
	AddW u14, (vram_sprites >> 5)
	
	; pull high byte back from stack
	pla

	; Add to offset
	clc
	adc u14L

	sprstore 0
	pla			; pull to restore the frame

	rts

.endif ; ANIMATION_ASM
