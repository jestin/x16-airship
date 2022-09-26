.ifndef NPC_PATH_ASM
NPC_PATH_ASM = 1

.include "npc_group.asm"

.segment "BSS"

; This represents a single stop along a path
.struct NpcPathStop

	; the x of this stop
	mapx 		.res 2

	; the y of this stop
	mapy		.res 2

	; can be set to indicate how fast to move
	speed_mask	.res 1

.endstruct

; This represents a movement path for an NPC group
.struct NpcPath

	; the npc group to apply this path to
	npc_group_index		.res 1

	; the number of stops along this path
	num_stops			.res 1

	; the next stop along this path
	next_stop			.res 1

	stops				.res 8 * .sizeof(NpcPathStop)

.endstruct

num_npc_paths:				.res 1

; We obviously will never need more NPC groups than we are allowed NPCs
npc_paths:					.res .sizeof(NpcPath) * MAX_NPCS

.segment "CODE"

;==================================================
; clear_npc_paths
;
; Clears the paths of NPCs and all their data
;
; void clear_npc_paths()
;==================================================
clear_npc_paths:

	; reset the count
	stz num_npc_paths

	rts

;==================================================
; add_npc_path
;
; Adds an NPC path
;
; void add_npc_path(byte npc_group_index: a,
;					out byte npc_path_index: x)
;==================================================
add_npc_path:
	; store the group index for later
	pha

	; calculate the memory location of the new NPC Path
	ldx num_npc_paths				; should be the next npc path index
	jsr calculate_npc_path_address

	; set the location to 0
	lda #0
	ldy #NpcPath::num_stops
	sta (u0),y
	ldy #NpcPath::next_stop
	sta (u0),y
	pla
	ldy #NpcPath::npc_group_index
	sta (u0),y

	inc num_npc_paths

	rts

;==================================================
; add_stop_to_npc_path
;
; Adds a stop to an NPC path
;
; void add_stop_to_npc_path(byte npc_path_index: a,
;							byte speed_mask: x,
;							byte mapx: u2L,
;							byte mapy: u2H)
;==================================================
add_stop_to_npc_path:
	; push X for later
	phx

	; get the address of the path
	tax
	jsr calculate_npc_path_address

	; get the base address of the stop array
	clc
	lda #NpcPath::stops
	adc u0L
	sta u1L
	lda #0
	adc u0H
	sta u1H

	; u1 now contains the base of the stops address

	; add the size of a stop in a loop to advance u1 to the new stop
	lda #NpcPath::num_stops
	lda (u0),y
	tax					; x now contains the index of the new stop
@multiply_loop:
	cpx #0
	beq @end_multiply_loop
	
	clc
	lda u1L
	adc #(.sizeof(NpcPathStop))
	sta u1L
	lda u1H
	adc #0
	sta u1H

	bra @multiply_loop
@end_multiply_loop:

	; u1 now contains the address of the new stop

	ldy #NpcPathStop::mapx

	pla
	ldy #NpcPathStop::speed_mask
	sta (u1),y

	rts

;==================================================
; update_npc_paths
;
; Updates the npc paths
;
; void update_npc_paths()
;==================================================
update_npc_paths:

	LoadW u1, npc_paths
	ldx #0
@path_loop:
	cpx num_npc_paths
	beq @end_path_loop

	phx		; push counter so we can use X

	; get the next stop
	jsr get_next_stop_in_path

	; u2 now had the address of the next NPC path stop

	; TODO: check the speed_mask to determine if it's time for an update

	; get the xy from the stop
	ldy #NpcPathStop::mapx
	lda (u2),y
	sta u5L
	ldy #NpcPathStop::mapx+1
	lda (u2),y
	sta u5H
	ldy #NpcPathStop::mapy
	lda (u2),y
	sta u6L
	ldy #NpcPathStop::mapy+1
	lda (u2),y
	sta u6H

	; now u5 and u6 hold the stop's x,y

	; get the NPC group for this path
	ldy #NpcPath::npc_group_index
	lda (u1),y
	tax
	jsr calculate_npc_group_address

	; u0 now has the address to the NPC group

	; store the current location of the group in u3 and u4
	ldy #NpcGroup::mapx
	lda (u0),y
	sta u3L
	ldy #NpcGroup::mapx+1
	lda (u0),y
	sta u3H
	ldy #NpcGroup::mapy
	lda (u0),y
	sta u4L
	ldy #NpcGroup::mapy+1
	lda (u0),y
	sta u4H

	; now u3 and u4 hold the group's current x,y

	; calculate the next position of the group and set it 
	ldy #NpcPath::npc_group_index
	lda (u1),y
	tax
	ldy #NpcPathStop::speed_mask
	lda (u2),y
	jsr calculate_next_npc_position

	jsr set_npc_group_map_location

	; check if the stop needs advancing
	cmp #0
	beq @continue

	ldy #NpcPath::num_stops
	lda (u1),y
	sta u2L						; re-using u2, so it is no longer the stop address
	ldy #NpcPath::next_stop
	lda (u1),y
	inc							; increment the next stop
	cmp u2L
	bcc @set_next_stop
	lda #0
@set_next_stop:
	sta (u1),y					; y should already be #NpcPath::next_stop

@continue:
	; increment address
	clc
	lda u1L
	adc #(.sizeof(NpcPath))
	sta u1L
	lda u1H
	adc #0
	sta u1H
	plx		; restore loop counter
	inx		; increment loop counter
	jmp @path_loop
@end_path_loop:

	rts

;==================================================
; get_next_stop_in_path
;
; void get_next_stop_in_path(word stop: u1)
;==================================================
get_next_stop_in_path:
	clc
	lda #NpcPath::stops
	adc u1L
	sta u2L
	lda #0
	adc u1H
	sta u2H						; u2 now points to the start of the stops array
	ldy #NpcPath::next_stop
	lda (u1),y
	tax

@stop_loop:
	beq @end_stop_loop	

	clc
	lda #(.sizeof(NpcPathStop))
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H

	dex
	bra @stop_loop
@end_stop_loop:

	rts

;==================================================
; calculate_next_npc_position
;
; void calculate_next_npc_position(
;								word curx: u3,
;								word cury: u4,
;								word stopx: u5,
;								word stopy: u6,
;								byte speed_mask: a,
;								out word newx: u3,
;								out word newy: u4
;								out advance_stop: a)
;==================================================
calculate_next_npc_position:

	; TODO: figure out next position

	rts

;==================================================
; calculate_npc_path_address
;
; Calculates the absolute address of a particular
; NPC path given its index.
;
; void calculate_npc_path_address(
;							byte npc_path_index: x,
;							out byte address: u0)
;==================================================
calculate_npc_path_address:

	phx

	; load the base address of the npc path array
	LoadW u0, npc_paths

@multiply_loop:
	cpx #0
	beq @return
	clc
	lda #.sizeof(NpcPath)
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

.endif ; NPC_PATH_ASM
