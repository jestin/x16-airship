.ifndef PIXRYN_CAVE_ASM
PIXRYN_CAVE_ASM = 1

;==================================================
; load_pixryn_cave
;
; void load_pixryn_cave()
;==================================================
load_pixryn_cave:

	; diable player sprite
	ldx #player_sprite
	lda #0
	sprstore 6

	; set video mode
	lda #%01000001		; sprites
	sta veradcvideo

	; set the loading message
	LoadW u0, loading_text
	LoadW u1, 5
	LoadW u2, 230
	LoadW u3, message_sprites
	jsr draw_string

	; stop music
	jsr stopmusic

	; initialize map width and height
	LoadW map_width, 512
	LoadW map_height, 1024

	LoadW u0, cave_l0_map_file
	LoadW u1, end_cave_l0_map_file-cave_l0_map_file
	jsr load_l0_map

	LoadW u0, vimaskfile
	LoadW u1, end_vimaskfile-vimaskfile
	jsr load_l1_map

	LoadW u0, cave_collision_map_file
	LoadW u1, end_cave_collision_map_file-cave_collision_map_file
	jsr load_collision_map

	LoadW u0, pixryn_cave_interaction_map_file
	LoadW u1, end_pixryn_cave_interaction_map_file-pixryn_cave_interaction_map_file
	jsr load_interaction_map

	; set the l0 tile mode
	lda #%01000011 	; height (2-bits) - 1 (64 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	; set the l1 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral1config

	LoadW tick_fn, pixryn_cave_tick_handler
	LoadW interaction_fn, pixryn_cave_interaction_handler

	; always restore and clear previous animated tiles
	jsr clear_animated_tiles

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

	; set video mode
	lda #%01110001		; sprites, l0, and l1 enabled
	sta veradcvideo

	; set player sprite
	ldx #player_sprite
	lda #%00001000
	sprstore 6

	lda #music_bank_1
	ldx #<music_data
	ldy #>music_data
	jsr startmusic

	rts

;==================================================
; pixryn_cave_tick_handler
;
; void pixryn_cave_tick_handler()
;==================================================
pixryn_cave_tick_handler:

	jsr update_joystick_data
	jsr animate_map

	; check if player can move
	lda player_status
	bit #%00000001
	bne @control

	jsr animate_player
	jsr move
	lda #1
	jsr apply_scroll_offsets
	jsr position_mask_over_player
	jsr set_player_tile
	jsr check_interactions

@control:
	jsr character_overworld_control

@music:
	jsr playmusic

	; Manually push the address of the jmp to the stack to simulate jsr
	; instruction.
	; NOTE:  Due to an ancient 6502 bug, we need to make sure that tick_fn
	; doesn't have $ff in the low byte.  It's a slim chance, but will happen
	; sooner or later.  When it does, just fix by putting in a nop somewhere to
	; bump the address foward.
	lda #>(@jmp_interaction_return)
	pha
	lda #<(@jmp_interaction_return)
	pha
	jmp (interaction_fn)				; jump to whatever the current screen defines
@jmp_interaction_return:
	nop

@return: 
	rts

;==================================================
; position_mask_over_player
;
; void position_mask_over_player()
;==================================================
position_mask_over_player:
	lda #$f7
	sec
	sbc xplayer
	sta veral1hscrolllo
	lda #$f7
	sbc xplayer+1
	sta veral1hscrollhi

	lda #$f7
	sec
	sbc yplayer
	sta veral1vscrolllo
	lda #$f7
	sbc yplayer+1
	sta veral1vscrollhi

	rts

;==================================================
; player_to_cave_entrance
;
; void player_to_cave_entrance()
;==================================================
player_to_cave_entrance:

	; initialize player location on screen
	LoadW xplayer, $0050
	LoadW yplayer, $00a8

	; initialize scroll variables
	LoadW xoff, $0000
	LoadW yoff, $0300

	rts

;==================================================
; player_to_field_ladder
;
; void player_to_field_ladder()
;==================================================
player_to_field_ladder:

	; initialize player location on screen
	LoadW xplayer, $010f
	LoadW yplayer, $0098

	; initialize scroll variables
	LoadW xoff, $00C1
	LoadW yoff, $0311

	rts

;==================================================
; pixryn_cave_interaction_handler
;
; void pixryn_cave_interaction_handler()
;==================================================
pixryn_cave_interaction_handler:

; putting everything (except the symbol of this routine) into a proc means we
; don't have to worry about symbol collisions with other handlers
.proc PIXRYN_CAVE_INTERACTIONS

	lda u0L
	cmp #0
	beq @return

	; check if the b button was pressed
	lda joystick_data
	eor #$ff						; NOT the accumulator
	and joystick_changed_data
	cmp #%10000000				; checks if the b button is currently down, and wasn't before
	bne @auto_interactions

	; NOTE: We are using unnamed labels here so that we don't care which
	; section is which.  When the condition doesn't hit, we just advance to the
	; next label.  This allows us to reorder these handlers without recoding
	; them.

; these interactions only trigger when the user has pressed the b button on the tile
@b_button_interactions:

	lda u0L
	cmp #$10
	bne :+
	lda #6		; cave entrance sign
	jsr captured_message
	bra @return
:
	lda u0L
	cmp #$11
	bne :+
	lda #8		; nothing to see here
	jsr captured_message
	bra @return
:
	lda u0L
	cmp #$12
	bne :+
	lda #7		; deliveries ahead sign
	jsr captured_message
	bra @return
:
	lda u0L
	cmp #$13
	bne :+
	lda #5		; cabin ladder sign
	jsr captured_message
	bra @return

@auto_interactions:
:

	lda u0L
	cmp #$1
	bne :+
	jsr find_trapdoor_to_cabin
	bra @return

:

	lda u0L
	cmp #$2
	bne :+
	jsr find_trapdoor_to_field

:

@return:
	rts

;==================================================
; find_trapdoor_to_field
;
; void find_trapdoor_to_field()
;==================================================
find_trapdoor_to_field:

	lda #0
	sta playerdir
	jsr load_pixryn
	jsr player_to_pixryn_field
	; Call a tick directly so that the user doesn't see the map loaded, but the
	; player unpositioned
	jsr character_overworld_tick

	lda #4
	jsr captured_message

	rts

;==================================================
; find_trapdoor_to_cabin
;
; void find_trapdoor_to_cabin()
;==================================================
find_trapdoor_to_cabin:

	lda #0
	sta playerdir
	jsr load_pixryn_cabin
	; Call a tick directly so that the user doesn't see the map loaded, but the
	; player unpositioned
	jsr character_overworld_tick

	lda #4
	jsr captured_message

	rts

.endproc		; PIXRYN_CAVE_INTERACTIONS

.endif ; PIXRYN_CAVE_ASM
