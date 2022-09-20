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

; This is the area of memory where npc groups allocate for their arrays of npc
; indexes.  Because we aren't supporting NPCs belonging to more than one group,
; we only need as many bytes as we allow NPCs.
npc_group_arrays:			.res MAX_NPCS

; the next available array starting address
npc_group_next_array:		.res 2

; There will only ever be as many grouped NPCs as there are NPCs
grouped_npcs:				.res .sizeof(GroupedNpc) * MAX_NPCS

; the next grouped NPC address
next_grouped_npc:			.res 2

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

	; reset the next array address
	lda #<npc_group_arrays
	sta npc_group_next_array
	lda #>npc_group_arrays
	sta npc_group_next_array+1

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
	ldy #GroupedNpc::relx
	sta (u1),y

	; store GroupedNpc to the NpcGroup's npc array
	ldy #NpcGroup::npcs					; get the address of the NPC array and put it in u3
	lda (u0),y
	sta u3L
	iny
	lda (u0),y
	sta u3H
	ldy #NpcGroup::count				; get the current count and store it in X
	lda (u0),y
	tax
	lda u1L								; store the GroupedNpc into the correct array position
	sta u3,x
	inx
	lda u1H
	sta u3,x

	; increment the group's NPC count
	ldy #NpcGroup::count
	lda (u0),y
	inc
	sta (u0),y

	; increment the next grouped NPC
	IncW next_grouped_npc

	rts

;==================================================
; calculate_npc_group_address
;
; Calculates the absolute address of a particular
; NPC given its index.
;
; void calculate_npc_group_address(
;							byte npc_group_index: x,
;							out byte address: u0)
;==================================================
calculate_npc_group_address:

	phx

	; load the base address of the npc array
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
