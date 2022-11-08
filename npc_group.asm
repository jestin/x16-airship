.ifndef NPC_GROUP_ASM
NPC_GROUP_ASM = 1

.include "npc.asm"

.segment "BSS"

; An NPC Group is a grouping of NPCs that can be manipulated and moved as one.
; The group keeps tracks of which NPCs need to be updated.

.struct NpcGroup

	; The number of NPCs in this group
	count			.res 1

	; The array of Grouped NPCs
	; reserve enough bytes for the maximum allowed group size (8)
	npcs			.res 16

	; X location on the map
	mapx			.res 2

	; Y location on the map
	mapy			.res 2

	; Size of the group
	sizex			.res 1
	sizey			.res 1

	; flip 
	; %000000vh
	flip			.res 1

.endstruct

; Each NPC in an NPC Group needs meta data in regards to its position in the
; NPC Group
.struct GroupedNpc

	; NPC index
	index			.res 1

	; relative X location
	relx			.res 1

	; relative Y location
	rely			.res 1

	; size in pixels
	sizex			.res 1
	sizey			.res 1

.endstruct

num_npc_groups:				.res 1

; We obviously will never need more NPC groups than we are allowed NPCs
npc_groups:					.res .sizeof(NpcGroup) * MAX_NPCS

; There will only ever be as many grouped NPCs as there are NPCs
grouped_npcs:				.res .sizeof(GroupedNpc) * MAX_NPCS

; the next grouped NPC address
next_grouped_npc:			.res 2


; This is an array of indexes shared by all maps.  They can make friendly names
; for their NPC groups by aliasing an offset into this array
npc_group_indexes:			.res MAX_NPCS

.segment "CODE"

;==================================================
; clear_npc_groups
;
; Clears the groups of NPCs and all their data
;
; void clear_npc_groups()
;==================================================
clear_npc_groups:

	; reset the count
	stz num_npc_groups

	; reset the next grouped NPC
	lda #<grouped_npcs
	sta next_grouped_npc
	lda #>grouped_npcs
	sta next_grouped_npc+1 
	rts

;==================================================
; add_npc_group
;
; Adds an NPC group
;
; void add_npc_group(byte sizex: u0L,
;						byte sizey: u0H,
;						out byte npc_group_index: x)
;==================================================
add_npc_group:

	; save the size for later
	lda u0H
	pha
	lda u0L
	pha

	; calculate the memory location of the new NPC Group
	ldx num_npc_groups				; should be the next npc group index
	jsr calculate_npc_group_address

	; set the location to 0
	lda #0
	ldy #NpcGroup::count
	sta (u0),y
	ldy #NpcGroup::mapx
	sta (u0),y
	ldy #NpcGroup::mapy
	sta (u0),y
	ldy #NpcGroup::flip
	sta (u0),y
	pla						; size X
	ldy #NpcGroup::sizex
	sta (u0),y
	pla						; size Y
	ldy #NpcGroup::sizey
	sta (u0),y

	inc num_npc_groups

	rts

;==================================================
; add_npc_to_group
;
; Adds an NPC to an NPC group
;
; void add_npc_to_group(byte npc_group_index: a
;						byte npc_index: x,
;						byte relx: u2L,
;						byte rely: u2H)
;==================================================
add_npc_to_group:

	phx			; store the NPC index on the stack for later

	; calculate the memory location of the new NPC Group
	tax
	jsr calculate_npc_group_address

	; u0 now holds the address of the NPC group
	; move it to u4 so we can look up the NPC
	MoveW u0, u4

	; create a new grouped NPC and add it to this NPC group's array
	lda next_grouped_npc
	sta u1L
	lda next_grouped_npc+1
	sta u1H

	; u1 is now the address of our grouped NPC

	; store the NPC index to the grouped NPC
	pla		; pul the NPC index from the stack and put it in A
	ldy #GroupedNpc::index
	sta (u1),y

	; get the NPC's size and store it for quick lookup
	tax
	jsr calculate_npc_address

	; u0 now holds the address of the NPC

	; store the npc's size

	ldy #Npc::size_and_frames
	lda (u0),y
	lsr									; shift frames out
	lsr
	lsr
	lsr
	sta u5L								; store for re-use
	and #%00000011						; just the width

	jsr sprite_size_to_pixels
	ldy #GroupedNpc::sizex
	sta (u1),y

	lda u5L
	lsr
	lsr
	jsr sprite_size_to_pixels
	ldy #GroupedNpc::sizey
	sta (u1),y

	; store relx
	lda u2L
	ldy #GroupedNpc::relx
	sta (u1),y

	; store rely
	lda u2H
	ldy #GroupedNpc::rely
	sta (u1),y

	; store GroupedNpc to the NpcGroup's npc array

	; get the address of the NPC array by adding the offset to the group
	; address and store it in u3
	clc
	lda #NpcGroup::npcs
	adc u4L
	sta u3L
	lda #0
	adc u4H
	sta u3H

	ldy #NpcGroup::count				; get the current count and store it in Y
	lda (u4),y
	asl									; double the value, since addresses are 2 bytes
	tay
	lda u1L								; store the GroupedNpc into the correct array position
	sta (u3),y
	iny
	lda u1H
	sta (u3),y

	; increment the group's NPC count
	ldy #NpcGroup::count
	lda (u4),y
	inc
	sta (u4),y

	; increment the next grouped NPC
	clc
	lda next_grouped_npc
	adc #(.sizeof(GroupedNpc))
	sta next_grouped_npc
	lda next_grouped_npc+1
	adc #0
	sta next_grouped_npc+1

	rts

;==================================================
; sprite_size_to_pixels
;
; void sprite_size_to_pixels(byte sprite_size: A,
;								byte pixel_size A)
;==================================================
sprite_size_to_pixels:

	cmp #0
	bne :+
	lda #8
	bra @return
:
	cmp #1
	bne :+
	lda #16
	bra @return
:
	cmp #2
	bne :+
	lda #32
	bra @return
:
	cmp #3
	bne :+
	lda #64
:
@return:
	rts

;==================================================
; set_npc_group_map_location
;
; Sets the NPCs location on the map.
;
; void set_npc_group_map_location(byte npc_group_index: x,
;									word mapx: u3,
;									word mapy: u4)
;==================================================
set_npc_group_map_location:

	jsr calculate_npc_group_address

	lda u3L
	ldy #NpcGroup::mapx
	sta (u0),y
	lda u3H
	ldy #NpcGroup::mapx+1
	sta (u0),y

	lda u4L
	ldy #NpcGroup::mapy
	sta (u0),y
	lda u4H
	ldy #NpcGroup::mapy+1
	sta (u0),y

	rts

;==================================================
; set_npc_group_flip
;
; Sets the NPCs flip setting
;
; void set_npc_group_flip(byte npc_group_index: x,
;							byte flip: A)
;==================================================
set_npc_group_flip:

	pha

	jsr calculate_npc_group_address

	pla
	ldy #NpcGroup::flip
	sta (u0),y

	rts

;==================================================
; update_npc_groups
;
; Updates the npc groups
;
; void update_npc_groups()
;==================================================
update_npc_groups:

	LoadW u0, npc_groups
	ldx #0
@group_loop:
	cpx num_npc_groups
	bcs @end_group_loop

	phx
	jsr update_npc_group
	plx
	
	; increment the address
	clc
	lda u0L
	adc #(.sizeof(NpcGroup))
	sta u0L
	lda u0H
	adc #0
	sta u0H

	; increment the loop counter
	inx
	bra @group_loop
@end_group_loop:

@return:
	rts

;==================================================
; update_npc_group
;
; Updates the values of a single npc.
;
; void update_npc_group(word npc_group_addr: u0)
;==================================================
update_npc_group:

	; load the count into X
	ldy #NpcGroup::count
	lda (u0),y
	tax

	; put the start of the NPC array in u4
	clc
	lda #NpcGroup::npcs
	adc u0L
	sta u4L
	lda #0
	adc u0H
	sta u4H

	; u4 now contains the start of the NPC array

	; loop through all the grouped NPCs
@npc_loop:
	dex			; start by decrementing so that x is now an index

	; get the grouped NPC
	txa
	asl				; double X
	tay
	lda (u4),y
	sta u5L
	iny
	lda (u4),y
	sta u5H

	; u5 now holds the address of the grouped NPC

	; update the position of the NPC based on the group and the relative position

	ldy #NpcGroup::mapx
	lda (u0),y
	sta u1L
	ldy #NpcGroup::mapx+1
	lda (u0),y
	sta u1H
	ldy #NpcGroup::mapy
	lda (u0),y
	sta u2L
	ldy #NpcGroup::mapy+1
	lda (u0),y
	sta u2H

	; u1 and u2 now contains the mapx and mapy of the group

	ldy #NpcGroup::flip
	lda (u0),y
	sta u3L
	ldy #NpcGroup::sizex
	lda (u0),y
	sta u6L
	ldy #NpcGroup::sizey
	lda (u0),y
	sta u6H
	
	jsr calculate_grouped_npc_location

	; set X to the npc index
	phx							; store the old X on the stack
	ldy #GroupedNpc::index
	lda (u5),y
	tax

	; with all calculations done, update the NPC itself
	jsr set_npc_map_location_depth_and_flip

	plx							; restore the old X
	cpx #0
	bne @npc_loop
@end_npc_loop:

@return:
	rts

;==================================================
; calculate_grouped_npc_location
;
; Calculates the absolute address of a particular
; NPC group given its index.
;
; void calculate_grouped_npc_location(
;							word group_x: u1,
;							word group_y: u2,
;							byte flip: u3L,
;							byte group_size_x: u6L,
;							byte group_size_y: u6H,
;							word grouped_npc: u5,
;							out word grouped_npc_x: u1,
;							out word grouped_npc_y: u2)
;==================================================
calculate_grouped_npc_location:

	lda u3L
	bne :+

	; flipped in neither direction
	; add the relx and rely from the grouped NPC
	clc
	ldy #GroupedNpc::relx
	lda (u5),y
	adc u1L
	sta u1L
	lda #0
	adc u1H
	sta u1H
	clc
	ldy #GroupedNpc::rely
	lda (u5),y
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H
	jmp @return

:

	bit #$01						; flipped horizontally only
	beq :+
	pha								; push A to check for vertical flip later

	; add the group size
	clc
	lda u1L
	adc u6L
	sta u1L
	lda u1H
	adc #0
	sta u1H

	; subtract the relative position
	sec
	lda u1L
	ldy #GroupedNpc::relx
	sbc (u5),y
	sta u1L
	lda u1H
	sbc #0
	sta u1H

	; subtract the NPC size
	sec
	lda u1L
	ldy #GroupedNpc::sizex
	sbc(u5),y
	sta u1L
	lda u1H
	sbc #0
	sta u1H

	; check if we need to flip vertically as well
	pla
	bit #$02						; flipped vertically only
	bne :+

	; add rely
	clc
	ldy #GroupedNpc::rely
	lda (u5),y
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H
	bra @return

:
	pha
	; add the group size
	clc
	lda u2L
	adc u6H
	sta u2L
	lda u2H
	adc #0
	sta u2H

	; subtract the relative position
	sec
	lda u2L
	ldy #GroupedNpc::rely
	sbc (u5),y
	sta u2L
	lda u2H
	sbc #0
	sta u2H

	; subtract the NPC size
	sec
	lda u2L
	ldy #GroupedNpc::sizey
	sbc(u5),y
	sta u2L
	lda u2H
	sbc #0
	sta u2H

	pla
	bit #$01
	bne @return					; this means we already flipped horizontally

	; add relx
	clc
	ldy #GroupedNpc::relx
	lda (u5),y
	adc u1L
	sta u1L
	lda #0
	adc u1H
	sta u1H
	bra @return

	; TODO calculate flipped vertically

@return:

	rts

;==================================================
; calculate_npc_group_address
;
; Calculates the absolute address of a particular
; NPC group given its index.
;
; void calculate_npc_group_address(
;							byte npc_group_index: x,
;							out word address: u0)
;==================================================
calculate_npc_group_address:

	phx

	; load the base address of the npc group array
	LoadW u0, npc_groups

@multiply_loop:
	cpx #0
	beq @return
	clc
	lda #.sizeof(NpcGroup)
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

.endif ; NPC_GROUP_ASM
