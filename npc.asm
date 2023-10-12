.ifndef NPC_ASM
NPC_ASM = 1

; max allowed NPCs
MAX_NPCS = 32

.include "vram.inc"

.segment "BSS"

; An NPC is any animated sprite that is placed on the map, other than the
; player.  There are 4 parts to each NPC: an element of an array in low RAM, an
; array of tiles in high RAM, a sprite in VRAM, and the current tile in VRAM.

.struct Npc

	; The sprite index
	sprite				.res 1

	; Width/height of the sprite and number of animation frames
	; %hhwwffff
	size_and_frames		.res 1

	; Depth, vflip, and hflip for the sprite attribute in VERA
	; %0000ddvh
	depth_and_flip		.res 1

	; X location on the map
	mapx				.res 2

	; Y location on the map
	mapy				.res 2

	; The current frame.  If $ff, it indicates that this is a clone, and
	; therefore not in charge of its own frames
	frame				.res 1

	; How often to switch frames
	; This number will be ANDed to the tickcount and then compared to 0
	frame_mask			.res 1

	; The address of the first frame in the npc bank
	ram_addr			.res 2

	; The location in vram, bits 5-16 (32 byte aligned, like in sprites)
	vram_addr			.res 2

.endstruct

; the number of npcs
num_npcs:		.res 1

; an array of NPC data
npcs:			.res .sizeof(Npc) * MAX_NPCS

; next high RAM address for npc tile data
next_npc_ram:		.res 2

; next VRAM address (shifted right 5 so it's aligned to 32 bytes)
next_npc_vram:		.res 2

npc_frames_loaded:	.res 1

; This is an array of indexes shared by all maps.  They can make friendly names
; for their NPCs  by aliasing an offset into this array
npc_indexes:			.res MAX_NPCS

.segment "CODE"

;==================================================
; initialize_npc_memory
;
; void initialize_npc_memory()
;==================================================
initialize_npc_memory:
	stz num_npcs
	stz next_npc_ram
	stz next_npc_ram+1
	stz next_npc_vram
	stz next_npc_vram+1
	stz npc_frames_loaded

	rts
;==================================================
; add_npc
;
; Create an NPC in memory.  Pass it the index of
; the sprite to use in A, and it will return the
; NPC index in X.
;
; NOTE: The frames will still needed to be loaded
; into high RAM and the VRAM address still needs to
; be set.
;
; void add_npc(byte sprite_index: a,
;				out byte npc_index: x)
;==================================================
add_npc:

	; store the sprite index for later
	pha

	; calculate the memory location of the new NPC
	ldx num_npcs				; should be the next npc index
	jsr calculate_npc_address
	
	; store the sprite index
	pla
	ldy #Npc::sprite
	sta (u0),y

	; set the curent frame to 0
	lda #0
	ldy #Npc::frame
	sta (u0),y

	; increment the number of NPCs
	inc num_npcs

@return:
	rts
	
;==================================================
; clone_npc
; Creates a clone of an existing NPC that uses the
;
; same vram.  Clones will always be on the same
; frame as the NPC they were cloned from.
;
; void clone_npc(byte sprite_index: a,
;					byte existing_npc_index: x	
;					out byte npc_index: x)
;==================================================
clone_npc:

	; store the sprite index for later
	pha

	; grab the address of the existing NPC and move it to u1
	jsr calculate_npc_address
	MoveW u0, u1

	; calculate the memory location of the new NPC
	ldx num_npcs				; should be the next npc index
	jsr calculate_npc_address

	; u0 contains the address of the new NPC, and u1 contains the existing one

	; copy the existing NPC to the new address
	ldy #0
@copy_loop:
	cpy #.sizeof(Npc)
	bcs @end_copy_loop
	lda (u1),y
	sta (u0),y
	iny
	bra @copy_loop
@end_copy_loop:

	; store the new sprite index, overwriting the one that was copied
	pla
	ldy #Npc::sprite
	sta (u0),y

	; set the frame to $ff, indicating that this is a clone
	lda #$ff
	ldy #Npc::frame
	sta (u0),y

	phx

	; set sprite attributes that otherwise won't be set
	ldy #Npc::sprite
	lda (u0),y
	tax

	ldy #Npc::size_and_frames
	lda (u0),y
	and #$f0
	sprstore 7

	ldy #Npc::vram_addr
	lda (u0),y
	sprstore 0
	ldy #Npc::vram_addr+1
	lda (u0),y
	ora #%10000000		; set to 8bpp
	sprstore 1

	plx

	; increment the number of NPCs
	inc num_npcs

@return:
	rts

;==================================================
; set_npc_depth_flip
;
; Sets the NPCs depth and flip settings.
;
; void set_npc_depth_flip(byte npc_index: x,
;							byte depth_flip: A)
;==================================================
set_npc_depth_flip:

	pha

	jsr calculate_npc_address

	pla
	ldy #Npc::depth_and_flip
	sta (u0),y

	rts

;==================================================
; set_npc_flip
;
; Sets the NPCs flip setting
;
; void set_npc_flip(byte npc_index: x,
;					byte flip: A)
;==================================================
set_npc_flip:

	and #%00000011				; zero out non flip bits to leave depth alone
	sta u1L

	jsr calculate_npc_address

	ldy #Npc::depth_and_flip
	lda (u0),y
	
	ora #%11111100				; zero out the flip bits
	ora u1L						; apply the flip bits
	sta (u0),y					; re-store the depth flip bits

	rts

;==================================================
; set_npc_map_location
;
; Sets the NPCs location on the map.
;
; void set_npc_map_location(byte npc_index: x,
;							word mapx: u1,
;							word mapy: u2)
;==================================================
set_npc_map_location:

	; stash u0
	lda u0H
	pha
	lda u0L
	pha

	jsr calculate_npc_address

	lda u1L
	ldy #Npc::mapx
	sta (u0),y
	lda u1H
	ldy #Npc::mapx+1
	sta (u0),y

	lda u2L
	ldy #Npc::mapy
	sta (u0),y
	lda u2H
	ldy #Npc::mapy+1
	sta (u0),y

	; restore u0
	pla
	sta u0L
	pla
	sta u0H

	rts

;==================================================
; set_npc_map_location_depth_and_flip
;
; Sets the NPCs location on the map.
;
; void set_npc_map_location_depth_and_flip(byte npc_index: x,
;							word mapx: u1,
;							word mapy: u2,
;							word depth_flip: u3L)
;==================================================
set_npc_map_location_depth_and_flip:

	; stash u0
	lda u0H
	pha
	lda u0L
	pha

	jsr calculate_npc_address

	lda u1L
	ldy #Npc::mapx
	sta (u0),y
	lda u1H
	ldy #Npc::mapx+1
	sta (u0),y

	lda u2L
	ldy #Npc::mapy
	sta (u0),y
	lda u2H
	ldy #Npc::mapy+1
	sta (u0),y

	ldy #Npc::depth_and_flip
	lda (u0),y					; retain depth value
	and #%11111100
	ora u3L
	sta (u0),y

	; restore u0
	pla
	sta u0L
	pla
	sta u0H

	rts

;==================================================
; set_npc_tiles
;
; Loads and sets the tiles for an NPC
;
; void set_npc_tiles(byte npc_index: x,
;						byte size: a,
;						byte num_frames: y,
;						word file_name: u0,
;						word file_name_size: u1,
;						byte frame_mask: u2L)
;==================================================
set_npc_tiles:

	; push args to stack
	phx
	phy
	pha

	; move the filename to u3 so that u0 can be used for the npc array address
	MoveW u0, u3

	jsr calculate_npc_address

	; now u0 holds the address of the NPC in ram, so we can re-pull the args
	pla
	ply

	; set the size/frame byte (assume size is already in high nibble)
	
	; store size in u4L
	sta u4L
	tya
	ora u4L
	ldy #Npc::size_and_frames
	sta (u0),y

	; switch to NPC tile bank
	lda #npc_tile_bank
	sta $00
	
	; set ROM bank to KERNAL
	lda #0
	sta $01

	; load the frames into high RAM
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda u1
	ldx u3L
	ldy u3H
	jsr SETNAM
	lda #0
	ldx next_npc_ram
	ldy next_npc_ram+1
	jsr LOAD

	; store ram address to the NPC
	ldy #Npc::ram_addr
	lda next_npc_ram
	sta (u0),y
	ldy #Npc::ram_addr+1
	lda next_npc_ram+1
	sta (u0),y

	; set the vram address of the NPC
	ldy #Npc::vram_addr
	lda next_npc_vram
	sta (u0),y
	ldy #Npc::vram_addr+1
	lda next_npc_vram+1
	sta (u0),y

	; put the NPC's sprite index in X
	ldy #Npc::sprite
	lda (u0),y
	tax

	; set the vram address in the sprite attribute
	ldy #Npc::vram_addr
	lda (u0),y
	sprstore 0
	ldy #Npc::vram_addr+1
	lda (u0),y
	ora #%10000000		; set to 8bpp
	sprstore 1

	lda u2L
	ldy #Npc::frame_mask
	sta (u0),y

	ldy #Npc::size_and_frames
	lda (u0),y
	and #$f0
	sprstore 7

	; calculate increments
	ldy #Npc::size_and_frames
	; width
	lda (u0),y
	lsr
	lsr
	lsr
	lsr
	; A now holds %0000hhww

	jsr calculate_npc_bytes_per_frame

	; u4 now holds the number of bytes required to store each NPC tile

	; increment next_npc_ram by w*h*f
	ldy #Npc::size_and_frames
	lda (u0),y
	and #%00001111
	tax
@multiply_loop:
	cpx #0
	beq @end_multiply_loop
	clc
	lda u4L
	adc next_npc_ram
	sta next_npc_ram
	lda u4H
	adc next_npc_ram+1
	sta next_npc_ram+1
	dex
	bra @multiply_loop
@end_multiply_loop:

	; shift right by 5 for correct 32 byte alignment
	LsrW u4
	LsrW u4
	LsrW u4
	LsrW u4
	LsrW u4

	; increment next_npc_vram by w*h (shifted right by 5)
	clc
	lda next_npc_vram
	adc u4L
	sta next_npc_vram
	lda next_npc_vram+1
	adc u4H
	sta next_npc_vram+1

	plx

	rts

;==================================================
; calculate_npc_bytes_per_frame
;
; Given a width and high value packed into the
; lower nibble of A, calculate the number of bytes
; needed to store a single frame.
;
; A should be in the form: 0000hhww, where hh and
; ww follow the sprite attribute standard
;
; void calculate_npc_bytes_per_frame(
;							byte width_height: A,
;							out word num_bytes: u4)
;==================================================
calculate_npc_bytes_per_frame:

	; The width/height can only be 16 different values and we assume 8bpp,
	; meaning that there are only 7 possible outcomes: 64, 128, 256, 512, 1024,
	; 2048, and 4096.  This means we can use a jump table instead of
	; calculating

	cmp #0			; 8x8
	beq @store64
	cmp #1			; 16x8
	beq @store128
	cmp #2			; 32x8
	beq @store256
	cmp #3			; 64*8
	beq @store512
	cmp #4			; 8*16
	beq @store128
	cmp #5			; 16*16
	beq @store256
	cmp #6			; 32*16
	beq @store512
	cmp #7			; 64*16
	beq @store1024
	cmp #8			; 8*32
	beq @store256
	cmp #9			; 16*32
	beq @store512
	cmp #10			; 32*32
	beq @store1024
	cmp #11			; 64*32
	beq @store2048
	cmp #12			; 8*64
	beq @store512
	cmp #13			; 16*64
	beq @store1024
	cmp #14			; 32*64
	beq @store2048
	cmp #15			; 64*64
	beq @store4096


@store64:
	lda #64
	sta u4L
	lda #0
	sta u4H
	bra @return
@store128:
	lda #128
	sta u4L
	lda #0
	sta u4H
	bra @return
@store256:
	lda #0
	sta u4L
	lda #1
	sta u4H
	bra @return
@store512:
	lda #0
	sta u4L
	lda #2
	sta u4H
	bra @return
@store1024:
	lda #0
	sta u4L
	lda #4
	sta u4H
	bra @return
@store2048:
	lda #0
	sta u4L
	lda #8
	sta u4H
	bra @return
@store4096:
	lda #0
	sta u4L
	lda #16
	sta u4H
	bra @return

@return:
	rts

;==================================================
; calculate_npc_address
;
; Calculates the absolute address of a particular
; NPC given its index.
;
; void calculate_npc_address(byte npc_index: x,
;							out byte address: u0)
;==================================================
calculate_npc_address:

	phx

	; load the base address of the npc array
	LoadW u0, npcs

@multiply_loop:
	cpx #0
	beq @return
	clc
	lda #.sizeof(Npc)
	adc u0L
	sta u0L
	lda #0
	adc u0H
	sta u0H
	dex
	bra @multiply_loop

@return:
	plx
	rts

;==================================================
; initialize_npcs
;
; Initializes all the global NPC data
;
; void initialize_npcs()
;==================================================
initialize_npcs:

	lda #0
	sta num_npcs

	lda #<(vram_npc >> 5)
	sta next_npc_vram
	lda #>(vram_npc >> 5)
	sta next_npc_vram+1

	; set next_npc_ram to the beginning of the bank
	LoadW next_npc_ram, hi_mem

	; reset the frames loaded counter
	lda #0
	sta npc_frames_loaded

	rts

;==================================================
; update_npcs
;
; Draws the npcs.
;
; void update_npcs()
;==================================================
update_npcs:

	LoadW u0, npcs
	ldx #0
@npc_loop:
	cpx num_npcs
	bcs @end_npc_loop

	jsr update_npc
	
	; increment the address
	clc
	lda u0L
	adc #(.sizeof(Npc))
	sta u0L
	lda u0H
	adc #0
	sta u0H

	; increment the loop counter
	inx
	bra @npc_loop
@end_npc_loop:

@return:
	rts

;==================================================
; update_npc
;
; Draws a single npc.
;
; void update_npc(word npc_addr: u0)
;==================================================
update_npc:
	; push X to stack
	phx

	; if not all npcs have their frames loaded, always load the frame
	lda npc_frames_loaded
	cmp num_npcs
	bcc @update_frame

@animate:
	; when there's only one frame, don't bother swapping
	ldy #Npc::size_and_frames
	lda (u0),y
	and #$0f
	cmp #1
	beq @update_sprite_attributes

	; when it's not time to swap out the frames, don't
	ldy #Npc::frame_mask
	lda (u0),y
	and tickcount
	cmp #0
	bne @update_sprite_attributes

@update_frame:
	jsr update_npc_frame
	inc npc_frames_loaded

@update_sprite_attributes:
	; put the sprite index in X
	ldy #Npc::sprite
	lda (u0),y
	tax

@update_depth_flip:

	ldy #Npc::depth_and_flip
	lda (u0),y
	sprstore 6

@update_position:

	jsr update_npc_position

@return:
	; restore X
	plx

	rts

;==================================================
; update_npc_position
;
; Updates the position of an NPC
;
; void update_npc_position(word npc_addr: u0)
;==================================================
update_npc_position:

	; put the sprite index in X
	ldy #Npc::sprite
	lda (u0),y
	tax

	; set X
	ldy #Npc::mapx
	lda (u0),y
	sta u1L
	ldy #Npc::mapx+1
	lda (u0),y
	sta u1H

	; calculate position against render offsets, and don't render if it outside
	sec
	lda u1L
	sbc xoff_render
	sta u1L
	lda u1H
	sbc xoff_render+1
	sta u1H

	; check high byte first to see if we are off the map
	cmp #$2 ; screens can't be big enough for this to be valid
	bcc :+
	lda #0
	sprstore 6

:

	; subract 64 to compensate for calculating off the render offset
	sec
	lda u1L
	sbc #64
	sta u1L
	lda u1H
	sbc #0
	sta u1H
	sprstore 3
	lda u1L
	sprstore 2

	; set Y
	ldy #Npc::mapy
	lda (u0),y
	sta u1L
	ldy #Npc::mapy+1
	lda (u0),y
	sta u1H

	; calculate position against render offsets, and don't render if it outside
	sec
	lda u1L
	sbc yoff_render
	sta u1L
	lda u1H
	sbc yoff_render+1
	sta u1H

	; check high byte first to see if we are off the map
	cmp #$2 ; screens can't be big enough for this to be valid
	bcc :+
	lda #0
	sprstore 6

:
	; subract 64 to compensate for calculating off the render offset
	sec
	lda u1L
	sbc #64
	sta u1L
	lda u1H
	sbc #0
	sta u1H
	sprstore 5
	lda u1L
	sprstore 4

@return:
	rts

;==================================================
; update_npc_frame
;
; Update the frame of an NPC
;
; void update_npc_frame(word npc_addr: u0)
;==================================================
update_npc_frame:

	; First, check if the player is reading a dialog.  If frames are loaded
	; from hi ram while the dialog is up, it causes the dialog to flicker.
	lda player_status
	bit #player_status_reading_dialog
	beq :+
	rts
:

	; next, check if this is a clone and return if so.  Clones share frames
	; with the original, so we won't do anything here
	ldy #Npc::frame
	lda (u0),y
	cmp #$ff
	bne :+
	rts

:

	; set x to the sprite index
	ldy #Npc::sprite
	lda (u0),y
	tax

	lda #0
	sta veractl

	; copy the frame to vram

	; set the vram address
	ldy #Npc::vram_addr
	lda (u0),y
	sta u2L
	ldy #Npc::vram_addr+1
	lda (u0),y
	sta u2H
	AslW u2
	AslW u2
	AslW u2
	AslW u2
	AslW u2

	; the carry bit will be what to put in verahi
	lda #0
	adc #(1 << 4)	; increment of 1
	sta verahi
	lda u2L
	sta veralo
	lda u2H
	sta veramid

	; ram_addr refers to hi ram, so select the correct bank
	lda #npc_tile_bank
	sta $00

	; set the base ram address to u1
	ldy #Npc::ram_addr
	lda (u0),y
	sta u1L
	ldy #Npc::ram_addr+1
	lda (u0),y
	sta u1H

	; add the frame * the w*h
	ldy #Npc::size_and_frames
	lda (u0),y
	lsr
	lsr
	lsr
	lsr
	jsr calculate_npc_bytes_per_frame

	; u4 now contains the bytes per frame, so multiply it by the current frame
	ldy #Npc::frame
	lda (u0),y
	tay
@multiply_loop:
	cpy #0
	beq @end_multiply_loop
	clc
	lda u1L
	adc u4L
	sta u1L
	lda u1H
	adc u4H
	sta u1H
	dey
	bra @multiply_loop
@end_multiply_loop:

@copy_to_vram:

	; at this point, u1 contains the correct ram address for the frame, and u4
	; still contains the frame size in bytes

	; switch to correct ram bank
	lda #npc_tile_bank
	sta $00

@copy_loop:
	lda u4L
	ora u4H
	cmp #0
	beq @end_copy_loop

	lda (u1)
	sta veradat

	IncW u1
	DecW u4
	bra @copy_loop
@end_copy_loop:
	
	; first retreive the frames to compare with
	ldy #Npc::size_and_frames
	lda (u0),y
	and #$0f		; only use the lower nibble
	sta u1L			; u1L is no longer needed so it can be used as a temp value

	ldy #Npc::frame
	lda (u0),y
	inc
	cmp u1L
	bne @store_frame
	lda #0

@store_frame:
	ldy #Npc::frame
	sta (u0),y

@return:
	rts

;==================================================
; clear_npc_sprites
;
; Clears the sprites used for NPCs
;
; void clear_npc_sprites()
;==================================================
clear_npc_sprites:

	LoadW u0, npcs
	ldx #0
@npc_loop:
	cpx num_npcs
	bcs @end_npc_loop

	ldy #Npc::sprite
	lda (u0),y
	phx				; push X
	tax
	lda #0
	sprstore 6
	plx				; pull X
	
	; increment the address
	clc
	lda u0L
	adc #(.sizeof(Npc))
	sta u0L
	lda u0H
	adc #0
	sta u0H

	; increment the loop counter
	inx
	bra @npc_loop
@end_npc_loop:

	lda #0
	sta num_npcs
	sta npc_frames_loaded

	rts

.endif ; NPC_ASM
