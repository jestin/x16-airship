.ifndef TITLE_ASM
TITLE_ASM = 1

;==================================================
; load_title
;
; Loads the title screen into vram
;
; void load_title()
;==================================================
load_title:

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_titlefile-titlefile)
	ldx #<titlefile
	ldy #>titlefile
	jsr SETNAM
	lda #(^vram_bitmap + 2)
	ldx #<vram_bitmap
	ldy #>vram_bitmap
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_titlepalfile-titlepalfile)
	ldx #<titlepalfile
	ldy #>titlepalfile
	jsr SETNAM
	lda #(^vram_palette + 2)
	ldx #<vram_palette
	ldy #>vram_palette
	jsr LOAD

	rts

;==================================================
; show_title
;
; Shows the title screen
;
; void show_title()
;==================================================
show_title:

	; set the l0 tile mode	
	lda #%00000110 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_bitmap >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase

	rts

.endif ; TITLE_ASM
