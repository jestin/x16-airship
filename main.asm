.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

	jmp main

.include "x16.inc"
.include "vera.inc"
.include "macros.inc"
.include "ram.inc"
.include "vram.inc"
.include "resources.inc"
.include "movement.asm"
.include "animation.asm"
.include "collision.asm"

; replace this with separate memory include file


main:
	; initialize map width and height
	LoadW map_width, 2048
	LoadW map_height, 1024

	; initialize player location on screen
	lda #$a0
	sta xplayer
	lda #0
	sta xplayer+1
	lda #$88
	sta yplayer
	lda #0
	sta yplayer+1

	; initialize scroll variables
	lda #0
	sta xoff
	stz xoff+1
	sta yoff
	stz yoff+1

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

	; read Aurora player sprites into vram as the player
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_connorfile-connorfile)
	ldx #<connorfile
	ldy #>connorfile
	jsr SETNAM
	lda #(^vram_player_sprites + 2)
	ldx #<vram_player_sprites
	ldy #>vram_player_sprites
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

	; create player sprite
	lda #<(vram_player_sprites >> 5)
	sta veradat
	lda #>(vram_player_sprites >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda xplayer		; XL
	sta veradat
	lda xplayer+1	; XH
	sta veradat
	lda yplayer		; YL
	sta veradat
	lda yplayer+1	; YH
	sta veradat
	lda #%00001000	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; read collision tile file into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_collisionfile-collisionfile)
	ldx #<collisionfile
	ldy #>collisionfile
	jsr SETNAM
	lda #0
	ldx #<collision_tile_data
	ldy #>collision_tile_data
	jsr LOAD

	; read collision tile map into memory
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_collisionmapfile-collisionmapfile)
	ldx #<collisionmapfile
	ldy #>collisionmapfile
	jsr SETNAM
	lda #0
	ldx #<collision_map_data
	ldy #>collision_map_data
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
	beq @return
	sta zp_vsync_trig
	; clear vera irq flag
	sta veraisr

@return:
	jmp (default_irq)

;==================================================
; check_vsync
;==================================================
check_vsync:
	lda zp_vsync_trig
	beq @return

	; VSYNC has occurred, handle

	jsr tick

@return:
	stz zp_vsync_trig
	rts

;==================================================
; tick
;==================================================
tick:
	inc tickcount

	; get joystick data
	lda #0
	jsr joystick_get
	sta joystick_data
	stx joystick_data+1
	sty joystick_data+2

	jsr animate_player
	jsr move
@return:
	rts

