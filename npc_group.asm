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
; void add_npc_group(out byte npc_group_index: x)
;==================================================
add_npc_group:

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
	adc u0L
	sta u3L
	lda #0
	adc u0H
	sta u3H

	ldy #NpcGroup::count				; get the current count and store it in Y
	lda (u0),y
	asl									; double the value, since addresses are 2 bytes
	tay
	lda u1L								; store the GroupedNpc into the correct array position
	sta (u3),y
	iny
	lda u1H
	sta (u3),y

	; increment the group's NPC count
	ldy #NpcGroup::count
	lda (u0),y
	inc
	sta (u0),y

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

	; set X to the npc index
	phx							; store the old X on the stack
	ldy #GroupedNpc::index
	lda (u5),y
	tax

	; with all calculations done, update the NPC itself
	jsr set_npc_map_location

	plx							; restore the old X
	cpx #0
	bne @npc_loop
@end_npc_loop:

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
;							out byte address: u0)
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
