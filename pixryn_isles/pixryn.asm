.ifndef PIXRYN_ASM
PIXRYN_ASM = 1

PIXRYN_MAP_ID = 1

.include "../map.asm"
.include "../player.asm"
.include "../npc.asm"
.include "../npc_group.asm"
.include "../npc_path.asm"

.include "pixryn_overworld_interactions.asm"
.include "pixryn_cabin.asm"
.include "pixryn_home.asm"
.include "pixryn_tavern.asm"
.include "pixryn_dirigible_shop.asm"
.include "pixryn_cave.asm"
.include "pixryn_resources.inc"

.segment "BSS"

ship_npc_group = npc_group_indexes + 0

.segment "CODE"

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
	jsr set_dcvideo

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
	jsr set_dcvideo

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

	; clear any NPC sprites from other maps
	jsr clear_npc_sprites
	jsr clear_npc_groups
	jsr clear_npc_paths
	
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
	jsr set_dcvideo

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
	lda #97
	jsr add_npc
	LoadW u0, testnpc_file
	LoadW u1, end_testnpc_file-testnpc_file
	lda #%00111111
	sta u2L
	lda #%01010000		; 16x16
	ldy #4				; number of frames
	jsr set_npc_tiles
	lda #%00001000
	jsr set_npc_depth_flip
	LoadW u1, 288
	LoadW u2, 320
	jsr set_npc_map_location

	; ship group
	jsr add_npc_group
	LoadW u3, 542
	LoadW u4, 350
	jsr set_npc_group_map_location

	stx ship_npc_group

	; ship
	lda #67
	jsr add_npc
	LoadW u0, ship_file
	LoadW u1, end_ship_file-ship_file
	lda #%00000011
	sta u2L
	lda #%01110000		; 64x16
	ldy #1				; number of frames
	jsr set_npc_tiles
	lda #%00001100
	jsr set_npc_depth_flip
	; LoadW u1, 542
	; LoadW u2, 376
	jsr set_npc_map_location

	; add the ship to the NPC group (x should be the NPC index)
	stz u2L
	lda #26
	sta u2H
	lda ship_npc_group
	jsr add_npc_to_group

	; ship in water
	; lda #67
	; jsr add_npc
	; LoadW u0, ship_in_water_file
	; LoadW u1, end_ship_in_water_file-ship_in_water_file
	; lda #%00000001
	; sta u2L
	; lda #%01110000		; 64x16
	; ldy #1				; number of frames
	; jsr set_npc_tiles
	; lda #%00001100
	; jsr set_npc_depth_flip
	; LoadW u1, 542
	; LoadW u2, 376
	; jsr set_npc_map_location

	; balloon
	lda #66
	jsr add_npc
	LoadW u0, balloon_file
	LoadW u1, end_balloon_file-balloon_file
	lda #%00000011
	sta u2L
	lda #%10110000		; 64x32
	ldy #1				; number of frames
	jsr set_npc_tiles
	lda #%00001100
	jsr set_npc_depth_flip
	; LoadW u1, 542
	; LoadW u2, 350
	jsr set_npc_map_location

	; add the balloon to the NPC group (x should be the NPC index)
	stz u2L
	stz u2H
	lda ship_npc_group
	jsr add_npc_to_group

	; propeller
	lda #65
	jsr add_npc
	LoadW u0, propeller_file
	LoadW u1, end_propeller_file-propeller_file
	lda #%00000011
	sta u2L
	lda #%00000000		; 8x8
	ldy #2				; number of frames
	jsr set_npc_tiles
	lda #%00001100
	jsr set_npc_depth_flip
	; LoadW u1, 600
	; LoadW u2, 384
	jsr set_npc_map_location

	; add the propeller to the NPC group (x should be the NPC index)
	lda #58
	sta u2L
	lda #34
	sta u2H
	lda ship_npc_group
	jsr add_npc_to_group

	; create path for ship
	lda ship_npc_group
	jsr add_npc_path
	phx					; push path index
	ldx #%00010001
	ldy #%01110001
	LoadW u2, 200
	LoadW u3, 250
	pla					; pull path index
	pha					; re-push path index
	jsr add_stop_to_npc_path
	ldx #%00010001
	ldy #%00110001
	LoadW u2, 400
	LoadW u3, 150
	pla					; pull path index
	pha					; re-push path index
	jsr add_stop_to_npc_path
	ldx #%00010001
	ldy #%00010001
	LoadW u2, 600
	LoadW u3, 350
	pla					; pull path index
	jsr add_stop_to_npc_path

	; example clone
	; lda #70
	; ; x should already be the propeller
	; jsr clone_npc
	; LoadW u1, 604
	; LoadW u2, 394
	; jsr set_npc_map_location

	rts

;==================================================
; load_pixryn_music
;==================================================
load_pixryn_music:

	; set ROM bank to KERNAL
	lda #0
	sta $01

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

;==================================================
; player_to_pixryn_dirigible_shop
;
; void player_to_pixryn_dirigible_shop()
;==================================================
player_to_pixryn_dirigible_shop:

	; initialize player location on screen
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0184
	LoadW yoff, $015f

	rts

.endif ; PIXRYN_ASM
