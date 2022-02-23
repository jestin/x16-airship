.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

	jmp main

.include "x16.inc"
.include "vera.inc"
.include "vram.inc"
.include "resources.asm"

; replace this with separate memory include file

default_irq			= $8000
zp_vsync_trig		= $30

main:
	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	lda #64
	sta veradchscale
	sta veradcvscale

	; set the l0 tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

 	; set the l0 tile base address
	lda #(<(vram_tile_data >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
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
	lda #(^vram_tile_data + 2)
	ldx #<vram_tile_data
	ldy #>vram_tile_data
	jsr LOAD

	; set the tile map base address
	lda #<(vram_l0_map_data >> 9)
	sta veral0mapbase

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tilemapfilename-tilemapfilename)
	ldx #<tilemapfilename
	ldy #>tilemapfilename
	jsr SETNAM
	lda #(^vram_l0_map_data + 2)
	ldx #<vram_l0_map_data
	ldy #>vram_l0_map_data
	jsr LOAD


	; set the tile map base address
	lda #<(vram_l1_map_data >> 9)
	sta veral1mapbase

	; read tile map file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_tilemap2filename-tilemap2filename)
	ldx #<tilemap2filename
	ldy #>tilemap2filename
	jsr SETNAM
	lda #(^vram_l1_map_data + 2)
	ldx #<vram_l1_map_data
	ldy #>vram_l1_map_data
	jsr LOAD

	; read sprites into vram
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_spritefile-spritefile)
	ldx #<spritefile
	ldy #>spritefile
	jsr SETNAM
	lda #(^vram_sprites + 2)
	ldx #<vram_sprites
	ldy #>vram_sprites
	jsr LOAD

	; load sprites
	lda #0
	sta veractl
	lda #<(vram_sprd >> 16) | $10
	sta verahi
	lda #<(vram_sprd >> 8)
	sta veramid
	lda #<(vram_sprd)
	sta veralo

	; create Rorie sprite
	lda #<(vram_sprites >> 5)
	sta veradat
	lda #>(vram_sprites >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$7f		; X
	sta veradat
	lda #0
	sta veradat
	lda #$7f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001100	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create Rorie sprite
	lda #<((vram_sprites + 256) >> 5)
	sta veradat
	lda #>((vram_sprites + 256) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$8f		; X
	sta veradat
	lda #0
	sta veradat
	lda #$7f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001100	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

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
	inc veral0hscrolllo
	inc veral1hscrolllo
	bne @vertical
	inc veral0hscrollhi
	inc veral1hscrollhi

@vertical:
	inc veral0vscrolllo
	inc veral1vscrolllo
	beq @end
	inc veral0vscrolllo
	inc veral1vscrolllo
	bne @end
	inc veral0vscrollhi
	inc veral1vscrollhi
@end:
	rts

