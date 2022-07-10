.ifndef NPC_ASM
NPC_ASM = 1

.include "vram.inc"

.segment "DATA"

; An NPC is any animated sprite that is placed on the map, other than the
; player.  There are 4 parts to each NPC: an element of an array in low RAM, an
; array of tiles in high RAM, a sprite in VRAM, and the current tile in VRAM.

.struct Npc
	; the sprite index
	sprite				.byte 1
	; width/height of the sprite and number of animation frames
	; %hhwwffff
	size_and_frames		.byte 1
	; the current frame
	frame				.byte 1
	; the address of the first frame in the npc bank
	ram_addr			.byte 2
	; the location in vram
	vram_addr			.byte 3
.endstruct

; the number of npcs
num_npcs:		.res 1

; an array of NPC data with a max of 32
npcs:			.res .sizeof(Npc) * 32

; next high RAM address for npc tile data
next_npc_ram:		.res 2

; next VRAM address
next_npc_vram:		.res 3

.segment "CODE"

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

	; store the num frames and sprite index for later
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
	IncW num_npcs

@return:
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
;						word file_name_size: u1)
;==================================================
set_npc_tiles:

	; push args to stack
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
	ldy Npc::size_and_frames
	sta (u0),y

	; switch to NPC tile bank
	lda #npc_tile_bank
	sta $00

	;load the frames into high RAM
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
	ldy Npc::ram_addr
	lda next_npc_ram
	sta (u0),y
	iny
	lda next_npc_ram+1
	sta (u0),y

	; set the vram address of the NPC
	ldy Npc::vram_addr
	lda next_npc_vram
	sta (u0),y
	iny
	lda next_npc_vram+1
	sta (u0),y

	; calculate increments
	; The width/height can only be 16 different values and we assume 8bpp,
	; meaning that there are only 7 possible outcomes: 64, 128, 256, 512, 1024,
	; 2048, and 4096.  This means we can use a jump table instead of
	; calculating
	ldy Npc::size_and_frames
	; width
	lda (u0),y
	lsr
	lsr
	lsr
	lsr
	; A now holds %0000hhww

	cmp #0			; 8x8
	jmp @store64
	cmp #1			; 16x8
	jmp @store128
	cmp #2			; 32x8
	jmp @store256
	cmp #3			; 64*8
	jmp @store512
	cmp #4			; 8*16
	jmp @store128
	cmp #5			; 16*16
	jmp @store256
	cmp #6			; 32*16
	jmp @store512
	cmp #7			; 64*16
	jmp @store1024
	cmp #8			; 8*32
	jmp @store256
	cmp #9			; 16*32
	jmp @store512
	cmp #10			; 32*32
	jmp @store1024
	cmp #11			; 64*32
	jmp @store2048
	cmp #12			; 8*64
	jmp @store512
	cmp #13			; 16*64
	jmp @store1024
	cmp #14			; 32*64
	jmp @store2048
	cmp #15			; 64*64
	jmp @store4096


@store64:
	lda #64
	sta u4L
	lda #0
	sta u4H
	jmp @end_byte_jump_table
@store128:
	lda #128
	sta u4L
	lda #0
	sta u4H
	jmp @end_byte_jump_table
@store256:
	lda #0
	sta u4L
	lda #1
	sta u4H
	jmp @end_byte_jump_table
@store512:
	lda #0
	sta u4L
	lda #2
	sta u4H
	jmp @end_byte_jump_table
@store1024:
	lda #0
	sta u4L
	lda #4
	sta u4H
	jmp @end_byte_jump_table
@store2048:
	lda #0
	sta u4L
	lda #8
	sta u4H
	jmp @end_byte_jump_table
@store4096:
	lda #0
	sta u4L
	lda #16
	sta u4H
	jmp @end_byte_jump_table

@end_byte_jump_table:

	; u4 now holds the number of bytes required to store the NPC tiles

	; increment next_npc_vram by w*h
	clc
	lda next_npc_vram
	adc u4L
	sta next_npc_vram
	lda next_npc_vram+1
	adc u4H
	sta next_npc_vram+1
	lda next_npc_vram+2
	adc #0					; don't forget the highest byte
	sta next_npc_vram+2

	; increment next_npc_ram by w*h*f
	ldy Npc::size_and_frames
	lda (u0),y
	ora %00001111
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
	jmp @multiply_loop
@end_multiply_loop:

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

	; NOTE: The carry part of this addition is not actually needed so long as
	; .sizeof(Npc) is less than 8 and we are restricting ourselves to 32 NPCs.
	; If an optimization needs to happen, the carry addition can be removed.

@multiply_loop:
	cpx #0
	beq @return
	lda #.sizeof(Npc)
	clc
	adc u0L
	sta u0L
	adc u0H
	sta u0H
	dex
	jmp @multiply_loop

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
	sta next_npc_vram
	sta next_npc_vram+1
	sta next_npc_vram+2

	; set next_npc_ram to the beginning of the bank
	LoadW next_npc_ram, hi_mem

	rts

.endif ; NPC_ASM
