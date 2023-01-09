.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

	jmp main
	
.include "x16.inc"
.include "vera.inc"
.include "macros.inc"
.include "himem.inc"
.include "vram.inc"
.include "sprites.inc"
.include "resources.inc"
.include "video.asm"
.include "text.asm"
.include "title.asm"

; 3rd party includes
.include "zsmplayer.inc"

; replace this with separate memory include file

.segment "RODATA"

loading_text:			.literal "Loading...", $00

.segment "BSS"

; vsync trigger for running the game loop
vsync_trigger:		.res 1
line_trigger:		.res 1
spr_trigger:		.res 1

start_dialog:		.res 1
dialog_top = 100
dialog_bottom = 380

default_irq:		.res 2

; 256 repeating ticks
tickcount:		.res 1

; CPU_MONITOR = 1

.segment "CODE"

main:

	.ifdef CPU_MONITOR
	lda #$02
	sta veractl

	lda #159
	sta veradchstop
	
	lda #$00
	sta veractl
	.endif

	jsr init_player

	; set video mode
	lda #%01000001		; turn off layers while loading (leave sprites)
	jsr set_dcvideo
	
	lda #64
	sta veradchscale
	sta veradcvscale

	; character initialization
	stz next_char_sprite

	; set ROM bank to KERNAL
	lda #0
	sta $01

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_charsetfile-charsetfile)
	ldx #<charsetfile
	ldy #>charsetfile
	jsr SETNAM
	lda #(^vram_charset_sprites + 2)
	ldx #<vram_charset_sprites
	ldy #>vram_charset_sprites
	jsr LOAD

	; TODO: Move this to a player selection screen
	LoadW player_file, aurorafile
	LoadW player_file_size, end_aurorafile - aurorafile

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
	ldx #player_sprite
	lda #<(vram_player_sprites >> 5)
	sprstore 0
	lda #>(vram_player_sprites >> 5) | %10000000 ; mode=1
	sprstore 1
	lda xplayer
	sprstore 2
	lda xplayer+1
	sprstore 3
	lda yplayer
	sprstore 4
	lda yplayer+1
	sprstore 5
	lda #%00000000	; Collision/Z-depth/vflip/hflip
	sprstore 6
	lda #%01010000	; Height/Width/Paloffset
	sprstore 7

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

	jsr init_irq

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; set video mode
	lda #%01000001		; sprites
	jsr set_dcvideo

	jsr load_title
	jsr load_title_music

	; turn off loading sprites
	lda #%00010001		; l0
	jsr set_dcvideo

	jsr show_title


;==================================================
; mainloop
;==================================================
mainloop:
	wai
	jsr check_vsync
	jsr check_line
	jsr check_sprite
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
	sei
	lda #<handle_irq
	sta IRQVec
	lda #>handle_irq
	sta IRQVec+1
	lda #$01				; set vera to only interrupt on vsync
	sta veraien
	cli
	rts

;==================================================
; handle_irq
; Handles VERA IRQ
;==================================================
handle_irq:
	; check for VSYNC
	lda veraisr
	and #$01
	beq :+
	sta vsync_trigger
	; clear vera irq flag
	sta veraisr
	bra @return
:
	; check for raster line
	lda veraisr
	and #$02
	beq :+
	sta line_trigger
	; clear vera irq flag
	sta veraisr
	; return from the IRQ manually
	ply
	plx
	pla
	rti
	; end of line IRQ
:
	; check for sprite
	lda veraisr
	and #$04
	beq :+
	sta spr_trigger
	; clear vera irq flag
	sta veraisr
	bra @return
:
@return:
	jmp (default_irq)

;==================================================
; check_vsync
;==================================================
check_vsync:
	lda vsync_trigger
	beq @return

	; VSYNC has occurred, handle

	lda player_status
	bit #%00000100		; showing dialog
	beq :+

	; in dialog mode so set up line interrupt
	lda #<(dialog_top)
	sta verairqlo
	lda #$3 | ((>dialog_top) << 7)
	sta veraien
	lda #1
	sta start_dialog
:
	inc tickcount

	; Manually push the address of the jmp to the stack to simulate jsr
	; instruction.
	; NOTE:  Due to an ancient 6502 bug, we need to make sure that tick_fn
	; doesn't have $ff in the low byte.  It's a slim chance, but will happen
	; sooner or later.  When it does, just fix by putting in a nop somewhere to
	; bump the address foward.
	lda #>(@jmp_tick_return)
	pha
	lda #<(@jmp_tick_return)
	pha
	jmp (tick_fn)				; jump to whatever the current screen defines
								; as the tick handler
@jmp_tick_return:
	nop

@return:
	stz vsync_trigger
	rts

;==================================================
; check_line
;==================================================
check_line:
	lda line_trigger
	beq @return

	; check if we are at the start of the dialog or end
	lda start_dialog
	beq @end_dialog

	; start of the dialog

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

	stz veral0hscrolllo
	stz veral0hscrollhi
	lda #(256-(dialog_top/2))
	sta veral0vscrolllo
	stz veral0vscrollhi

	lda #51				; use a scale that fits exactly 32 characters on the screen
	sta veradchscale

	; set the next line interrupt at the end of the dialog
	lda #<(dialog_bottom)
	sta verairqlo
	lda veraien
	ora #((>dialog_bottom) << 7)
	sta veraien

	stz start_dialog
	bra @return

@end_dialog:
	; end of the dialog

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

	lda #64
	sta veradchscale

	lda veraien
	and #%11111101		; disable line interrupt
	sta veraien

@return:
	stz line_trigger
	rts

;==================================================
; check_sprite
;==================================================
check_sprite:
	lda spr_trigger
	beq @return

@return:
	stz spr_trigger
	rts
