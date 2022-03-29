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
.include "map.asm"
.include "pixryn.asm"

; replace this with separate memory include file


main:
	lda #64
	sta veradchscale
	sta veradcvscale

 	; set the tile base address
	lda #(<(vram_tile_data >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	sta veral1tilebase

	; set the l0 tile map base address
	lda #<(vram_l0_map_data >> 9)
	sta veral0mapbase

	; set the l1 tile map base address
	lda #<(vram_l1_map_data >> 9)
	sta veral1mapbase

	; read Aurora player sprites into vram as the player
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_aurorafile-aurorafile)
	ldx #<aurorafile
	ldy #>aurorafile
	jsr SETNAM
	lda #(^vram_player_sprites + 2)
	ldx #<vram_player_sprites
	ldy #>vram_player_sprites
	jsr LOAD

	LoadWBE player_collision_tile+00, %0000000000000000
	LoadWBE player_collision_tile+02, %0000000000000000
	LoadWBE player_collision_tile+04, %0000000000000000
	LoadWBE player_collision_tile+06, %0000000000000000
	LoadWBE player_collision_tile+08, %0000000000000000
	LoadWBE player_collision_tile+10, %0000000000000000
	LoadWBE player_collision_tile+12, %0000000000000000
	LoadWBE player_collision_tile+14, %0000000000000000
	LoadWBE player_collision_tile+16, %0000111111110000
	LoadWBE player_collision_tile+18, %0000111111110000
	LoadWBE player_collision_tile+20, %0000111111110000
	LoadWBE player_collision_tile+22, %0000111111110000
	LoadWBE player_collision_tile+24, %0000111111110000
	LoadWBE player_collision_tile+26, %0000111111110000
	LoadWBE player_collision_tile+28, %0000111111110000
	LoadWBE player_collision_tile+30, %0000111111110000

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

	jsr load_pixryn

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

