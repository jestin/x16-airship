.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

	jmp main

.include "x16.inc"
.include "vera.inc"
.include "resources.asm"

; replace this with separate memory include file

default_irq			= $8000
zp_vsync_trig		= $30
tile_vram_data		= $04000
tile_map_vram_data	= $00000

main:
	; set video mode
	lda #%00100001		; sprites and l1 enabled
	sta veradcvideo

	lda #64
	sta veradchscale
	sta veradcvscale

	; set the tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 1 (64 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral1config

 	; set the tile base address
	lda #(<(tile_vram_data >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral1tilebase

	; read tile file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tilefilename-tilefilename)
	ldx #<tilefilename
	ldy #>tilefilename
	jsr SETNAM
	lda #(^tile_vram_data + 2)
	ldx #<tile_vram_data
	ldy #>tile_vram_data
	jsr LOAD

	; set the tile map base address
	lda #<(tile_map_vram_data >> 9)
	sta veral1mapbase

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tilemapfilename-tilemapfilename)
	ldx #<tilemapfilename
	ldy #>tilemapfilename
	jsr SETNAM
	lda #(^tile_map_vram_data + 2)
	ldx #<tile_map_vram_data
	ldy #>tile_map_vram_data
	jsr LOAD

	jsr init_irq

;==================================================
; mainloop
;==================================================
mainloop:
	wai
	jsr check_vsync
	jmp mainloop  ; loop forever

	rts

;==================================================
; init_irq
; Initializes interrupt vector
;==================================================
init_irq:
	lda IRQVec
	sta default_irq
	lda IRQVec+1
	sta default_irq+1
	lda #<handle_irq
	sta IRQVec
	lda #>handle_irq
	sta IRQVec+1
	rts

;==================================================
; handle_irq
; Handles VERA IRQ
;==================================================
handle_irq:
	; check for VSYNC
	lda veraisr
	and #$01
	beq @end
	sta zp_vsync_trig
	; clear vera irq flag
	sta veraisr

@end:
	jmp (default_irq)

;==================================================
; check_vsync
;==================================================
check_vsync:
	lda zp_vsync_trig
	beq @end

	; VSYNC has occurred, handle

	jsr tick

@end:
	stz zp_vsync_trig
	rts

;==================================================
; tick
;==================================================
tick:
	inc veral1hscrolllo
	bne @end
	inc veral1hscrollhi
	inc veral1vscrolllo
	bne @end
	inc veral1vscrollhi
@end:
	rts

