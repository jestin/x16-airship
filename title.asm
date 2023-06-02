.ifndef TITLE_ASM
TITLE_ASM = 1

.include "tick_handlers.asm"

.segment "CODE"

;==================================================
; load_title
;
; Loads the title screen into vram
;
; void load_title()
;==================================================
load_title:

	; set ROM bank to KERNAL
	lda #0
	sta $01

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
; load_title_music
;
; Loads the title screen into vram
;
; void load_title_music()
;==================================================
load_title_music:

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #music_bank_2
	sta 0
	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda #(end_title_music_file-title_music_file)
	ldx #<title_music_file
	ldy #>title_music_file
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
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

	; set the title IRQ handler
	sei
	lda #<title_irq_handler
	sta IRQVec
	lda #>title_irq_handler
	sta IRQVec+1
	cli

	LoadW tick_fn, title_screen_tick
	
	; title music
	lda #music_bank_2
	ldx #<hi_mem
	ldy #>hi_mem
	jsr startmusic

	; set the l0 layer mode	
	lda #%00000110 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 1
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_bitmap >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase

	rts

.endif ; TITLE_ASM
