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
.include "animation.asm"

; replace this with separate memory include file


main:
	; initialize scroll variables
	lda #0
	sta xofflo
	sta yofflo
	stz xoffhi
	stz yoffhi

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
	lda #%00001000	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create Luna sprite
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
	lda #%00001000	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create Connor sprite
	lda #<((vram_sprites + (256 * 2)) >> 5)
	sta veradat
	lda #>((vram_sprites + (256 * 2)) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$9f		; X
	sta veradat
	lda #0
	sta veradat
	lda #$7f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001000	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create Elliot sprite
	lda #<((vram_sprites + (256 * 3)) >> 5)
	sta veradat
	lda #>((vram_sprites + (256 * 3)) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$af		; X
	sta veradat
	lda #0
	sta veradat
	lda #$7f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001000	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create George sprite
	lda #<((vram_sprites + (256 * 3)) >> 5)
	sta veradat
	lda #>((vram_sprites + (256 * 3)) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$bf		; X
	sta veradat
	lda #0
	sta veradat
	lda #$7f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001001	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create airship left sprite
	lda #<((vram_sprites + (256 * 62)) >> 5)
	sta veradat
	lda #>((vram_sprites + (256 * 62)) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$4f		; X
	sta veradat
	lda #0
	sta veradat
	lda #$4f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001100	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; create airship right sprite
	lda #<((vram_sprites + (256 * 63)) >> 5)
	sta veradat
	lda #>((vram_sprites + (256 * 63)) >> 5) | 1 << 7 ; mode=0
	sta veradat
	lda #$5f		; X
	sta veradat
	lda #0
	sta veradat
	lda #$4f		; Y
	sta veradat
	lda #0
	sta veradat
	lda #%00001100	; Collision/Z-depth/vflip/hflip
	sta veradat
	lda #%01010000	; Height/Width/Paloffset
	sta veradat

	; read collision file into memory
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
	jsr move
	jsr animate
@return:
	rts

;==================================================
; animate
;==================================================
animate:
	; returns the correct animation frame in A
	jsr animation_calculate_frame

	; Rorie
	ldx #0
	ldy #0
	jsr set_sprite_frame

	; Luna
	ldx #1
	ldy #1
	jsr set_sprite_frame


	; Conner
	ldx #2
	ldy #2
	jsr set_sprite_frame

	; Elliot
	ldx #3
	ldy #3
	jsr set_sprite_frame

	; George
	ldx #4
	ldy #3
	jsr set_sprite_frame

@return:
	rts

;==================================================
; move
;==================================================
move:
	lda #0
	jsr joystick_get

	bit#$8
	beq @up
	bit#$4
	beq @down
	bit#$2
	beq @left
	bit #$1
	beq @right
	bra @update
@up:
	dec yofflo
	lda yofflo
	cmp #$ff
	bne @update
	dec yoffhi
	bra @update
@down:
	inc yofflo
	bne @update
	inc yoffhi
	bra @update
@left:
	dec xofflo
	lda xofflo
	cmp #$ff
	bne @update
	dec xoffhi
	bra @update
@right:
	inc xofflo
	bne @update
	inc xoffhi
	
	; calculate and set the correct vera scroll offsets
@update:
	lda xoffhi
	cmp #$08
	bne @updatex
	stz xoffhi
@updatex:
	lda xofflo
	sta veral0hscrolllo
	sta veral1hscrolllo
	lda xoffhi
	sta veral0hscrollhi
	sta veral1hscrollhi

	lda yoffhi
	cmp #$04
	bne @updatey
	stz yoffhi

@updatey:
	lda yofflo
	sta veral0vscrolllo
	sta veral1vscrolllo
	lda yoffhi
	sta veral0vscrollhi
	sta veral1vscrollhi
	
@return: 
	rts
