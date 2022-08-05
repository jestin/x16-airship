.ifndef NPC_GROUP_ASM
NPC_GROUP_ASM = 1

.include "npc.asm"

.segment "BSS"

; An NPC Group is a grouping of NPCs that can be manipulated and moved as one.
; The group keeps tracks of which NPCs need to be updated.

.struct NpcGroup

	; The number of NPCs in this group
	count			.res 1

	; The address of the array of Grouped NPCs
	npcs			.res 2

	; X location on the map
	mapx				.res 2

	; Y location on the map
	mapy				.res 2

.endstruct

; Each NPC in an NPC Group needs meta data in regards to its position in the
; NPC Group
.struct GroupedNpc

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

; ext grouped NPC address
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
	stz next_grouped_npc
	stz next_grouped_npc+1

	rts

.endif ; NPC_GROUP_ASM
