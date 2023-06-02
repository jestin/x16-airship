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
.include "interrupts.asm"
.include "video.asm"
.include "text.asm"
.include "title.asm"
.include "initialization.asm"

; 3rd party includes
.include "zsmplayer.inc"

; replace this with separate memory include file

.segment "RODATA"

loading_text:			.literal "Loading...", $00

.segment "BSS"

default_irq:		.res 2

; 256 repeating ticks
tickcount:		.res 1

; CPU_MONITOR = 1

.segment "CODE"

main:
	jsr initialize_memory

	.ifdef CPU_MONITOR
	lda #$02
	sta veractl

	lda #159
	sta veradchstop
	.endif

	stz veractl

	jsr initialize_vram

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
	LoadW player_file, lunafile
	LoadW player_file_size, end_lunafile - lunafile

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
	lda #(%00001000 | player_sprite_collision_mask)
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

	; perform the out-of-interrupt upkeep for each type of interrupt
	jsr vsync_tick
	jsr raster_line_tick
	jsr sprite_collision_tick

	jmp mainloop  ; loop forever

	rts

;==================================================
; initialize_vram
; 
; Initializes the memory behind VRAM
;==================================================
initialize_vram:
	vset $1f9c0

	ldx $0
@init_loop:
	stz veradat
	stz veradat
	stz veradat
	stz veradat
	stz veradat
	stz veradat
	stz veradat
	stz veradat
	inx
	bne @init_loop
	
	rts
