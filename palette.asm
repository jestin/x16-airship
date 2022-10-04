.ifndef PALETTE_ASM
PALETTE_ASM = 1

.segment "BSS"

palette_backup:			.res 512
palette_restore_flag:	.res 1

.segment "CODE"

;==================================================
; store_palette
;
; Stores the palette to memory so it can be
; restored later
;
; void store_palette()
;==================================================
store_palette:

	lda #0						; use data port 0 to point to the palette
	sta veractl
	stz veralo
	lda #$fa
	sta veramid
	lda #$11					; increment of 1
	sta verahi

	LoadW u0, palette_backup
	ldy #0

@palette_backup_loop:
	; because the palette is 512 bytes, copy two bytes per iteration
	lda veradat
	sta (u0)
	IncW u0
	lda veradat
	sta (u0)
	IncW u0
	iny
	bne @palette_backup_loop
@end_palette_backup_loop:

	rts

;==================================================
; restore_palette
;
; Restores the palette from memory
;
; void restore_palette()
;==================================================
restore_palette:

	lda #0						; use data port 0 to point to the palette
	sta veractl
	stz veralo
	lda #$fa
	sta veramid
	lda #$11					; increment of 1
	sta verahi

	LoadW u0, palette_backup
	ldy #0

@palette_restore_loop:
	; because the palette is 512 bytes, copy two bytes per iteration
	lda (u0)
	sta veradat
	IncW u0
	lda (u0)
	sta veradat
	IncW u0
	iny
	bne @palette_restore_loop
@end_palette_restore_loop:
	rts

;==================================================
; lightning_effect
;
; Restores the palette from memory
;
; void lightning_effect()
;==================================================
lightning_effect:

	lda #0						; use data port 0 for reading from the palette
	sta veractl
	stz veralo
	lda #$fa
	sta veramid
	lda #$11					; increment of 1
	sta verahi

	lda #1						; use data port 1 for writing to the palette
	sta veractl
	stz veralo
	lda #$fa
	sta veramid
	lda #$11					; increment of 1
	sta verahi

	ldy #0
@lightning_loop:
	; green, blue
	lda veradat
	ora #%10001000
	sta veradat2

	; red
	lda veradat
	ora #%00001000
	sta veradat2

	iny
	bne @lightning_loop
@end_lightning_loop:

	rts

.endif ; PALETTE_ASM
