.ifndef DIALOG_ASM
DIALOG_ASM = 1

.include "video.asm"

dialog_top = 100
dialog_bottom = 380

.segment "CODE"

;==================================================
; set_vera_dialog_top
;
; sets the video mode used within the dialog area
;==================================================
set_vera_dialog_top:

	; set video mode
	lda #%00010001
	jsr set_dcvideo

	; set the l0 tile mode	
	lda #%00000010 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	; set the tile map base address
	lda #<(vram_dialog_map >> 9)
	sta veral0mapbase

	lda #(<(vram_charset_sprites >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase

	lda #$ef
	sta veral0hscrolllo
	stz veral0hscrollhi

	; scroll down half dialog_top (because of the 2x vscale) plus another half-line
	lda #((256-(dialog_top/2)) - 4)
	sta veral0vscrolllo
	stz veral0vscrollhi

	stz veractl

	lda #51				; use a scale that fits exactly 32 characters on the screen
	sta veradchscale

	; set the next line interrupt at the end of the dialog
	lda #<(dialog_bottom)
	sta verairqlo
	lda veraien
	ora #((>dialog_bottom) << 7)
	sta veraien

	rts

;==================================================
; set_vera_dialog_bottom
;
; restores the video mode to normal
;==================================================
set_vera_dialog_bottom:
	; set video mode
	lda #%01110001
	jsr set_dcvideo

	; set the l0 tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	; set the l0 tile map base address
	lda #<(vram_l0_map_data >> 9)
	sta veral0mapbase

 	; set the tile base address
	lda #(<(vram_tile_data >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase

	lda #1
	jsr apply_scroll_offsets

	stz veractl

	lda #64
	sta veradchscale
	rts

.endif ; DIALOG_ASM
