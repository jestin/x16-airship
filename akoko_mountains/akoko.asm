.ifndef AKOKO_ASM
AKOKO_ASM = 1

AKOKO_MAP_ID = 1

.include "../map.asm"
.include "../player.asm"
.include "../npc.asm"
.include "../npc_group.asm"
.include "../npc_path.asm"
.include "../palette.asm"
.include "../random.asm"

.include "akoko_resources.inc"
.include "akoko_overworld_interactions.asm"

.segment "BSS"

.segment "CODE"

load_akoko:

	; stop music
	jsr stopmusic

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	lda map_id
	cmp #AKOKO_MAP_ID
	beq @start_load

	; stop music
	jsr stopmusic

@start_load:

	; initialize map width and height
	LoadW map_width, 1024
	LoadW map_height, 2048

	LoadW u0, akoko_collision_map_file
	LoadW u1, end_akoko_collision_map_file-akoko_collision_map_file
	jsr load_collision_map

	LoadW u0, akoko_interaction_map_file
	LoadW u1, end_akoko_interaction_map_file-akoko_interaction_map_file
	jsr load_interaction_map

	LoadW u0, akoko_message_file
	LoadW u1, end_akoko_message_file-akoko_message_file
	jsr load_messages

	lda map_id
	cmp #AKOKO_MAP_ID
	beq @set_just_sprites

	LoadW u0, akoko_tile_file
	LoadW u1, end_akoko_tile_file-akoko_tile_file
	jsr load_tiles

@set_just_sprites:

	; set video mode
	lda #%01000001		; sprites
	sta veradcvideo

	; load palette first so that the loading message is correct
	LoadW u0, akoko_pal_file
	LoadW u1, end_akoko_pal_file-akoko_pal_file
	jsr load_palette

	; store the palette in memory as well, so we can use palette effects on
	; this map
	jsr store_palette

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

	; clear any NPC sprites from other maps
	jsr clear_npc_sprites
	jsr clear_npc_groups
	
	; load NPCs
	jsr initialize_npcs

	lda map_id
	cmp #AKOKO_MAP_ID
	beq @load_tile_maps_from_cache

	; load all akoko music
	; jsr load_akoko_music

@load_tile_maps:

	LoadW u0, akoko_l0_map_file
	LoadW u1, end_akoko_l0_map_file-akoko_l0_map_file
	jsr load_l0_map

	vset vram_l0_map_data
	ldx #overworld_l0_map_bank_1
	ldy #overworld_l0_map_bank_2
	jsr cache_map_in_hi_mem

	LoadW u0, akoko_l1_map_file
	LoadW u1, end_akoko_l1_map_file-akoko_l1_map_file
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
	lda #%10010011 	; height (2-bits) - 2 (128 tiles)
					; width (2-bits) - 1 (64 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config
	sta veral1config

	LoadW tick_fn, akoko_character_overworld_tick
	LoadW interaction_fn, akoko_overworld_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

	; manually setup the animated tiles for the map
	lda #1
	sta u0L
	jsr add_animated_tile
	lda #5
	sta u0L
	jsr add_animated_tile
	lda #21
	sta u0L
	jsr add_animated_tile
	lda #37
	sta u0L
	jsr add_animated_tile
	lda #53
	sta u0L
	jsr add_animated_tile
	lda #69
	sta u0L
	jsr add_animated_tile

	; add the NPCs
	; jsr load_akoko_npcs

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

	lda #AKOKO_MAP_ID
	sta map_id

	lda #overworld_music_bank
	ldx #<hi_mem
	ldy #>hi_mem
	jsr startmusic

	rts

;==================================================
; player_to_akoko_home
;
; void player_to_akoko_home()
;==================================================
player_to_akoko_home:

	; initialize player location on screen
	LoadW xplayer, $00bc
	LoadW yplayer, $007a

	; initialize scroll variables
	LoadW xoff, $0040
	LoadW yoff, $0680

	rts

;==================================================
; akoko_character_overworld_tick
;
; Custom tick handler for the Akoko character
; overworld map.
;
; void akoko_character_overworld_tick()
;==================================================
akoko_character_overworld_tick:
	jsr character_overworld_tick

	lda palette_restore_flag
	beq @random_lightning

	cmp #4
	beq @end_lightning
	inc palette_restore_flag
	bra @return

@end_lightning:
	jsr restore_palette
	stz palette_restore_flag
	bra @return

@random_lightning:

	jsr get_random_byte
	cmp #0
	bne @return

	jsr lightning_effect
	lda #1
	sta palette_restore_flag

@return:
	rts

.endif ; AKOKO_ASM
