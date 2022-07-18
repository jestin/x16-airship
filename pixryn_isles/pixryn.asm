.ifndef PIXRYN_ASM

.include "../map.asm"
.include "../player.asm"
.include "../npc.asm"

.include "pixryn_overworld_interactions.asm"
.include "pixryn_cabin.asm"
.include "pixryn_home.asm"
.include "pixryn_tavern.asm"
.include "pixryn_cave.asm"
.include "pixryn_resources.inc"

PIXRYN_ASM = 1

PIXRYN_MAP_ID = 1

;==================================================
; load_pixryn
;
; void load_pixryn()
;==================================================
load_pixryn:

	; stop music
	jsr stopmusic

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	lda map_id
	cmp #PIXRYN_MAP_ID
	beq @start_load

	; stop music
	jsr stopmusic

@start_load:

	; initialize map width and height
	LoadW map_width, 2048
	LoadW map_height, 1024

	LoadW u0, pixryn_collision_map_file
	LoadW u1, end_pixryn_collision_map_file-pixryn_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_interaction_map_file
	LoadW u1, end_pixryn_interaction_map_file-pixryn_interaction_map_file
	jsr load_interaction_map

	LoadW u0, pixryn_message_file
	LoadW u1, end_pixryn_message_file-pixryn_message_file
	jsr load_messages

	lda map_id
	cmp #PIXRYN_MAP_ID
	beq @set_just_sprites

	LoadW u0, pixryn_tile_file
	LoadW u1, end_pixryn_tile_file-pixryn_tile_file
	jsr load_tiles

@set_just_sprites:

	; set video mode
	lda #%01000001		; sprites
	sta veradcvideo

	; load palette first so that the loading message is correct
	LoadW u0, pixryn_pal_file
	LoadW u1, end_pixryn_pal_file-pixryn_pal_file
	jsr load_palette

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; set video mode
	lda #%01000001		; sprites
	sta veradcvideo

	; load the player into the sprites
	lda player_file
	sta u0L
	lda player_file+1
	sta u0H
	lda player_file_size
	sta u1L
	lda player_file_size+1
	sta u1H
	jsr load_player_sprites
	
	; load NPCs
	jsr initialize_npcs

	lda map_id
	cmp #PIXRYN_MAP_ID
	beq @load_tile_maps_from_cache

	; load all pixryn music
	jsr load_pixryn_music

@load_tile_maps:

	LoadW u0, pixryn_l0_map_file
	LoadW u1, end_pixryn_l0_map_file-pixryn_l0_map_file
	jsr load_l0_map

	vset vram_l0_map_data
	ldx #overworld_l0_map_bank_1
	ldy #overworld_l0_map_bank_2
	jsr cache_map_in_hi_mem

	LoadW u0, pixryn_l1_map_file
	LoadW u1, end_pixryn_l1_map_file-pixryn_l1_map_file
	jsr load_l1_map

	vset vram_l1_map_data
	ldx #overworld_l1_map_bank_1
	ldy #overworld_l1_map_bank_2
	jsr cache_map_in_hi_mem

	bra @set_layer

@load_tile_maps_from_cache:

	vset vram_l0_map_data
	ldx #overworld_l0_map_bank_1
	ldy #overworld_l0_map_bank_2
	jsr load_map_from_cache

	vset vram_l1_map_data
	ldx #overworld_l1_map_bank_1
	ldy #overworld_l1_map_bank_2
	jsr load_map_from_cache

@set_layer:

	; set the l0 tile mode	
	lda #%01100011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 2 (128 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW tick_fn, character_overworld_tick
	LoadW interaction_fn, pixryn_overworld_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

	; manually setup the animated tiles for the map
	lda #1
	sta u0L
	jsr add_animated_tile
	lda #74
	sta u0L
	jsr add_animated_tile
	lda #197
	sta u0L
	jsr add_animated_tile
	lda #213
	sta u0L
	jsr add_animated_tile

	; add the NPCs
	jsr load_pixryn_npcs

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

	; clear loading message
	LoadW u0, message_sprites
	jsr clear_text_sprites

	; set player sprite
	ldx #player_sprite
	lda #%00001000
	sprstore 6

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	lda #PIXRYN_MAP_ID
	sta map_id

	lda #overworld_music_bank
	ldx #<hi_mem
	ldy #>hi_mem
	jsr startmusic

	rts


;==================================================
; load_pixryn_npcs
;==================================================
load_pixryn_npcs:
	; test NPC
	lda #100			; sprite index
	jsr add_npc
	LoadW u0, testnpc_file
	LoadW u1, end_testnpc_file-testnpc_file
	lda #%00011111
	sta u2L
	lda #%01010000		; 16x16
	ldy #4				; number of frames
	jsr set_npc_tiles
	lda #%00001100
	jsr set_npc_depth_flip
	LoadW u1, 128
	LoadW u2, 128
	jsr set_npc_map_location

	rts

;==================================================
; load_pixryn_music
;==================================================
load_pixryn_music:

	; overworld
	lda #overworld_music_bank
	sta 0
	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda #(end_pixryn_overworld_music_file-pixryn_overworld_music_file)
	ldx #<pixryn_overworld_music_file
	ldy #>pixryn_overworld_music_file
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
	jsr LOAD

	; cave
	lda #music_bank_1
	sta 0
	lda #1
	ldx #8
	ldy #2
	jsr SETLFS
	lda #(end_pixryn_cave_music_file-pixryn_cave_music_file)
	ldx #<pixryn_cave_music_file
	ldy #>pixryn_cave_music_file
	jsr SETNAM
	lda #0
	ldx #<hi_mem
	ldy #>hi_mem
	jsr LOAD

	rts

;==================================================
; player_to_pixryn_tavern
;
; void player_to_pixryn_tavern()
;==================================================
player_to_pixryn_tavern:

	; initialize player location on screen
	LoadW xplayer, $00ac
	LoadW yplayer, $0048

	; initialize scroll variables
	LoadW xoff, $0144
	LoadW yoff, $0000

	rts

;==================================================
; player_to_pixryn_home
;
; void player_to_pixryn_home()
;==================================================
player_to_pixryn_home:

	; initialize player location on screen
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0144
	LoadW yoff, $00bf

	rts

;==================================================
; player_to_pixryn_cabin
;
; void player_to_pixryn_cabin()
;==================================================
player_to_pixryn_cabin:

	; initialize player location on screen
	LoadW xplayer, $0050
	LoadW yplayer, $006a

	; initialize scroll variables
	LoadW xoff, $0000
	LoadW yoff, $0000

	rts

;==================================================
; player_to_pixryn_field
;
; void player_to_pixryn_field()
;==================================================
player_to_pixryn_field:

	; initialize player location on screen
	LoadW xplayer, $00ba
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0094
	LoadW yoff, $013f

	rts

.endif ; PIXRYN_ASM
